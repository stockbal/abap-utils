"! <p class="shorttext synchronized" lang="en">Code Inspector Run</p>
CLASS zcl_dutils_ci_run DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_ci_run.

    METHODS:
      "! <p class="shorttext synchronized" lang="en">Creates new CI Run</p>
      constructor
        IMPORTING
          variant_name         TYPE sci_chkv
          object_set           TYPE zif_dutils_ci_run=>ty_ci_object_set
          resolve_sub_packages TYPE abap_bool
          object_assignment    TYPE zif_dutils_ci_run=>ty_ci_object_assignment.
  PROTECTED SECTION.
    METHODS:
      cleanup
        IMPORTING
          !object_set TYPE REF TO cl_ci_objectset
        RAISING
          zcx_dutils_exception ,
      create_variant
        IMPORTING
          !variant_name TYPE sci_chkv
        RETURNING
          VALUE(result) TYPE REF TO cl_ci_checkvariant
        RAISING
          zcx_dutils_exception ,
      skip_object
        IMPORTING
          !obj_info     TYPE scir_objs
        RETURNING
          VALUE(result) TYPE abap_bool.
  PRIVATE SECTION.
    DATA:
      package_reader       TYPE REF TO zif_dutils_devc_reader,
      inspection           TYPE REF TO cl_ci_inspection,
      inspection_name      TYPE sci_objs,
      run_mode             TYPE zif_dutils_ci_run~ty_run_mode VALUE zif_dutils_ci_run~c_run_mode-run_loc_parallel,
      successful           TYPE abap_bool,
      plain_results        TYPE scit_alvlist,
      variant_name         TYPE sci_chkv,
      object_set_ranges    TYPE zif_dutils_ci_run=>ty_ci_object_set,
      object_assignments   TYPE zif_dutils_ci_run=>ty_ci_object_assignment,
      resolve_sub_packages TYPE abap_bool,
      insp_duration        TYPE timestampl.

    METHODS:
      create_inspection
        IMPORTING
          !object_set    TYPE REF TO cl_ci_objectset
          !check_variant TYPE REF TO cl_ci_checkvariant
        RAISING
          zcx_dutils_exception,
      create_objectset
        RETURNING
          VALUE(result) TYPE REF TO cl_ci_objectset
        RAISING
          zcx_dutils_exception,
      run_inspection
        RAISING
          zcx_dutils_exception.
ENDCLASS.



CLASS zcl_dutils_ci_run IMPLEMENTATION.

  METHOD constructor.
    me->package_reader = zcl_dutils_reader_factory=>get_package_reader( ).
    me->object_set_ranges = object_set.
    me->object_assignments = object_assignment.
    me->variant_name = variant_name.
    me->resolve_sub_packages = resolve_sub_packages.

    " the inspection and object set are created with dummy names.
    " Because we want to persist them so we can run it in parallel.
    " Both are deleted afterwards.
    me->inspection_name = |{ sy-uname }_{ sy-datum }_{ sy-uzeit }|.
    me->run_mode = COND #(
      WHEN sy-batch = abap_true THEN zif_dutils_ci_run~c_run_mode-run_in_batch
      ELSE                           zif_dutils_ci_run~c_run_mode-run_loc_parallel ).
  ENDMETHOD.

  METHOD zif_dutils_ci_run~get_duration.
    result = insp_duration.
  ENDMETHOD.


  METHOD zif_dutils_ci_run~get_results.
    results = plain_results.
  ENDMETHOD.


  METHOD zif_dutils_ci_run~has_results.
    IF kind IS SUPPLIED.
      result = xsdbool( line_exists( plain_results[ kind = kind ] ) ).
    ELSE.
      result = xsdbool( plain_results IS NOT INITIAL ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_dutils_ci_run~is_successful.
    result = me->successful.
  ENDMETHOD.


  METHOD zif_dutils_ci_run~run.

    TRY.
        DATA(object_set) = create_objectset( ).
        DATA(check_variant) = create_variant( me->variant_name ).

        create_inspection(
          object_set     = object_set
          check_variant  = check_variant ).

        run_inspection( ).

        cleanup( object_set ).

        successful = xsdbool( me->plain_results IS INITIAL ).
      CATCH zcx_dutils_exception INTO DATA(error).
        cleanup( object_set ).
        RAISE EXCEPTION error.
    ENDTRY.

  ENDMETHOD.

  METHOD cleanup.

    IF me->inspection IS BOUND.

      me->inspection->delete(
        EXCEPTIONS
          locked              = 1
          error_in_enqueue    = 2
          not_authorized      = 3
          exceptn_appl_exists = 4
          OTHERS              = 5 ).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_dutils_exception
          EXPORTING
            text = |Couldn't delete inspection. Subrc = { sy-subrc }|.
      ENDIF.

    ENDIF.

    IF object_set IS BOUND.
      object_set->delete(
        EXCEPTIONS
          exists_in_insp   = 1
          locked           = 2
          error_in_enqueue = 3
          not_authorized   = 4
          exists_in_objs   = 5
          OTHERS           = 6 ).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_dutils_exception
          EXPORTING
            text = |Couldn't delete objectset. Subrc = { sy-subrc }|.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD create_variant.

    IF variant_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_dutils_exception
        EXPORTING
          text = |No check variant supplied.|.
    ENDIF.

    cl_ci_checkvariant=>get_ref(
      EXPORTING
        p_user                   = ''
        p_name                   = variant_name
      RECEIVING
        p_ref                    = result
      EXCEPTIONS
        chkv_not_exists          = 1
        missing_parameter        = 2
        OTHERS                   = 3 ).

    CASE sy-subrc.
      WHEN 1.
        RAISE EXCEPTION TYPE zcx_dutils_exception
          EXPORTING
            text = |Check variant { variant_name } doesn't exist|.
      WHEN 2.
        RAISE EXCEPTION TYPE zcx_dutils_exception
          EXPORTING
            text = |Parameter missing for check variant { variant_name }|.
    ENDCASE.

  ENDMETHOD.

  METHOD skip_object.

    CASE obj_info-objtype.

      WHEN 'PROG'.

        SELECT SINGLE subc
          FROM trdir
          WHERE name = @obj_info-objname
        INTO @DATA(program_type).

        result = xsdbool( program_type = 'I' ). " Include program.

      WHEN OTHERS.
        result = abap_false.

    ENDCASE.

  ENDMETHOD.

  METHOD create_inspection.

    cl_ci_inspection=>create(
      EXPORTING
        p_user           = sy-uname
        p_name           = me->inspection_name
      RECEIVING
        p_ref            = me->inspection
      EXCEPTIONS
        locked           = 1
        error_in_enqueue = 2
        not_authorized   = 3
        OTHERS           = 4 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_dutils_exception
        EXPORTING
          text = |Failed to create inspection. Subrc = { sy-subrc }|.
    ENDIF.

    me->inspection->set(
      p_chkv = check_variant
      p_objs = object_set ).

    me->inspection->save(
      EXCEPTIONS
        missing_information = 1
        insp_no_name        = 2
        not_enqueued        = 3
        OTHERS              = 4 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_dutils_exception
        EXPORTING
          text = |Failed to save inspection. Subrc = { sy-subrc }|.
    ENDIF.

  ENDMETHOD.


  METHOD create_objectset.
    DATA: obj_infos TYPE scit_objs.

    IF me->object_assignments-package_range IS NOT INITIAL AND
       me->resolve_sub_packages = abap_true.

      DATA(packages) = me->package_reader->resolve_packages( me->object_assignments-package_range ).
      DATA(sub_packages) = me->package_reader->get_subpackages_by_range( packages ).

      me->object_assignments-package_range = VALUE #(
        ( LINES OF packages )
        ( LINES OF sub_packages )
      ).
    ENDIF.

    IF me->object_assignments IS NOT INITIAL AND me->object_set_ranges IS INITIAL.
      cl_ci_objectset=>get_packages_from_akh(
        EXPORTING
          p_socomp      = me->object_assignments-appl_comp_range
          p_soappl      = me->object_assignments-software_comp_range
          p_sopdev      = me->object_assignments-transport_layer_range
          p_sodevc      = me->object_assignments-package_range
          p_soosys      = me->object_assignments-source_system_range
          p_soresp      = me->object_assignments-responsible_range
        IMPORTING
          p_result_devc = DATA(final_package_range)
          p_ok          = DATA(packages_ok)
      ).

      IF packages_ok = abap_true.

        SELECT object   AS objtype,
               obj_name AS objname
          FROM tadir
          WHERE devclass IN @final_package_range
          AND delflag = @abap_false
          AND srcsystem IN @object_assignments-source_system_range
          AND author IN @object_assignments-responsible_range
          AND pgmid = 'R3TR' ##TOO_MANY_ITAB_FIELDS     "#EC CI_GENBUFF
        INTO CORRESPONDING FIELDS OF TABLE @obj_infos.

        cl_ci_objectset=>save_from_list(
          EXPORTING
            p_objects           = obj_infos
            p_name              = me->inspection_name
          RECEIVING
            p_ref               = result
          EXCEPTIONS
            objs_already_exists = 1
            locked              = 2
            error_in_enqueue    = 3
            not_authorized      = 4
            OTHERS              = 5
        ).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_dutils_exception
            EXPORTING
              text = |Object Set Creation failed. Subrc = { sy-subrc }|.
        ENDIF.
      ENDIF.
    ELSEIF me->object_set_ranges IS NOT INITIAL.
      result = cl_ci_objectset=>create(
        p_user = sy-uname
        p_name = me->inspection_name
      ).
      result->save_objectset(
        EXPORTING
          p_tadir               = VALUE #(
            soappl = me->object_assignments-appl_comp_range
            socomp = me->object_assignments-software_comp_range
            sodevc = me->object_assignments-package_range
            soosys = me->object_assignments-source_system_range
            soresp = me->object_assignments-responsible_range
          )
          p_fugrs               = VALUE #( soname = me->object_set_ranges-func_group_range )
          p_class               = VALUE #( soname = me->object_set_ranges-class_range )
          p_repos               = VALUE #( soname = me->object_set_ranges-report_name_range )
          p_ddics               = VALUE #( soname = me->object_set_ranges-ddic_type_range )
          p_typps               = VALUE #( soname = me->object_set_ranges-type_group_range )
          p_wdyns               = VALUE #( soname = me->object_set_ranges-wdyn_comp_name_range )
          p_sel_flags           = VALUE #(
            class = xsdbool( me->object_set_ranges-class_range IS NOT INITIAL )
            ddics = xsdbool( me->object_set_ranges-ddic_type_range IS NOT INITIAL )
            fugrs = xsdbool( me->object_set_ranges-func_group_range IS NOT INITIAL )
            repos = xsdbool( me->object_set_ranges-report_name_range IS NOT INITIAL )
            typps = xsdbool( me->object_set_ranges-type_group_range IS NOT INITIAL )
            wdyns = xsdbool( me->object_set_ranges-wdyn_comp_name_range IS NOT INITIAL )
          )
        EXCEPTIONS
          no_valid_selection    = 1
          missing_program_param = 2
          not_enqueued          = 3
          not_authorized        = 4
          OTHERS                = 5
      ).
      IF sy-subrc <> 0.
        cleanup( result ).
        RAISE EXCEPTION TYPE zcx_dutils_exception
          EXPORTING
            text = |Object Set Creation failed. Subrc = { sy-subrc }|.
      ENDIF.

    ENDIF.

    " if no objects have been determined no inspection is possible
    IF lines( result->iobjlst-objects ) = 0.
      cleanup( result ).
      RAISE EXCEPTION TYPE zcx_dutils_exception
        EXPORTING
          text = |No Objects for checking have been determined.|.
    ENDIF.
  ENDMETHOD.


  METHOD run_inspection.

    DATA: start_time TYPE timestampl,
          end_time   TYPE timestampl.

    GET TIME STAMP FIELD start_time.

    me->inspection->run(
      EXPORTING
        p_howtorun            = me->run_mode
      EXCEPTIONS
        invalid_check_version = 1
        OTHERS                = 2 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_dutils_exception
        EXPORTING
          text = |Code inspector run failed. Subrc = { sy-subrc }|.
    ENDIF.

    GET TIME STAMP FIELD end_time.

    insp_duration = cl_abap_timestamp_util=>get_instance( )->tstmpl_seconds_between(
      iv_timestamp0 = start_time
      iv_timestamp1 = end_time ).

    me->inspection->plain_list( IMPORTING p_list = me->plain_results ).

    SORT me->plain_results BY objtype objname test code sobjtype sobjname line col.

    DELETE ADJACENT DUPLICATES FROM me->plain_results.

  ENDMETHOD.


ENDCLASS.

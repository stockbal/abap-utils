"! <p class="shorttext synchronized" lang="en">Logs Object Environment</p>
CLASS zcl_dutils_oea_analyzer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_oea_analyzer,
      zif_dutils_oea_analyzer_par.

    METHODS:
      "! <p class="shorttext synchronized" lang="en">Create new Analyzer instance</p>
      constructor
        IMPORTING
          source_objects TYPE zif_dutils_ty_global=>ty_tadir_objects
          parallel       TYPE abap_bool OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      c_two_hour_validity TYPE timestamp VALUE 7200.

    DATA:
      id                  TYPE sysuuid_x16,
      tadir_obj_data      TYPE zif_dutils_ty_global=>ty_tadir_objects,
      source_objects_flat TYPE zif_dutils_ty_oea=>ty_source_objects_ext,
      source_objects      TYPE zif_dutils_oea_source_object=>ty_table,
      parallel            TYPE abap_bool,
      repo_reader         TYPE REF TO zif_dutils_ddic_repo_reader,
      obj_env_dac         TYPE REF TO zif_dutils_oea_dac.

    METHODS:
      "! <p class="shorttext synchronized" lang="en">Fills analysis information</p>
      fill_analysis_info,
      "! <p class="shorttext synchronized" lang="en">Resolves source object - if needed</p>
      "! Objects of type DEVC cannot be used directly. Instead all objects belonging to the
      "! package are used as source objects.
      resolve_source_objects,
      "! <p class="shorttext synchronized" lang="en">Persists all source objects</p>
      persist_src_objects,
      is_parallel_active
        RETURNING
          VALUE(result) TYPE abap_bool,
      run_parallel
        IMPORTING
          source_object TYPE REF TO zif_dutils_oea_source_object,
      run_serial
        IMPORTING
          source_object TYPE REF TO zif_dutils_oea_source_object,
      derive_src_objects
        IMPORTING
          source_object TYPE REF TO zif_dutils_oea_source_object,
      analyze.
ENDCLASS.



CLASS zcl_dutils_oea_analyzer IMPLEMENTATION.

  METHOD constructor.
    me->tadir_obj_data = tadir_obj_data.
    me->id = zcl_dutils_system_util=>create_sysuuid_x16( ).
    me->parallel = parallel.
    me->repo_reader = zcl_dutils_ddic_readers=>create_repo_reader( ).
    me->obj_env_dac = zcl_dutils_oea_dac=>get_instance( ).
    me->tadir_obj_data = source_objects.
  ENDMETHOD.

  METHOD zif_dutils_oea_analyzer~run.
    fill_analysis_info( ).
    resolve_source_objects( ).

    analyze( ).

    COMMIT WORK.
  ENDMETHOD.

  METHOD zif_dutils_oea_analyzer_par~run.

  ENDMETHOD.

  METHOD zif_dutils_oea_analyzer~get_result.

  ENDMETHOD.

  METHOD zif_dutils_oea_analyzer~get_id.
    result = me->id.
  ENDMETHOD.

  METHOD zif_dutils_oea_analyzer~set_id.
    me->id = id.
  ENDMETHOD.

  METHOD fill_analysis_info.
    GET TIME STAMP FIELD DATA(valid_to).

    valid_to = cl_abap_timestamp_util=>get_instance( )->tstmp_add_seconds(
      iv_timestamp = valid_to
      iv_seconds   = c_two_hour_validity ).

    me->id = zcl_dutils_system_util=>create_sysuuid_x16( ).

    me->obj_env_dac->insert_analysis_info( VALUE #(
      analysis_id = me->id
      created_by  = sy-uname
      valid_to    = valid_to ) ).

  ENDMETHOD.

  METHOD resolve_source_objects.
    DATA: derived_source_objects TYPE TABLE OF REF TO zif_dutils_oea_source_object.

    LOOP AT me->tadir_obj_data INTO DATA(tadir_obj_data).
      TRY.
          DATA(source_obj) = zcl_dutils_oea_factory=>create_source_object(
            name          = tadir_obj_data-name
            external_type = tadir_obj_data-type ).
        CATCH zcx_dutils_oea_no_type.
          " source object is not usable, so skip it
          CONTINUE.
      ENDTRY.

      IF tadir_obj_data-type = zif_dutils_c_tadir_type=>package.
        source_obj->set_generated( ).

        derive_src_objects( source_obj ).
        source_obj->persist( me->id ).
      ELSE.
        source_obj->set_processing( ).
        me->source_objects = VALUE #( BASE me->source_objects ( source_obj ) ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD derive_src_objects.
    DATA(derived_objects) = me->repo_reader->reset(
    )->include_by_package(
      packages            = VALUE #( ( source_object->get_display_name( ) ) )
      resolve_subpackages = abap_true
    )->select( ).

    LOOP AT derived_objects ASSIGNING FIELD-SYMBOL(<derived_object>).

      TRY.
          DATA(derived_src_obj) = zcl_dutils_oea_factory=>create_source_object(
            name          = <derived_object>-name
            external_type = <derived_object>-type ).
        CATCH zcx_dutils_oea_no_type.
          " source object is not usable, so skip it
          CONTINUE.
      ENDTRY.

      derived_src_obj->set_parent_ref( source_object->get_id( ) ).
      derived_src_obj->set_processing( ).

      me->source_objects = VALUE #( BASE me->source_objects ( derived_src_obj ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD persist_src_objects.
    CHECK me->source_objects_flat IS NOT INITIAL.

    me->obj_env_dac->insert_source_objects( me->source_objects_flat ).
  ENDMETHOD.

  METHOD analyze.

    DATA(is_parallel) = is_parallel_active( ).

    LOOP AT me->source_objects INTO DATA(src_obj).
      CHECK src_obj->needs_processing( ).

      IF is_parallel = abap_true.
        run_parallel( src_obj ).
      ELSE.
        run_serial( src_obj ).
      ENDIF.

      DELETE me->source_objects.
    ENDLOOP.

  ENDMETHOD.

  METHOD is_parallel_active.
    result = xsdbool( me->parallel = abap_true AND lines( me->source_objects_flat ) > 1 ).
  ENDMETHOD.

  METHOD run_parallel.

  ENDMETHOD.

  METHOD run_serial.
    source_object->determine_environment( ).
    source_object->persist( me->id ).
    source_object->set_processing( abap_false ).
  ENDMETHOD.

ENDCLASS.

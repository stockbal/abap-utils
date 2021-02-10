"! <p class="shorttext synchronized" lang="en">WB Object Utility</p>
CLASS zcl_dutils_wb_object_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Resolve Include to WB object</p>
      "! Resolves a given Include to a workbench object<br/>
      "! Possible values are:
      "! <ul>
      "! <li>FUGR/I - Function Group Include</li>
      "! <li>FUGR/FF - Function Module</li>
      "! <li>PROG/I - Program Include
      "! </ul>
      resolve_include_to_wb_object
        IMPORTING
          include_name     TYPE progname
        RETURNING
          VALUE(wb_object) TYPE zif_dutils_ty_global=>ty_wb_object,

      "! <p class="shorttext synchronized" lang="en">Retrieves full workbench type for given type</p>
      get_full_wb_object_type
        IMPORTING
          type          TYPE seu_obj
        RETURNING
          VALUE(result) TYPE wbobjtype,

      "! <p class="shorttext synchronized" lang="en">Determines full workbench object name</p>
      determine_wb_obj_name
        IMPORTING
          name          TYPE sobj_name
          external_type TYPE trobjtype
        RETURNING
          VALUE(result) TYPE zif_dutils_ty_global=>ty_wb_object_name.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS:
      get_fugr_from_prog
        IMPORTING
          program       TYPE progname
        RETURNING
          VALUE(result) TYPE rs38l_area.
ENDCLASS.



CLASS zcl_dutils_wb_object_util IMPLEMENTATION.

  METHOD get_full_wb_object_type.

    "TODO: check behavior for certain types like DOCT
    cl_wb_object_type=>create_from_exttype(
      EXPORTING  p_external_id    = type
      RECEIVING  p_wb_object_type = DATA(wb_object_type)
      EXCEPTIONS OTHERS           = 1 ).
    CHECK sy-subrc = 0.

    result = VALUE #(
      objtype_tr = wb_object_type->get_r3tr_type( )
      subtype_wb = wb_object_type->internal_id ).

    " Some types like BOBF do not have a sub type
    IF result-subtype_wb = cl_wb_registry=>c_generated.
      CLEAR result-subtype_wb.
    ENDIF.
  ENDMETHOD.


  METHOD resolve_include_to_wb_object.
    DATA: is_fugr_include     TYPE abap_bool,
          is_functionmodule   TYPE abap_bool,
          function_name       TYPE rs38l_fnam,
          function_group_name TYPE rs38l_area.

    CALL FUNCTION 'RS_PROGNAME_SPLIT'
      EXPORTING
        progname_with_namespace     = include_name
      IMPORTING
        fugr_is_include_name        = is_fugr_include
        fugr_is_functionmodule_name = is_functionmodule
      EXCEPTIONS
        delimiter_error             = 0.

    IF is_fugr_include = abap_true.
      wb_object-type = zif_dutils_c_tadir_type=>function_group.
    ELSE.
      wb_object-type = zif_dutils_c_tadir_type=>program.
    ENDIF.

    IF is_functionmodule = abap_true.
      DATA(l_include) = include_name.

      CALL FUNCTION 'FUNCTION_INCLUDE_INFO'
        CHANGING
          funcname = function_name
          include  = l_include
          group    = function_group_name
        EXCEPTIONS
          OTHERS   = 0.

      wb_object-sub_type = swbm_c_type_function.
      wb_object-name = function_group_name.
      wb_object-display_name = function_name.
    ELSE.
      wb_object-sub_type = swbm_c_type_prg_include.
      wb_object-name =
      wb_object-display_name = include_name.
    ENDIF.
  ENDMETHOD.

  METHOD determine_wb_obj_name.
    CASE external_type.

        " Currently only Function modules receive special handling
      WHEN zif_dutils_c_object_type=>function_module.
        SELECT SINGLE pname FROM tfdir WHERE funcname = @name INTO @DATA(prog_of_fugr).
        result = VALUE #(
          display_name = name
          name         = get_fugr_from_prog( prog_of_fugr ) ).

      WHEN OTHERS.
        result = VALUE #(
          display_name = name
          name         = name ).

    ENDCASE.
  ENDMETHOD.

  METHOD get_fugr_from_prog.
    CALL FUNCTION 'FUNCTION_INCLUDE_SPLIT'
      EXPORTING
        program = program
      IMPORTING
        group   = result
      EXCEPTIONS
        OTHERS  = 1.
  ENDMETHOD.

ENDCLASS.

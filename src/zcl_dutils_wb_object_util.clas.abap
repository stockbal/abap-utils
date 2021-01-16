"! <p class="shorttext synchronized" lang="en">WB Object Utility</p>
CLASS zcl_dutils_wb_object_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_dutils_wb_object_util.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DUTILS_WB_OBJECT_UTIL IMPLEMENTATION.


  METHOD zif_dutils_wb_object_util~get_full_wb_object_type.
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


  METHOD zif_dutils_wb_object_util~resolve_include_to_wb_object.
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
      wb_object-type = 'FUGR'.
    ELSE.
      wb_object-type = 'PROG'.
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
ENDCLASS.

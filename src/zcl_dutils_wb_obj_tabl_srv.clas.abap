"! <p class="shorttext synchronized" lang="en">WB Object Service for DDIC Table</p>
CLASS zcl_dutils_wb_obj_tabl_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_wb_obj_service.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dutils_wb_obj_tabl_srv IMPLEMENTATION.

  METHOD zif_dutils_wb_obj_service~get_wb_object.
    result = VALUE #(
      display_name = display_name
      name         = display_name
      type         = zif_dutils_c_tadir_type=>table
      sub_type     = zcl_dutils_tabl_util=>get_table_wb_type( CONV #( display_name ) ) ).
  ENDMETHOD.

ENDCLASS.

"! <p class="shorttext synchronized" lang="en">API for Object Environment Analysis</p>
CLASS zcl_dutils_oea_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Create new Object Environment Analyzer</p>
      create_analyzer
        IMPORTING
          description    TYPE string OPTIONAL
          source_objects TYPE zif_dutils_ty_global=>ty_tadir_objects
          parallel       TYPE abap_bool OPTIONAL
        RETURNING
          VALUE(result)  TYPE REF TO zif_dutils_oea_analyzer,

      "! <p class="shorttext synchronized" lang="en">Creates new used object instance</p>
      create_used_object
        IMPORTING
          name               TYPE seu_objkey
          external_type      TYPE trobjtype
          enclosing_obj_name TYPE seu_objkey
        RETURNING
          VALUE(result)      TYPE REF TO zif_dutils_oea_used_object,

      "! <p class="shorttext synchronized" lang="en">Creates new source object instance</p>
      create_source_object
        IMPORTING
          name          TYPE sobj_name
          external_type TYPE trobjtype
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_oea_source_object
        RAISING
          zcx_dutils_no_wb_type
          zcx_dutils_not_exists.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS:
      get_wb_object
        IMPORTING
          display_name  TYPE sobj_name
          external_type TYPE trobjtype
        RETURNING
          VALUE(result) TYPE zif_dutils_ty_global=>ty_wb_object
        RAISING
          zcx_dutils_not_exists
          zcx_dutils_no_wb_type,
      get_full_type
        IMPORTING
          display_name  TYPE sobj_name
          external_type TYPE trobjtype
        RETURNING
          VALUE(result) TYPE wbobjtype.
ENDCLASS.



CLASS zcl_dutils_oea_factory IMPLEMENTATION.

  METHOD create_analyzer.
    result = NEW zcl_dutils_oea_analyzer(
      description    = description
      source_objects = source_objects
      parallel       = parallel ).
  ENDMETHOD.

  METHOD create_source_object.
    DATA(wb_object) = get_wb_object(
      display_name  = name
      external_type = external_type ).

    result = NEW zcl_dutils_oea_source_object(
      name         = wb_object-name
      display_name = wb_object-display_name
      type         = wb_object-type
      sub_type     = wb_object-sub_type
      external_type = external_type ).
  ENDMETHOD.

  METHOD create_used_object.
    TRY.
        DATA(wb_object) = get_wb_object(
          display_name  = CONV #( name )
          external_type = external_type ).
      CATCH zcx_dutils_not_exists
            zcx_dutils_no_wb_type ##NO_HANDLER.
    ENDTRY.

    result = NEW zcl_dutils_oea_used_object(
      name         = CONV #( wb_object-name )
      display_name = CONV #( wb_object-display_name )
      type         = wb_object-type
      sub_type     = wb_object-sub_type ).
  ENDMETHOD.

  METHOD get_wb_object.
    CASE external_type.

      WHEN zif_dutils_c_object_type=>include.
        result = zcl_dutils_wb_object_util=>resolve_include_to_wb_object( display_name ).

      WHEN OTHERS.
        DATA(obj_name) = zcl_dutils_wb_object_util=>determine_wb_obj_name(
          name          = display_name
          external_type = external_type ).

        DATA(type) = get_full_type(
          display_name  = obj_name-display_name
          external_type = external_type ).

        IF type-objtype_tr IS INITIAL.
          RAISE EXCEPTION TYPE zcx_dutils_no_wb_type
            EXPORTING
              text = |No WB Type for { external_type } found|.
        ENDIF.

        result = VALUE #(
          name         = obj_name-name
          display_name = obj_name-display_name
          type         = type-objtype_tr
          sub_type     = type-subtype_wb ).
    ENDCASE.
  ENDMETHOD.

  METHOD get_full_type.
    CASE external_type.

      WHEN zif_dutils_c_tadir_type=>table OR
           zif_dutils_c_object_type=>structure.
        result = VALUE #(
          objtype_tr = zif_dutils_c_tadir_type=>table
          subtype_wb = zcl_dutils_tabl_util=>get_table_wb_type( CONV #( display_name ) ) ).

      WHEN OTHERS.
        result = zcl_dutils_wb_object_util=>get_full_wb_object_type( CONV #( external_type ) ).

    ENDCASE.
  ENDMETHOD.

ENDCLASS.

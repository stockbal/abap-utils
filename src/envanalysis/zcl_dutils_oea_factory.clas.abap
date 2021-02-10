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
          zcx_dutils_oea_no_type.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS:
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
      source_objects = source_objects
      parallel       = parallel ).
  ENDMETHOD.

  METHOD create_source_object.
    DATA(obj_name) = zcl_dutils_wb_object_util=>determine_wb_obj_name(
      name          = name
      external_type = external_type ).

    DATA(type) = get_full_type(
      display_name  = obj_name-display_name
      external_type = external_type ).

    IF type-objtype_tr IS INITIAL.
      RAISE EXCEPTION TYPE zcx_dutils_oea_no_type.
    ENDIF.

    result = NEW zcl_dutils_oea_source_object(
      name          = obj_name-name
      display_name  = obj_name-display_name
      type          = type-objtype_tr
      sub_type      = type-subtype_wb
      external_type = external_type ).
  ENDMETHOD.

  METHOD create_used_object.
    DATA(obj_name) = zcl_dutils_wb_object_util=>determine_wb_obj_name(
      name          = CONV #( name )
      external_type = external_type ).

    DATA(type) = get_full_type(
      display_name  = obj_name-display_name
      external_type = external_type ).

    result = NEW zcl_dutils_oea_used_object(
      name         = CONV #( obj_name-name )
      display_name = CONV #( obj_name-display_name )
      type         = type-objtype_tr
      sub_type     = type-subtype_wb ).
  ENDMETHOD.

  METHOD get_full_type.
    CASE external_type.

      WHEN zif_dutils_c_tadir_type=>table OR
           zif_dutils_c_object_type=>structure.
        result = VALUE #(
          objtype_tr = zif_dutils_c_tadir_type=>table
          subtype_wb = zcl_dutils_ddic_readers=>get_table_reader( )->get_table_wb_type( CONV #( display_name ) ) ).

      WHEN OTHERS.
        result = zcl_dutils_wb_object_util=>get_full_wb_object_type( CONV #( external_type ) ).

    ENDCASE.
  ENDMETHOD.

ENDCLASS.

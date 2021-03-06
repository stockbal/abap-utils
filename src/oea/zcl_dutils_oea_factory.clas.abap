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
          enclosing_obj_name TYPE seu_objkey OPTIONAL
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
ENDCLASS.



CLASS zcl_dutils_oea_factory IMPLEMENTATION.

  METHOD create_analyzer.
    result = NEW zcl_dutils_oea_analyzer(
      description    = description
      source_objects = source_objects
      parallel       = parallel ).
  ENDMETHOD.

  METHOD create_source_object.
    DATA(wb_object) = zcl_dutils_wb_obj_srv_factory=>get_service( external_type )->get_wb_object(
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
        DATA(wb_object) = zcl_dutils_wb_obj_srv_factory=>get_service( external_type )->get_wb_object(
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

ENDCLASS.

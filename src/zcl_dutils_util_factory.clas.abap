"! <p class="shorttext synchronized" lang="en">Factory for utility classes</p>
CLASS zcl_dutils_util_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">Retrieves instance of Obj. Env. Analysis utils</p>
    CLASS-METHODS get_obj_env_utils
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_oea_utils.
    "! <p class="shorttext synchronized" lang="en">Retrieves instance of WB Object Util</p>
    CLASS-METHODS get_wb_object_util
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_wb_object_util.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA obj_env_utils TYPE REF TO zif_dutils_oea_utils.
    CLASS-DATA wb_obj_util TYPE REF TO zif_dutils_wb_object_util.
ENDCLASS.



CLASS zcl_dutils_util_factory IMPLEMENTATION.

  METHOD get_obj_env_utils.
    IF obj_env_utils IS INITIAL.
      obj_env_utils = NEW zcl_dutils_oea_utils( ).
    ENDIF.

    result = obj_env_utils.
  ENDMETHOD.

  METHOD get_wb_object_util.
    IF wb_obj_util IS INITIAL.
      wb_obj_util = NEW zcl_dutils_wb_object_util( ).
    ENDIF.

    result = wb_obj_util.
  ENDMETHOD.

ENDCLASS.

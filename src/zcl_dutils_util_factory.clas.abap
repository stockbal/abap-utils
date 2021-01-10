"! <p class="shorttext synchronized" lang="en">Factory for utility classes</p>
CLASS zcl_dutils_util_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! <p class="shorttext synchronized" lang="en">Retrieves instance for package access</p>
    CLASS-METHODS get_package_access
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_package_access.
    "! <p class="shorttext synchronized" lang="en">Retrieves instance for TADIR access</p>
    CLASS-METHODS get_tadir_access
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_tadir_access.
    "! <p class="shorttext synchronized" lang="en">Retrieves instance of Obj. Env. Analysis utils</p>
    CLASS-METHODS get_obj_env_utils
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_oea_utils.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA package_access TYPE REF TO zif_dutils_package_access.
    CLASS-DATA tadir_access TYPE REF TO zif_dutils_tadir_access.
    CLASS-DATA obj_env_utils TYPE REF TO zif_dutils_oea_utils.
ENDCLASS.



CLASS zcl_dutils_util_factory IMPLEMENTATION.

  METHOD get_package_access.
    IF package_access IS INITIAL.
      package_access = NEW zcl_dutils_package_access( ).
    ENDIF.

    result = package_access.
  ENDMETHOD.

  METHOD get_tadir_access.
    IF tadir_access IS INITIAL.
      tadir_access = NEW zcl_dutils_tadir_access( ).
    ENDIF.

    result = tadir_access.
  ENDMETHOD.

  METHOD get_obj_env_utils.
    IF obj_env_utils IS INITIAL.
      obj_env_utils = NEW zcl_dutils_oea_utils( ).
    ENDIF.

    result = obj_env_utils.
  ENDMETHOD.

ENDCLASS.

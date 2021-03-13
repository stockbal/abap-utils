"! <p class="shorttext synchronized" lang="en">Environment determination for BOBF objects</p>
CLASS zcl_dutils_oea_bobf_env_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_oea_env_service.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dutils_oea_bobf_env_srv IMPLEMENTATION.

  METHOD zif_dutils_oea_env_service~determine_used_objects.

  ENDMETHOD.

ENDCLASS.

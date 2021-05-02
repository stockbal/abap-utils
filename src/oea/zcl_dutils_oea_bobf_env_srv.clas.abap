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
    METHODS:
      find_actions,
      find_determinatations,
      find_validations,
      find_associations.
ENDCLASS.



CLASS zcl_dutils_oea_bobf_env_srv IMPLEMENTATION.


  METHOD zif_dutils_oea_env_service~determine_used_objects.

  ENDMETHOD.


  METHOD find_actions.

  ENDMETHOD.


  METHOD find_associations.

  ENDMETHOD.


  METHOD find_determinatations.

  ENDMETHOD.


  METHOD find_validations.

  ENDMETHOD.


ENDCLASS.

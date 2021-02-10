"! <p class="shorttext synchronized" lang="en">Factory for Object Environment Service</p>
CLASS zcl_dutils_oea_env_srv_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Creates Object environment service</p>
      create_env_service
        IMPORTING
          obj_type      TYPE trobjtype
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_oea_env_service.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DUTILS_OEA_ENV_SRV_FACTORY IMPLEMENTATION.

  METHOD create_env_service.
    CASE obj_type.

      WHEN zif_dutils_c_tadir_type=>business_object.
        result = NEW zcl_dutils_oea_bobf_env_srv( ).

      WHEN OTHERS.
        result = NEW zcl_dutils_oea_default_env_srv( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

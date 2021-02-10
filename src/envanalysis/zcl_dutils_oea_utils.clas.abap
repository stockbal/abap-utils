"! <p class="shorttext synchronized" lang="en">Utiltities for object environment analysis</p>
CLASS zcl_dutils_oea_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_oea_utils.

    CLASS-METHODS:
      get_instance
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_oea_utils.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      c_direct_usages TYPE i VALUE '1'.
    CLASS-DATA:
      instance TYPE REF TO zif_dutils_oea_utils.
ENDCLASS.


CLASS zcl_dutils_oea_utils IMPLEMENTATION.

  METHOD get_instance.
    IF instance IS INITIAL.
      instance = NEW zcl_dutils_oea_utils( ).
    ENDIF.

    result = instance.
  ENDMETHOD.

  METHOD zif_dutils_oea_utils~get_used_objects.
    DATA: env_tab TYPE STANDARD TABLE OF senvi.

    DATA(obj_type) = CONV seu_obj( object-type ).

    CALL FUNCTION 'REPOSITORY_ENVIRONMENT_ALL'
      EXPORTING
        obj_type        = obj_type
        object_name     = object-name
        deep            = c_direct_usages
        with_parameters = with_parameters
        aggregate_level = aggregate_level
      TABLES
        environment_tab = env_tab.

    used_objects = VALUE #(
      FOR env IN env_tab
      ( type             = env-type
        name             = env-object
        enclosing_object = env-encl_obj
        calling_object   = env-call_obj ) ).
  ENDMETHOD.

ENDCLASS.

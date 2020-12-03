"! <p class="shorttext synchronized" lang="en">Code Inspector</p>
CLASS zcl_dutils_code_inspector DEFINITION
  PUBLIC
  CREATE PRIVATE.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized" lang="en">Creates new CI Run</p>
    CLASS-METHODS create_run
      IMPORTING
        variant_name         TYPE sci_chkv
        object_set           TYPE zif_dutils_ci_run=>ty_ci_object_set OPTIONAL
        resolve_sub_packages TYPE abap_bool
        object_assignemnt    TYPE zif_dutils_ci_run=>ty_ci_object_assignment OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO zif_dutils_ci_run
      RAISING
        zcx_dutils_exception .
    CLASS-METHODS validate_check_variant
      IMPORTING
        check_variant_name TYPE sci_chkv
      RAISING
        zcx_dutils_exception .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dutils_code_inspector IMPLEMENTATION.


  METHOD create_run.
    DATA(ci_run) = NEW zcl_dutils_ci_run(
      variant_name         = variant_name
      object_set           = object_set
      resolve_sub_packages = resolve_sub_packages
      object_assignment    = object_assignemnt
    ).
    result = ci_run.
  ENDMETHOD.


  METHOD validate_check_variant.

    cl_ci_checkvariant=>get_ref(
      EXPORTING
        p_user                   = ''
        p_name                   = check_variant_name
      EXCEPTIONS
        chkv_not_exists          = 1
        missing_parameter        = 2
        OTHERS                   = 3 ).

    IF sy-subrc <> 0.
      zcx_dutils_exception=>raise( |No valid check variant { check_variant_name  }| ).
    ENDIF.

  ENDMETHOD.


ENDCLASS.

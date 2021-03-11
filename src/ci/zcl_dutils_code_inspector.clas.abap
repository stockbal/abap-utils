"! <p class="shorttext synchronized" lang="en">Code Inspector</p>
CLASS zcl_dutils_code_inspector DEFINITION
  PUBLIC
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Validates given check variant</p>
      validate_check_variant
        IMPORTING
          check_variant_name TYPE sci_chkv
        RAISING
          zcx_dutils_exception,
      "! <p class="shorttext synchronized" lang="en">Creates new CI Run</p>
      create_run
        IMPORTING
          variant_name         TYPE sci_chkv
          object_set           TYPE zif_dutils_ci_run=>ty_ci_object_set
          resolve_sub_packages TYPE abap_bool
          object_assignment    TYPE zif_dutils_ci_run=>ty_ci_object_assignment
        RETURNING
          VALUE(result)        TYPE REF TO zif_dutils_ci_run,
      "! <p class="shorttext synchronized" lang="en">Creates new CI Run Result View</p>
      create_run_result
        IMPORTING
          ci_run          TYPE REF TO zif_dutils_ci_run
          enable_adt_jump TYPE abap_bool
        RETURNING
          VALUE(result)   TYPE REF TO zif_dutils_ci_result_view.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dutils_code_inspector IMPLEMENTATION.

  METHOD create_run.
    result = NEW zcl_dutils_ci_run(
      variant_name         = variant_name
      object_set           = object_set
      resolve_sub_packages = resolve_sub_packages
      object_assignment    = object_assignment ).
  ENDMETHOD.

  METHOD create_run_result.
    result = NEW zcl_dutils_ci_result_view(
      ci_run          = ci_run
      enable_adt_jump = enable_adt_jump ).
  ENDMETHOD.

  METHOD validate_check_variant.

    cl_ci_checkvariant=>get_ref(
      EXPORTING
        p_user            = space
        p_name            = check_variant_name
      RECEIVING
        p_ref             = DATA(check_variant)
      EXCEPTIONS
        chkv_not_exists   = 1
        missing_parameter = 2
        OTHERS            = 3 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_dutils_exception
        EXPORTING
          text = |No valid check variant { check_variant_name  }|.
    ELSE. " validate if check variant can be used
      check_variant->verify(
        EXPORTING p_srcid    = VALUE #( )
        IMPORTING p_messages = DATA(verifition_msgs) ).

      ASSIGN verifition_msgs[ kind = 'E' ] TO FIELD-SYMBOL(<error_msg>).
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_dutils_exception
          EXPORTING
            text = CONV #( <error_msg>-text ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

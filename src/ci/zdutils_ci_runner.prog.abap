*&---------------------------------------------------------------------*
*& Report ZDUTILS_CI_RUNNER
*&---------------------------------------------------------------------*
*& Simple Report for running
*&---------------------------------------------------------------------*
REPORT zdutils_ci_runner.

TABLES: sci_dynp.

**********************************************************************
* Selection Screen
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE TEXT-b01.
PARAMETERS: p_civar TYPE sci_chkv DEFAULT 'SYNTAX_CHECK'.
SELECTION-SCREEN END OF BLOCK variant.


SELECTION-SCREEN BEGIN OF BLOCK object_assgnmt WITH FRAME TITLE TEXT-b02.

SELECT-OPTIONS:
  s_appco  FOR sci_dynp-o_tadir_a, " application component
  s_socomp FOR sci_dynp-o_tadir_c, " software component
  s_dellay FOR sci_dynp-o_tadir_t, " transport layer
  s_pack   FOR sci_dynp-o_tadir_p. " package
PARAMETERS: p_subp TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
SELECT-OPTIONS:
  s_srcsys FOR sci_dynp-o_tadir_s, " source System
  s_respon FOR sci_dynp-o_tadir_r. " responsible Person

SELECTION-SCREEN END OF BLOCK object_assgnmt.

SELECTION-SCREEN BEGIN OF BLOCK object_set WITH FRAME TITLE TEXT-b03.
SELECT-OPTIONS:
  s_clas FOR sci_dynp-o_clas MATCHCODE OBJECT seo_classes_interfaces, " Class/Interface
  s_fugr FOR sci_dynp-o_fugr, " Function group
  s_repo FOR sci_dynp-o_repo MATCHCODE OBJECT s_progname_with_description, " Report
  s_wdyn FOR sci_dynp-o_wdyn, " Web dynpro component
  s_ddic FOR sci_dynp-o_ddic, " DDIC Type
  s_ddty FOR sci_dynp-o_ddty. " Type Group

SELECTION-SCREEN END OF BLOCK object_set.

SELECTION-SCREEN BEGIN OF BLOCK additional WITH FRAME TITLE TEXT-b04.
PARAMETERS: p_adt TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK additional.
**********************************************************************


START-OF-SELECTION.
  TRY.
      zcl_dutils_code_inspector=>validate_check_variant( p_civar ).

      DATA(ci_run) = zcl_dutils_code_inspector=>create_run(
        variant_name          = p_civar
        resolve_sub_packages  = p_subp
        object_assignemnt     = VALUE #(
           package_range         = s_pack[]
           appl_comp_range       = s_appco[]
           software_comp_range   = s_socomp[]
           transport_layer_range = s_dellay[]
           responsible_range     = s_respon[]
           source_system_range   = s_srcsys[]
        )
        object_set            = VALUE #(
           class_range          = s_clas[]
           func_group_range     = s_fugr[]
           report_name_range    = s_repo[]
           wdyn_comp_name_range = s_wdyn[]
           ddic_type_range      = s_ddic[]
           type_group_range     = s_ddty[]
        )
      ).

      ci_run->run( ).

      IF ci_run->is_successful( ).
        MESSAGE |No Results collected| TYPE 'S'.
      ELSEIF sy-batch = abap_false.
        DATA(ci_result) = NEW zcl_dutils_ci_result_view(
          ci_run = ci_run
          enable_adt_jump = p_adt ).

        ci_result->show( ).
      ENDIF.
    CATCH zcx_dutils_exception INTO DATA(error).
      MESSAGE error->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

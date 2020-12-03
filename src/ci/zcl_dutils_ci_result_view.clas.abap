"! <p class="shorttext synchronized" lang="en">Code Inspector Result View</p>
CLASS zcl_dutils_ci_result_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">CONSTRUCTOR</p>
    METHODS constructor
      IMPORTING
        ci_run          TYPE REF TO zif_dutils_ci_run
        enable_adt_jump TYPE abap_bool.
    METHODS show.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_functions,
        refresh       TYPE ui_func VALUE 'REFRESH',
        all_results   TYPE ui_func VALUE 'ALLRESULTS',
        only_errors   TYPE ui_func VALUE 'ERRORS',
        only_warnings TYPE ui_func VALUE 'WARNINGS',
        only_infos    TYPE ui_func VALUE 'INFOS',
      END OF c_functions.

    CONSTANTS:
      BEGIN OF c_fields,
        kind            TYPE salv_de_column VALUE 'KIND',
        kind_icon       TYPE salv_de_column VALUE 'KIND_ICON',
        sub_object_type TYPE salv_de_column VALUE 'SOBJTYPE',
        sub_object_name TYPE salv_de_column VALUE 'SOBJNAME',
        text            TYPE salv_de_column VALUE 'TEXT',
        test            TYPE salv_de_column VALUE 'TEST',
        description     TYPE salv_de_column VALUE 'DESCRIPTION',
        sub_object_text TYPE salv_de_column VALUE 'SUB_OBJECT_TEXT',
      END OF c_fields.

    TYPES:
      BEGIN OF ty_ci_result,
        kind_icon       TYPE c LENGTH 40, " icon with tooltip
        objtype         TYPE scir_alvlist-objtype,
        objname         TYPE scir_alvlist-objname,
        sub_object_text TYPE c LENGTH 100,
        line            TYPE scir_alvlist-line,
        sobjtype        TYPE scir_alvlist-sobjtype,
        sobjname        TYPE scir_alvlist-sobjname,
        devclass        TYPE scir_alvlist-devclass,
        component       TYPE scir_alvlist-component,
        author          TYPE scir_alvlist-author,
        kind            TYPE scir_alvlist-kind,
        text            TYPE scir_alvlist-text,
        test            TYPE scir_alvlist-test,
        description     TYPE scir_alvlist-description,
      END OF ty_ci_result.

    DATA ci_result_alv TYPE REF TO cl_salv_table.
    DATA plain_results TYPE STANDARD TABLE OF ty_ci_result WITH EMPTY KEY.
    DATA ci_run TYPE REF TO zif_dutils_ci_run.
    DATA enable_adt_jump TYPE abap_bool.

    METHODS create_alv
      RAISING
        cx_salv_msg
        cx_salv_existing
        cx_salv_wrong_call.

    METHODS filter_by_kind
      IMPORTING
        kind TYPE sci_errty OPTIONAL.
    METHODS refresh_results.
    METHODS process_results.
    METHODS process_result
      CHANGING
        result TYPE ty_ci_result.
    METHODS navigate_to_result
      IMPORTING
        row TYPE i.
    METHODS on_user_command
        FOR EVENT added_function OF cl_salv_events
      IMPORTING
        e_salv_function.
    METHODS on_link_click
        FOR EVENT link_click OF cl_salv_events_table
      IMPORTING
        column
        row.
    METHODS on_double_click
        FOR EVENT double_click OF cl_salv_events_table
      IMPORTING
        column
        row.
ENDCLASS.



CLASS ZCL_DUTILS_CI_RESULT_VIEW IMPLEMENTATION.


  METHOD constructor.
    me->ci_run = ci_run.
    me->enable_adt_jump = enable_adt_jump.
    process_results( ).
  ENDMETHOD.


  METHOD create_alv.
    cl_salv_table=>factory(
      IMPORTING r_salv_table = ci_result_alv
      CHANGING  t_table      = plain_results
    ).

    DATA(cols) = ci_result_alv->get_columns( ).

    cols->set_optimize( ).

    LOOP AT cols->get( ) INTO DATA(col).

      CASE col-columnname.

        WHEN c_fields-sub_object_name OR
             c_fields-sub_object_type OR
             c_fields-kind OR
             c_fields-test.
          col-r_column->set_technical( ).

        WHEN c_fields-kind_icon.
          CAST cl_salv_column_table( col-r_column )->set_icon( ).
          col-r_column->set_short_text( space ).
          col-r_column->set_medium_text( space ).
          col-r_column->set_long_text( 'Kind' ).

        WHEN c_fields-sub_object_text.
          col-r_column->set_short_text( space ).
          col-r_column->set_medium_text( space ).
          col-r_column->set_long_text( 'Sub Object' ).


        WHEN c_fields-text.
          CAST cl_salv_column_table( col-r_column )->set_cell_type( if_salv_c_cell_type=>hotspot ).

      ENDCASE.

    ENDLOOP.

    DATA(disp_settings) = ci_result_alv->get_display_settings( ).
    disp_settings->set_list_header( 'Code Inspector - Results' ).

    DATA(functions) = ci_result_alv->get_functions( ).
    ci_result_alv->set_screen_status(
        report        = 'ZDUTILS_CI_RUNNER'
        pfstatus      = 'CI_RESULTS'
        set_functions = cl_salv_table=>c_functions_all
    ).

    DATA(events) = ci_result_alv->get_event( ).
    SET HANDLER:
      on_user_command FOR events,
      on_link_click FOR events,
      on_double_click FOR events.

    ci_result_alv->display( ).
  ENDMETHOD.


  METHOD filter_by_kind.
    DATA: kind_filter TYPE REF TO cl_salv_filter.

    CHECK ci_result_alv IS BOUND.

    DATA(filters) = ci_result_alv->get_filters( ).

    IF kind IS INITIAL.
      filters->remove_filter( c_fields-kind ).
    ELSE.
      TRY.
          kind_filter = filters->get_filter( c_fields-kind ).
          IF kind_filter IS BOUND.
            DATA(filter_selopt) = kind_filter->get( ).
            IF filter_selopt IS NOT INITIAL.
              filter_selopt[ 1 ]->set_low( CONV #( kind ) ).
            ENDIF.
          ENDIF.
        CATCH cx_salv_not_found.
          TRY.
              filters->add_filter( columnname = c_fields-kind
                                   low        = CONV #( kind ) ).
            CATCH cx_salv_data_error
                  cx_salv_not_found
                  cx_salv_existing INTO DATA(salv_error).
          ENDTRY.
      ENDTRY.
    ENDIF.

    ci_result_alv->refresh( s_stable     = VALUE #( row = abap_true col = abap_true )
                            refresh_mode = if_salv_c_refresh=>full ).

  ENDMETHOD.


  METHOD navigate_to_result.

    ASSIGN plain_results[ row ] TO FIELD-SYMBOL(<result>).
    CHECK sy-subrc = 0.

    TRY.
        IF enable_adt_jump = abap_true.

          zcl_dutils_adt_obj_util=>jump_adt( object_name     = <result>-objname
                                             object_type     = <result>-objtype
                                             sub_object_name = <result>-sobjname
                                             sub_object_type = <result>-sobjtype
                                             line_number     = CONV #( <result>-line ) ).
          RETURN.

        ENDIF.
      CATCH zcx_dutils_exception.
    ENDTRY.

    DATA(test_ref) = cl_ci_tests=>get_test_ref( <result>-test ).

    DATA(test_result_node) = test_ref->get_result_node( <result>-kind ).
    DATA(test_info) = CORRESPONDING scir_rest( <result> ).

    test_result_node->set_info( test_info ).
    test_result_node->if_ci_test~navigate( ).
  ENDMETHOD.


  METHOD on_double_click.
    navigate_to_result( row ).
  ENDMETHOD.


  METHOD on_link_click.
    navigate_to_result( row ).
  ENDMETHOD.


  METHOD on_user_command.

    CASE e_salv_function.

      WHEN c_functions-refresh.
        refresh_results( ).

      WHEN c_functions-all_results.
        filter_by_kind( ).

      WHEN c_functions-only_errors.
        filter_by_kind( 'E' ).

      WHEN c_functions-only_warnings.
        filter_by_kind( 'W' ).

      WHEN c_functions-only_infos.
        filter_by_kind( 'N' ).
    ENDCASE.

  ENDMETHOD.


  METHOD process_result.

    DATA: lv_class  TYPE string.

    CASE result-kind.
      WHEN 'E'.
        lv_class = 'ci-error'.
        result-kind_icon = |@{ icon_led_red+1(2) }\\QError@|.
      WHEN 'W'.
        result-kind_icon = |@{ icon_led_yellow+1(2) }\\QWarning@|.
      WHEN OTHERS.
        result-kind_icon = |@{ icon_led_green+1(2) }\\QInfo@|.
    ENDCASE.

    IF result-objtype = 'CLAS' OR
       ( result-objtype = 'PROG' AND NOT result-sobjname+30(*) IS INITIAL ).
      TRY.
          CASE result-sobjname+30(*).
            WHEN seop_incextapp_definition.
              result-sub_object_text = |Local Definitions|.
            WHEN seop_incextapp_implementation.
              result-sub_object_text = |Local Implementations|.
            WHEN seop_incextapp_macros.
              result-sub_object_text = |Macros|.
            WHEN seop_incextapp_testclasses.
              result-sub_object_text = |Test Classes|.
            WHEN 'CU'.
              result-sub_object_text = |Public Section|.
            WHEN 'CO'.
              result-sub_object_text = |Protected Section|.
            WHEN 'CI'.
              result-sub_object_text = |Private Section|.
            WHEN OTHERS.
              cl_oo_classname_service=>get_method_by_include(
                EXPORTING
                  incname             = result-sobjname
                RECEIVING
                  mtdkey              = DATA(method_key)
                EXCEPTIONS
                  class_not_existing  = 1
                  method_not_existing = 2
                  OTHERS              = 3 ).
              IF sy-subrc = 0.
                result-sub_object_text = |Method { method_key-cpdname }|.
              ENDIF.

          ENDCASE.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD process_results.
    plain_results = CORRESPONDING #( ci_run->get_results( ) ).

    LOOP AT plain_results ASSIGNING FIELD-SYMBOL(<result>).
      process_result( CHANGING result = <result> ).
    ENDLOOP.

  ENDMETHOD.


  METHOD refresh_results.
    ci_run->run( ).
    process_results( ).

    ci_result_alv->refresh( s_stable = VALUE #( col = abap_true row = abap_true ) ).
  ENDMETHOD.


  METHOD show.
    TRY.
        create_alv( ).
      CATCH cx_salv_msg cx_salv_existing cx_salv_wrong_call.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_parallel_analyzer DEFINITION.

  PUBLIC SECTION.
    METHODS:
      "! Creates new parallel processor
      constructor
        IMPORTING
          group_name TYPE rzlli_apcl OPTIONAL,
      "! Returns 'X' if there are enough tasks
      has_enough_tasks
        RETURNING
          VALUE(result) TYPE abap_bool,
      "! Runs parallel environment analysis
      run
        IMPORTING
          analysis_id   TYPE sysuuid_x16
          task_name     TYPE zif_dutils_ty_global=>ty_task_name
          source_object TYPE REF TO zif_dutils_oea_source_object,
      wait_until_free_task,
      wait_until_finished,
      on_end_of_task
        IMPORTING
          p_task TYPE clike.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      free_tasks  TYPE i,
      group       TYPE rzlli_apcl,
      max_tasks   TYPE i,
      initialized TYPE abap_bool.
ENDCLASS.

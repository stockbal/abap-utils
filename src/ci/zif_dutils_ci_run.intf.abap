"! <p class="shorttext synchronized" lang="en">Code Inspector Run</p>
INTERFACE zif_dutils_ci_run
  PUBLIC .
  TYPES:
    "! <p class="shorttext synchronized" lang="en">Run mode for CI</p>
    ty_run_mode TYPE c LENGTH 1,
    "! <p class="shorttext synchronized" lang="en">Object Set for CI</p>
    BEGIN OF ty_ci_object_set,
      class_range          TYPE zif_dutils_ty_global=>ty_class_intf_range,
      func_group_range     TYPE zif_dutils_ty_global=>ty_func_group_name_range,
      report_name_range    TYPE zif_dutils_ty_global=>ty_report_name_range,
      wdyn_comp_name_range TYPE zif_dutils_ty_global=>ty_wdyn_comp_name_range,
      ddic_type_range      TYPE zif_dutils_ty_global=>ty_ddic_type_range,
      type_group_range     TYPE zif_dutils_ty_global=>ty_type_group_range,
    END OF ty_ci_object_set,
    "! <p class="shorttext synchronized" lang="en">Object Assignments for CI</p>
    BEGIN OF ty_ci_object_assignment,
      package_range         TYPE zif_dutils_ty_global=>ty_package_name_range,
      appl_comp_range       TYPE zif_dutils_ty_global=>ty_appl_comp_range,
      software_comp_range   TYPE zif_dutils_ty_global=>ty_software_comp_range,
      transport_layer_range TYPE zif_dutils_ty_global=>ty_transport_layer_range,
      source_system_range   TYPE zif_dutils_ty_global=>ty_source_system_range,
      responsible_range     TYPE zif_dutils_ty_global=>ty_responsible_person_range,
    END OF ty_ci_object_assignment.

  CONSTANTS:
    "! <p class="shorttext synchronized" lang="en">Run modes for CI</p>
    BEGIN OF c_run_mode,
      run_in_batch     TYPE ty_run_mode VALUE 'B',
      run_loc_parallel TYPE ty_run_mode VALUE 'L',
    END OF c_run_mode .

  "! <p class="shorttext synchronized" lang="en">Runs Code Inspection</p>
  METHODS run
    RAISING
      zcx_dutils_exception.

  "! <p class="shorttext synchronized" lang="en">Returns 'X' if inspection successful</p>
  METHODS is_successful
    RETURNING
      VALUE(result) TYPE abap_bool .

  "! <p class="shorttext synchronized" lang="en">Performs Re-Run of current Inspection</p>
  METHODS get_results
    RETURNING
      VALUE(results) TYPE scit_alvlist.

  "! <p class="shorttext synchronized" lang="en">Resturns 'X' if there are results</p>
  "! Optional restriction of query is possible via the parameter IV_KIND, e.g. if only Results of type 'E'
  "! are relevant, you should supply the parameter with the value 'E'.
  "!
  METHODS has_results
    IMPORTING
      kind          TYPE sci_errty OPTIONAL
    RETURNING
      VALUE(result) TYPE abap_bool.

  "! <p class="shorttext synchronized" lang="en">Returns duration of inspection run</p>
  METHODS get_duration
    RETURNING
      VALUE(result) TYPE i.

ENDINTERFACE.

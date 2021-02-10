"! <p class="shorttext synchronized" lang="en">Utiltities for object environment analysis</p>
INTERFACE zif_dutils_oea_utils
  PUBLIC .

  METHODS:
    "! <p class="shorttext synchronized" lang="en">Determine used objects for the given object</p>
    "! @parameter object | Object that should be analyzed
    "! @parameter aggregate_level | Level of aggregation that should be performed
    "! @parameter with_parameters | if 'X' parameters of methods and function modules are also analyzed
    get_used_objects
      IMPORTING
        object              TYPE zif_dutils_ty_global=>ty_tadir_object
        aggregate_level     TYPE zif_dutils_ty_oea=>ty_aggregation_level DEFAULT zif_dutils_c_oea=>c_aggregation_level-by_type
        with_parameters     TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(used_objects) TYPE zif_dutils_ty_oea=>ty_used_objects.
ENDINTERFACE.

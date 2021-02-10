"! <p class="shorttext synchronized" lang="en">Object Environment service</p>
INTERFACE zif_dutils_oea_env_service
  PUBLIC .

  METHODS:
    "! <p class="shorttext synchronized" lang="en">Determine used objects for the given object</p>
    "! @parameter object | Object that should be analyzed
    "! @parameter result | The determined used objects for the given source object
    determine_used_objects
      IMPORTING
        object        TYPE zif_dutils_ty_global=>ty_tadir_object
      RETURNING
        VALUE(result) TYPE zif_dutils_oea_used_object=>ty_table.
ENDINTERFACE.

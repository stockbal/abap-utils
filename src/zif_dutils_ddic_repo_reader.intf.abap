"! <p class="shorttext synchronized" lang="en">Access to TADIR Table</p>
INTERFACE zif_dutils_ddic_repo_reader
  PUBLIC .
  "! <p class="shorttext synchronized" lang="en">Read Repository objects by package</p>
  METHODS read_by_package
    IMPORTING
      package_name        TYPE devclass
      resolve_subpackages TYPE abap_bool OPTIONAL
    RETURNING
      VALUE(result)       TYPE zif_dutils_ty_oea=>ty_objects.
ENDINTERFACE.

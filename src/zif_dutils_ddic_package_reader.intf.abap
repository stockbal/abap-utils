"! <p class="shorttext synchronized" lang="en">Package Utility</p>
INTERFACE zif_dutils_ddic_package_reader
  PUBLIC .
  "! <p class="shorttext synchronized" lang="en">Resolves full package names from Range Table</p>
  METHODS resolve_packages
    IMPORTING
      package_range TYPE zif_dutils_ty_global=>ty_package_name_range
    RETURNING
      VALUE(result) TYPE zif_dutils_ty_global=>ty_package_name_range.
  "! <p class="shorttext synchronized" lang="en">Retrieves sub packages by range</p>
  METHODS get_subpackages_by_range
    IMPORTING
      package_range TYPE zif_dutils_ty_global=>ty_package_name_range
    RETURNING
      value(result) TYPE zif_dutils_ty_global=>ty_package_name_range.
  "! <p class="shorttext synchronized" lang="en">Retrieves sub packages by tab</p>
  METHODS get_subpackages_by_tab
    IMPORTING
      package_names TYPE zif_dutils_ty_global=>ty_package_names
    RETURNING
      value(result) TYPE zif_dutils_ty_global=>ty_package_name_range.
  "! <p class="shorttext synchronized" lang="en">Retrieves sub packages for top package</p>
  METHODS get_subpackages
    IMPORTING
      package_name  TYPE devclass
    RETURNING
      value(result) TYPE zif_dutils_ty_global=>ty_package_name_range.
ENDINTERFACE.

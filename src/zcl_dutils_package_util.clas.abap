"! <p class="shorttext synchronized" lang="en">Package Utility</p>
CLASS zcl_dutils_package_util DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">Resolves full package names from Range Table</p>
    CLASS-METHODS resolve_packages
      IMPORTING
        package_range TYPE zif_dutils_ty_global=>ty_package_name_range
      RETURNING
        VALUE(result) TYPE zif_dutils_ty_global=>ty_package_names.
    "! <p class="shorttext synchronized" lang="en">Retrieves sub packages by range</p>
    CLASS-METHODS get_subpackages_by_range
      IMPORTING
        package_range TYPE zif_dutils_ty_global=>ty_package_name_range
      RETURNING
        VALUE(result) TYPE zif_dutils_ty_global=>ty_package_names.
    "! <p class="shorttext synchronized" lang="en">Retrieves sub packages by tab</p>
    CLASS-METHODS get_subpackages_by_tab
      IMPORTING
        package_names TYPE zif_dutils_ty_global=>ty_package_names
      RETURNING
        VALUE(result) TYPE zif_dutils_ty_global=>ty_package_names.
    "! <p class="shorttext synchronized" lang="en">Retrieves sub packages for top package</p>
    CLASS-METHODS get_subpackages
      IMPORTING
        package_name  TYPE devclass
      RETURNING
        VALUE(result) TYPE zif_dutils_ty_global=>ty_package_names.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS list_sub_packages
      IMPORTING
        package_range TYPE zif_dutils_ty_global=>ty_package_name_range
      RETURNING
        VALUE(result) TYPE zif_dutils_ty_global=>ty_package_names.
ENDCLASS.



CLASS zcl_dutils_package_util IMPLEMENTATION.

  METHOD resolve_packages.
    CHECK package_range IS NOT INITIAL.

    SELECT devclass
      FROM tdevc
      WHERE devclass IN @package_range
    INTO TABLE @result.
  ENDMETHOD.

  METHOD get_subpackages_by_range.
    result = list_sub_packages( package_range  ).
  ENDMETHOD.

  METHOD get_subpackages.
    result = list_sub_packages( VALUE #( ( sign = 'I' option = 'EQ' low = to_upper( package_name ) ) ) ).
  ENDMETHOD.

  METHOD list_sub_packages.
    DATA: package_names TYPE zif_dutils_ty_global=>ty_package_names.

    CHECK package_range IS NOT INITIAL.

    SELECT devclass
      FROM tdevc
      WHERE parentcl IN @package_range
    INTO TABLE @package_names.

    result = package_names.

    WHILE lines( package_names ) > 0.
      SELECT devclass
        FROM tdevc
        FOR ALL ENTRIES IN @package_names
        WHERE parentcl = @package_names-table_line
      INTO TABLE @package_names.

      result = VALUE #( BASE result ( LINES OF package_names ) ).
    ENDWHILE.
  ENDMETHOD.

  METHOD get_subpackages_by_tab.
    result = list_sub_packages(
      VALUE #(
        FOR pack IN package_names
        ( sign   = 'I'
          option = 'EQ'
          low    = pack ) ) ).
  ENDMETHOD.

ENDCLASS.

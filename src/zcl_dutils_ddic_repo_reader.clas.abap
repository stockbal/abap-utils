"! <p class="shorttext synchronized" lang="en">Access to TADIR Table</p>
CLASS zcl_dutils_ddic_repo_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_dutils_ddic_repo_reader.

    METHODS constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      package_reader TYPE REF TO zif_dutils_ddic_package_reader.
ENDCLASS.



CLASS zcl_dutils_ddic_repo_reader IMPLEMENTATION.

  METHOD constructor.
    me->package_reader = zcl_dutils_ddic_reader_factory=>get_package_reader( ).
  ENDMETHOD.

  METHOD zif_dutils_ddic_repo_reader~read_by_package.
    DATA: packages TYPE RANGE OF devclass.

    packages = VALUE #( ( sign = 'I' option = 'EQ' low = to_upper( package_name ) ) ).

    IF resolve_subpackages = abap_true.
      packages = VALUE #(
        BASE packages
        ( LINES OF me->package_reader->get_subpackages( package_name ) ) ).
    ENDIF.

    SELECT object AS type,
           obj_name AS name,
           devclass AS package
      FROM tadir
      WHERE devclass IN @packages
    INTO CORRESPONDING FIELDS OF TABLE @result.

  ENDMETHOD.

ENDCLASS.

"! <p class="shorttext synchronized" lang="en">Factory for DDIC Reader classes</p>
CLASS zcl_dutils_ddic_reader_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">Retrieves instance to Repository Reader</p>
    CLASS-METHODS get_repo_reader
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_ddic_repo_reader.
    "! <p class="shorttext synchronized" lang="en">Retrieves instance to table reader</p>
    CLASS-METHODS get_table_reader
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_ddic_table_reader.
    "! <p class="shorttext synchronized" lang="en">Retrieves instance to package reader</p>
    CLASS-METHODS get_package_reader
      RETURNING
        VALUE(result) TYPE REF TO zif_dutils_ddic_package_reader.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      package_reader TYPE REF TO zif_dutils_ddic_package_reader,
      repo_reader    TYPE REF TO zif_dutils_ddic_repo_reader,
      table_reader   TYPE REF TO zif_dutils_ddic_table_reader.
ENDCLASS.



CLASS zcl_dutils_ddic_reader_factory IMPLEMENTATION.

  METHOD get_package_reader.
    IF package_reader IS INITIAL.
      package_reader = NEW zcl_dutils_ddic_package_reader( ).
    ENDIF.

    result = package_reader.
  ENDMETHOD.

  METHOD get_repo_reader.
    IF repo_reader IS INITIAL.
      repo_reader = NEW zcl_dutils_ddic_repo_reader( ).
    ENDIF.

    result = repo_reader.
  ENDMETHOD.

  METHOD get_table_reader.
    IF table_reader IS INITIAL.
      table_reader = NEW zcl_dutils_ddic_table_reader( ).
    ENDIF.

    result = table_reader.
  ENDMETHOD.

ENDCLASS.

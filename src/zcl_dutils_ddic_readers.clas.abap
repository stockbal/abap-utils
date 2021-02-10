"! <p class="shorttext synchronized" lang="en">Factory for DDIC Reader classes</p>
CLASS zcl_dutils_ddic_readers DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Creates instance of Repository Reader</p>
      create_repo_reader
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_ddic_repo_reader,
      "! <p class="shorttext synchronized" lang="en">Retrieves instance to table reader</p>
      get_table_reader
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_ddic_table_reader,
      "! <p class="shorttext synchronized" lang="en">Retrieves instance to package reader</p>
      get_package_reader
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_ddic_package_reader.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      package_reader TYPE REF TO zif_dutils_ddic_package_reader,
      table_reader   TYPE REF TO zif_dutils_ddic_table_reader.
ENDCLASS.



CLASS zcl_dutils_ddic_readers IMPLEMENTATION.

  METHOD get_package_reader.
    IF package_reader IS INITIAL.
      package_reader = NEW zcl_dutils_ddic_package_reader( ).
    ENDIF.

    result = package_reader.
  ENDMETHOD.

  METHOD create_repo_reader.
    result = new zcl_dutils_ddic_repo_reader( ).
  ENDMETHOD.

  METHOD get_table_reader.
    IF table_reader IS INITIAL.
      table_reader = NEW zcl_dutils_ddic_table_reader( ).
    ENDIF.

    result = table_reader.
  ENDMETHOD.

ENDCLASS.

"! <p class="shorttext synchronized" lang="en">Factory for DDIC Reader classes</p>
CLASS zcl_dutils_reader_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Retrieves instance to package reader</p>
      get_package_reader
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_devc_reader.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      package_reader TYPE REF TO zif_dutils_devc_reader.
ENDCLASS.



CLASS zcl_dutils_reader_factory IMPLEMENTATION.


  METHOD get_package_reader.
    IF package_reader IS INITIAL.
      package_reader = NEW zcl_dutils_devc_reader( ).
    ENDIF.

    result = package_reader.
  ENDMETHOD.


ENDCLASS.

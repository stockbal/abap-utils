"! <p class="shorttext synchronized" lang="en">No object type could be determined</p>
CLASS zcx_dutils_oea_no_type DEFINITION
  PUBLIC
  INHERITING FROM zcx_dutils_exception
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      "! <p class="shorttext synchronized" lang="en">CONSTRUCTOR</p>
      constructor
        IMPORTING
          !previous LIKE previous OPTIONAL
          !text     TYPE string OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_dutils_oea_no_type IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous
        text     = text.
  ENDMETHOD.

ENDCLASS.

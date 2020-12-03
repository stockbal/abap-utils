"! <p class="shorttext synchronized" lang="en">General Exception</p>
CLASS zcx_dutils_exception DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .

    "! <p class="shorttext synchronized" lang="en">CONSTRUCTOR</p>
    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !msgv1    TYPE sy-msgv1 OPTIONAL
        !msgv2    TYPE sy-msgv2 OPTIONAL
        !msgv3    TYPE sy-msgv3 OPTIONAL
        !msgv4    TYPE sy-msgv4 OPTIONAL .

    DATA msgv1 TYPE sy-msgv1 .
    DATA msgv2 TYPE sy-msgv2 .
    DATA msgv3 TYPE sy-msgv3 .
    DATA msgv4 TYPE sy-msgv4 .

    "! <p class="shorttext synchronized" lang="en">Raises Error with given text</p>
    CLASS-METHODS raise
      IMPORTING
        text     TYPE string
        previous TYPE REF TO cx_root OPTIONAL
      RAISING
        zcx_dutils_exception.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS split_string_to_symsg
      IMPORTING
        text TYPE string.
ENDCLASS.



CLASS zcx_dutils_exception IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    me->msgv1 = msgv1 .
    me->msgv2 = msgv2 .
    me->msgv3 = msgv3 .
    me->msgv4 = msgv4 .
    CLEAR me->textid.

    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

  METHOD raise.
    split_string_to_symsg( text ).

    RAISE EXCEPTION TYPE zcx_dutils_exception
      EXPORTING
        textid   = VALUE #(
          msgid = sy-msgid
          msgno = sy-msgno
          attr1 = 'MSGV1'
          attr2 = 'MSGV2'
          attr3 = 'MSGV3'
          attr4 = 'MSGV4'
        )
        previous = previous
        msgv1    = sy-msgv1
        msgv2    = sy-msgv2
        msgv3    = sy-msgv3
        msgv4    = sy-msgv4.
  ENDMETHOD.

  METHOD split_string_to_symsg.

    DATA: offset TYPE i.

    DATA(rest_text) = text.

    DATA(msgv1) = rest_text.
    SHIFT rest_text LEFT BY 50 PLACES.
    DATA(msgv2) = rest_text.
    SHIFT rest_text LEFT BY 50 PLACES.
    DATA(msgv3) = rest_text.
    SHIFT rest_text LEFT BY 50 PLACES.
    DATA(msgv4) = rest_text.

    IF strlen( rest_text ) > 50.
      FIND ALL OCCURRENCES OF REGEX '.\s.' IN SECTION LENGTH 47 OF msgv4 MATCH OFFSET offset.
      IF sy-subrc = 0.
        offset = offset + 1.
        msgv4 = msgv4(offset).

        msgv4 = |{ msgv4 }...|.
      ENDIF.
    ENDIF.

    MESSAGE e001(00) WITH msgv1 msgv2 msgv3 msgv4 INTO DATA(msg).
  ENDMETHOD.

ENDCLASS.

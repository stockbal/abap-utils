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
        text      TYPE string OPTIONAL
        !msgv1    TYPE sy-msgv1 OPTIONAL
        !msgv2    TYPE sy-msgv2 OPTIONAL
        !msgv3    TYPE sy-msgv3 OPTIONAL
        !msgv4    TYPE sy-msgv4 OPTIONAL .

    DATA msgv1 TYPE sy-msgv1 .
    DATA msgv2 TYPE sy-msgv2 .
    DATA msgv3 TYPE sy-msgv3 .
    DATA msgv4 TYPE sy-msgv4 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_dutils_exception IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    CLEAR me->textid.

    IF text IS NOT INITIAL.
      zcl_dutils_message_util=>split_string_to_symsg( text ).

      if_t100_message~t100key = VALUE #(
        msgid = sy-msgid
        msgno = sy-msgno
        attr1 = 'MSGV1'
        attr2 = 'MSGV2'
        attr3 = 'MSGV3'
        attr4 = 'MSGV4'
      ).
      me->previous = previous.
      me->msgv1    = sy-msgv1.
      me->msgv2    = sy-msgv2.
      me->msgv3    = sy-msgv3.
      me->msgv4    = sy-msgv4.
    ELSE.
      me->msgv1 = msgv1 .
      me->msgv2 = msgv2 .
      me->msgv3 = msgv3 .
      me->msgv4 = msgv4 .


      IF textid IS INITIAL.
        if_t100_message~t100key = if_t100_message=>default_textid.
      ELSE.
        if_t100_message~t100key = textid.
      ENDIF.
    ENDIF.

  ENDMETHOD.



ENDCLASS.

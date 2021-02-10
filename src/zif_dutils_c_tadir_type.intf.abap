"! <p class="shorttext synchronized" lang="en">Object types in TADIR</p>
INTERFACE zif_dutils_c_tadir_type
  PUBLIC .

  CONSTANTS:
    table           TYPE trobjtype VALUE 'TABL' ##NO_TEXT,
    function_group  TYPE trobjtype VALUE 'FUGR' ##NO_TEXT,
    program         TYPE trobjtype VALUE 'PROG' ##NO_TEXT,
    package         TYPE trobjtype VALUE 'DEVC' ##NO_TEXT,
    business_object TYPE trobjtype VALUE 'BOBF' ##NO_TEXT.
ENDINTERFACE.

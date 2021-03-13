"! <p class="shorttext synchronized" lang="en">Parallel execution of object environment analyzer</p>
INTERFACE zif_dutils_oea_analyzer_par
  PUBLIC .

  METHODS:
    "! <p class="shorttext synchronized" lang="en">Runs parallel Analysis</p>
    run
      IMPORTING
        source_objects TYPE zif_dutils_ty_global=>ty_tadir_objects.
ENDINTERFACE.

"! <p class="shorttext synchronized" lang="en">Object Environment Analyzer</p>
INTERFACE zif_dutils_oea_analyzer
  PUBLIC .

  METHODS:
    "! <p class="shorttext synchronized" lang="en">Runs Analysis</p>
    run
      RAISING
        zcx_dutils_exception,

    "! <p class="shorttext synchronized" lang="en">Returns the result of the analysis</p>
    "!
    "! @parameter result | Result of object analysis
    get_result
      RETURNING
        VALUE(result) TYPE zif_dutils_ty_oea=>ty_used_objects,

    "! <p class="shorttext synchronized" lang="en">Returns duration of analysis</p>
    get_duration
      RETURNING
        VALUE(result) TYPE timestampl.
ENDINTERFACE.

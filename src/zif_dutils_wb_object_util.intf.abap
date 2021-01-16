"! <p class="shorttext synchronized" lang="en">WB Object Utility</p>
INTERFACE zif_dutils_wb_object_util
  PUBLIC .
  "! <p class="shorttext synchronized" lang="en">Resolve Include to WB object</p>
  "! Resolves a given Include to a workbench object<br/>
  "! Possible values are:
  "! <ul>
  "! <li>FUGR/I - Function Group Include</li>
  "! <li>FUGR/FF - Function Module</li>
  "! <li>PROG/I - Program Include
  "! </ul>
  METHODS resolve_include_to_wb_object
    IMPORTING
      include_name     TYPE progname
    RETURNING
      VALUE(wb_object) TYPE zif_dutils_ty_oea=>ty_wb_object.

  "! <p class="shorttext synchronized" lang="en">Retrieves full workbench type for given type</p>
  METHODS get_full_wb_object_type
    IMPORTING
      type          TYPE seu_obj
    RETURNING
      VALUE(result) TYPE wbobjtype.

ENDINTERFACE.

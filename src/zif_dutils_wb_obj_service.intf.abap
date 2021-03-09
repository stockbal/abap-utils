"! <p class="shorttext synchronized" lang="en">Service for WB Object functions</p>
INTERFACE zif_dutils_wb_obj_service
  PUBLIC.
  METHODS:
    "! <p class="shorttext synchronized" lang="en">Retrieves WB Object data</p>
    get_wb_object
      IMPORTING
        display_name  TYPE sobj_name
        external_type TYPE trobjtype
      RETURNING
        VALUE(result) TYPE zif_dutils_ty_global=>ty_wb_object
      RAISING
        zcx_dutils_not_exists
        zcx_dutils_no_wb_type.
ENDINTERFACE.

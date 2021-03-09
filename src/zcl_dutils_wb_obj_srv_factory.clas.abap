"! <p class="shorttext synchronized" lang="en">Factory which creates WB Object service</p>
CLASS zcl_dutils_wb_obj_srv_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Retrieves service for type</p>
      get_service
        IMPORTING
          type          TYPE trobjtype
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_wb_obj_service.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_services,
        type    TYPE trobjtype,
        service TYPE REF TO zif_dutils_wb_obj_service,
      END OF ty_services.

    CLASS-DATA:
      services TYPE HASHED TABLE OF ty_services WITH UNIQUE KEY type.
ENDCLASS.



CLASS zcl_dutils_wb_obj_srv_factory IMPLEMENTATION.

  METHOD get_service.
    TRY.
        result = services[ type = type ]-service.
      CATCH cx_sy_itab_line_not_found.
        CASE type.

          WHEN zif_dutils_c_tadir_type=>icf_node.
            result = NEW zcl_dutils_wb_obj_sicf_srv( ).

          WHEN zif_dutils_c_tadir_type=>table OR
                zif_dutils_c_object_type=>structure.
            result = NEW zcl_dutils_wb_obj_tabl_srv( ).

          WHEN zif_dutils_c_object_type=>include.
            result = NEW zcl_dutils_wb_obj_incl_srv( ).

          WHEN zif_dutils_c_object_type=>function_module.
            result = NEW zcl_dutils_wb_obj_func_srv( ).

          WHEN OTHERS.
            result = NEW zcl_dutils_wb_obj_default_srv( ).

        ENDCASE.

        IF type = zif_dutils_c_tadir_type=>table OR
            type = zif_dutils_c_object_type=>structure.
          INSERT VALUE #( type = zif_dutils_c_tadir_type=>table service = result ) INTO TABLE services.
          INSERT VALUE #( type = zif_dutils_c_object_type=>structure service = result ) INTO TABLE services.
        ELSE.
          INSERT VALUE #( type = type service = result ) INTO TABLE services.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

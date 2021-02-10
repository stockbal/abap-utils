"! <p class="shorttext synchronized" lang="en">Default Environment determination</p>
CLASS zcl_dutils_oea_default_env_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_oea_env_service.

    METHODS:
      constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_dutils_oea_default_env_srv IMPLEMENTATION.

  METHOD constructor.
  ENDMETHOD.

  METHOD zif_dutils_oea_env_service~determine_used_objects.
    DATA(used_objects_data) = zcl_dutils_oea_utils=>get_used_objects(
      object          = object
      with_parameters = abap_true ).

    LOOP AT used_objects_data ASSIGNING FIELD-SYMBOL(<used_object_data>).
      " discard of objects that are not needed
      IF <used_object_data>-type = zif_dutils_c_object_type=>single_message OR
         strlen( <used_object_data>-type ) < 4.
        CONTINUE.
      ENDIF.

      result = VALUE #(
        BASE result
        ( zcl_dutils_oea_factory=>create_used_object(
            name               = <used_object_data>-name
            external_type      = CONV #( <used_object_data>-type )
            enclosing_obj_name = CONV #( <used_object_data>-enclosing_object ) ) ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

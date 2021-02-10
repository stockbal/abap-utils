"! <p class="shorttext synchronized" lang="en">Source Object for which OEA was triggered</p>
CLASS zcl_dutils_oea_source_object DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_oea_source_object.

    METHODS:
      constructor
        IMPORTING
          name          TYPE sobj_name
          display_name  TYPE sobj_name
          type          TYPE trobjtype
          sub_type      TYPE seu_objtyp
          external_type TYPE trobjtype.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      used_objects  TYPE zif_dutils_oea_used_object=>ty_table,
      env_service   TYPE REF TO zif_dutils_oea_env_service,
      id            TYPE sysuuid_x16,
      parent_ref    TYPE sysuuid_x16,
      external_type TYPE trobjtype,
      type          TYPE trobjtype,
      sub_type      TYPE seu_objtyp,
      name          TYPE sobj_name,
      display_name  TYPE seu_objkey,
      generated     TYPE abap_bool,
      processing    TYPE abap_bool.

    METHODS:
      get_env_service
        RETURNING
          VALUE(result) TYPE REF TO zif_dutils_oea_env_service.
ENDCLASS.



CLASS zcl_dutils_oea_source_object IMPLEMENTATION.

  METHOD constructor.
    me->name = name.
    me->display_name = display_name.
    me->external_type = external_type.
    me->sub_type = sub_type.
    me->type = type.
    me->id = zcl_dutils_system_util=>create_sysuuid_x16( ).
  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~persist.
    DATA: used_objects_db TYPE zif_dutils_ty_oea=>ty_used_objects_db.

    LOOP AT me->used_objects INTO DATA(used_object).
      DATA(used_object_data) = used_object->to_data( ).
      used_object_data-analysis_id = analysis_id.
      used_object_data-source_obj_id = me->id.
      used_objects_db = VALUE #( BASE used_objects_db ( used_object_data  ) ).
    ENDLOOP.

    " discard of duplicates
    SORT used_objects_db BY used_obj_display_name used_obj_type used_obj_sub_type.
    DELETE ADJACENT DUPLICATES FROM used_objects_db COMPARING used_obj_display_name used_obj_type used_obj_sub_type.

    DATA(data_access) = zcl_dutils_oea_dac=>get_instance( ).

    data_access->insert_source_object( VALUE #(
      analysis_id         = analysis_id
      source_obj_id       = me->id
      generated           = me->generated
      object_name         = me->name
      object_display_name = me->display_name
      object_type         = me->type
      object_sub_type     = me->sub_type
      parent_ref          = me->parent_ref
      used_object_count   = lines( me->used_objects ) ) ).

    data_access->insert_used_objects( used_objects_db ).

  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~determine_environment.
    me->used_objects = get_env_service( )->determine_used_objects(
      object = VALUE #(
        name = me->display_name
        type = me->external_type ) ).
  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~set_parent_ref.
    me->parent_ref = parent_ref.
  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~set_id.
    me->id = id.
  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~set_generated.
    me->generated = generated.
  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~needs_processing.
    result = me->processing.
  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~set_processing.
    me->processing = processing.
  ENDMETHOD.

  METHOD zif_dutils_oea_object~get_display_name.
    result = me->display_name.
  ENDMETHOD.

  METHOD zif_dutils_oea_source_object~get_id.
    result = me->id.
  ENDMETHOD.

  METHOD zif_dutils_oea_object~get_name.
    result = me->name.
  ENDMETHOD.

  METHOD get_env_service.
    IF me->env_service IS INITIAL.
      me->env_service = zcl_dutils_oea_env_srv_factory=>create_env_service( me->external_type ).
    ENDIF.

    result = me->env_service.
  ENDMETHOD.

ENDCLASS.

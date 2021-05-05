"! <p class="shorttext synchronized" lang="en">Environment determination for BOBF objects</p>
CLASS zcl_dutils_oea_bobf_env_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_oea_env_service.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_bo_properties,
        const_interface            TYPE /bobf/obm_obj-const_interface,
        object_model_cds_view_name TYPE c LENGTH 30,
      END OF ty_bo_properties,

      BEGIN OF ty_bo_node,
        data_type                     TYPE /bobf/obm_node-data_type,
        data_data_type                TYPE /bobf/obm_node-data_data_type,
        data_table_type               TYPE /bobf/obm_node-data_table_type,
        database_table                TYPE /bobf/obm_node-database_table,
        auth_check_class              TYPE /bobf/obm_node-auth_check_class,
        object_model_cds_view_name    TYPE c LENGTH 30,
        object_mdl_active_persistence TYPE /bobf/obm_node-object_mdl_active_persistence,
        draft_class                   TYPE /bobf/obm_node-draft_class,
        draft_data_type               TYPE /bobf/obm_node-draft_data_type,
        object_mdl_draft_persistence  TYPE /bobf/obm_node-object_mdl_draft_persistence,
      END OF ty_bo_node.

    METHODS:
      find_bo_properties
        IMPORTING
          bo_name      TYPE /bobf/obm_name
        CHANGING
          used_objects TYPE zif_dutils_oea_used_object=>ty_table,
      find_actions
        IMPORTING
          bo_name      TYPE /bobf/obm_name
        CHANGING
          used_objects TYPE zif_dutils_oea_used_object=>ty_table,
      find_determinatations
        IMPORTING
          bo_name      TYPE /bobf/obm_name
        CHANGING
          used_objects TYPE zif_dutils_oea_used_object=>ty_table,
      find_validations
        IMPORTING
          bo_name      TYPE /bobf/obm_name
        CHANGING
          used_objects TYPE zif_dutils_oea_used_object=>ty_table,
      find_nodes
        IMPORTING
          bo_name      TYPE /bobf/obm_name
        CHANGING
          used_objects TYPE zif_dutils_oea_used_object=>ty_table,
      find_alt_keys
        IMPORTING
          bo_name      TYPE /bobf/obm_name
        CHANGING
          used_objects TYPE zif_dutils_oea_used_object=>ty_table,
      add_used_object
        IMPORTING
          used_obj_name TYPE c
          external_type TYPE c
        CHANGING
          used_objects  TYPE zif_dutils_oea_used_object=>ty_table.
ENDCLASS.



CLASS zcl_dutils_oea_bobf_env_srv IMPLEMENTATION.


  METHOD zif_dutils_oea_env_service~determine_used_objects.
    DATA(bo_name) = CONV /bobf/obm_name( name ).

    find_bo_properties(
      EXPORTING bo_name = bo_name
      CHANGING  used_objects = result ).
    find_actions(
      EXPORTING bo_name = bo_name
      CHANGING  used_objects = result ).
    find_determinatations(
      EXPORTING bo_name = bo_name
      CHANGING used_objects = result ).
    find_validations(
      EXPORTING bo_name = bo_name
      CHANGING used_objects = result ).
    find_nodes(
      EXPORTING bo_name = bo_name
      CHANGING used_objects = result ).
    find_alt_keys(
      EXPORTING bo_name = bo_name
      CHANGING used_objects = result ).

  ENDMETHOD.


  METHOD find_bo_properties.
    DATA bo_properties TYPE ty_bo_properties.

    " 1) Select properties for NW >= 740
    SELECT SINGLE const_interface
      FROM /bobf/obm_obj
      WHERE name = @bo_name
      INTO CORRESPONDING FIELDS OF @bo_properties.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " 2) Try to select properties for NW > 740
    DATA(select_list) = `object_model_cds_view_name`.
    TRY.
        SELECT SINGLE (select_list)
          FROM /bobf/obm_obj
          WHERE name = @bo_name
          INTO CORRESPONDING FIELDS OF @bo_properties.
      CATCH cx_sy_dynamic_osql_semantics ##NO_HANDLER.
    ENDTRY.

    _add_used_obj:
      bo_properties-const_interface            zif_dutils_c_tadir_type=>interface,
      bo_properties-object_model_cds_view_name zif_dutils_c_tadir_type=>structured_object.
  ENDMETHOD.


  METHOD find_nodes.
    DATA: bo_nodes TYPE TABLE OF ty_bo_node.
    FIELD-SYMBOLS: <node> TYPE zcl_dutils_oea_bobf_env_srv=>ty_bo_node.

    " 1) Select properties for NW >= 740
    SELECT node~data_type,
           node~data_data_type,
           node~data_table_type,
           node~database_table,
           node~auth_check_class,
           node~object_mdl_active_persistence,
           node~draft_class,
           node~draft_data_type,
           node~object_mdl_draft_persistence
      FROM /bobf/obm_bo AS bo
        INNER JOIN /bobf/obm_node AS node
          ON bo~bo_key = node~bo_key
      WHERE bo~bo_name = @bo_name
      INTO CORRESPONDING FIELDS OF TABLE @bo_nodes.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT bo_nodes ASSIGNING <node>.
      _add_used_obj:
        <node>-data_type                      zif_dutils_c_object_type=>structure,
        <node>-data_data_type                 zif_dutils_c_object_type=>structure,
        <node>-data_table_type                zif_dutils_c_tadir_type=>table_type,
        <node>-database_table                 zif_dutils_c_tadir_type=>table,
        <node>-auth_check_class               zif_dutils_c_tadir_type=>class,
        <node>-object_mdl_active_persistence  zif_dutils_c_tadir_type=>table,
        <node>-draft_class                    zif_dutils_c_tadir_type=>class,
        <node>-draft_data_type                zif_dutils_c_object_type=>structure,
        <node>-object_mdl_draft_persistence   zif_dutils_c_tadir_type=>table.
    ENDLOOP.

    " 2) Try to select properties for NW > 740
    DATA(select_list) = `node~object_model_cds_view_name`.
    TRY.
        SELECT (select_list)
          FROM /bobf/obm_bo AS bo
            INNER JOIN /bobf/obm_node AS node
              ON bo~bo_key = node~bo_key
          WHERE bo~bo_name = @bo_name
          INTO CORRESPONDING FIELDS OF TABLE @bo_nodes.
      CATCH cx_sy_dynamic_osql_semantics ##NO_HANDLER.
        RETURN.
    ENDTRY.

    LOOP AT bo_nodes ASSIGNING <node>.
      _add_used_obj:
        <node>-object_model_cds_view_name  zif_dutils_c_tadir_type=>structured_object.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_actions.
    SELECT act_class,
           param_data_type,
           export_param_s,
           export_param_tt
      FROM /bobf/act_list
      WHERE name = @bo_name
        AND act_class <> ''
      INTO TABLE @DATA(bo_actions).

    LOOP AT bo_actions ASSIGNING FIELD-SYMBOL(<action>).
      _add_used_obj:
        <action>-act_class        zif_dutils_c_tadir_type=>class,
        <action>-param_data_type  zif_dutils_c_object_type=>structure,
        <action>-export_param_s   zif_dutils_c_object_type=>structure,
        <action>-export_param_tt  zif_dutils_c_tadir_type=>table_type.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_determinatations.
    SELECT det_class
      FROM /bobf/det_list
      WHERE name = @bo_name
        AND det_class <> ''
      INTO TABLE @DATA(bo_determinations).

    LOOP AT bo_determinations ASSIGNING FIELD-SYMBOL(<determination>).
      APPEND zcl_dutils_oea_factory=>create_used_object(
        name          = CONV #( <determination>-det_class )
        external_type = zif_dutils_c_tadir_type=>class ) TO used_objects.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_validations.
    SELECT val_class
      FROM /bobf/val_list
      WHERE name = @bo_name
        AND val_class <> ''
      INTO TABLE @DATA(bo_validations).

    LOOP AT bo_validations ASSIGNING FIELD-SYMBOL(<validation>).
      APPEND zcl_dutils_oea_factory=>create_used_object(
        name          = CONV #( <validation>-val_class )
        external_type = zif_dutils_c_tadir_type=>class ) TO used_objects.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_alt_keys.
    SELECT data_type,
           data_table_type
      FROM /bobf/obm_altkey
      WHERE name = @bo_name
      INTO TABLE @DATA(bo_alt_keys).

    LOOP AT bo_alt_keys ASSIGNING FIELD-SYMBOL(<alt_key>).
      add_used_object(
        EXPORTING used_obj_name = <alt_key>-data_type
                  external_type = zif_dutils_c_object_type=>structure
        CHANGING  used_objects  = used_objects ).
      add_used_object(
        EXPORTING used_obj_name = <alt_key>-data_table_type
                  external_type = zif_dutils_c_tadir_type=>table_type
        CHANGING  used_objects  = used_objects ).
    ENDLOOP.

  ENDMETHOD.


  METHOD add_used_object.
    CHECK used_obj_name IS NOT INITIAL.

    APPEND zcl_dutils_oea_factory=>create_used_object(
      name          = CONV #( used_obj_name )
      external_type = CONV #( external_type ) ) TO used_objects.
  ENDMETHOD.


ENDCLASS.

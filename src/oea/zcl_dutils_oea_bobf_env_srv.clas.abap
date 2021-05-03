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
    CONSTANTS:
      c_bobf_prefix     TYPE classname VALUE '/BOBF/*',
      c_bobf_prefix_sql TYPE classname VALUE '/BOBF/%'.

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
    SELECT SINGLE const_interface,
           object_model_cds_view_name
      FROM /bobf/obm_obj
      WHERE name = @bo_name
      INTO @DATA(bo_properties).

    IF sy-subrc = 0.
      add_used_object(
        EXPORTING used_obj_name = bo_properties-const_interface
                  external_type = zif_dutils_c_tadir_type=>interface
        CHANGING  used_objects  = used_objects ).
      add_used_object(
        EXPORTING used_obj_name = bo_properties-object_model_cds_view_name
                  external_type = zif_dutils_c_tadir_type=>structured_object
        CHANGING  used_objects  = used_objects ).
    ENDIF.
  ENDMETHOD.


  METHOD find_nodes.
    SELECT node~data_type,
           node~data_data_type,
           node~data_table_type,
           node~database_table,
           node~auth_check_class,
           node~object_model_cds_view_name,
           node~object_mdl_active_persistence,
           node~draft_class,
           node~draft_data_type,
           node~object_mdl_draft_persistence
      FROM /bobf/obm_bo AS bo
        INNER JOIN /bobf/obm_node AS node
          ON bo~bo_key = node~bo_key
      WHERE bo~bo_name = @bo_name
      INTO TABLE @DATA(bo_nodes).

    DEFINE _add_used_obj.
      add_used_object(
        EXPORTING used_obj_name = <node>-&1
                  external_type = &2
        CHANGING  used_objects  = used_objects ).
    END-OF-DEFINITION.

    LOOP AT bo_nodes ASSIGNING FIELD-SYMBOL(<node>).
      _add_used_obj:
        data_type                      zif_dutils_c_object_type=>structure,
        data_data_type                 zif_dutils_c_object_type=>structure,
        data_table_type                zif_dutils_c_tadir_type=>table_type,
        database_table                 zif_dutils_c_tadir_type=>table,
        auth_check_class               zif_dutils_c_tadir_type=>class,
        object_model_cds_view_name     zif_dutils_c_tadir_type=>structured_object,
        object_mdl_active_persistence  zif_dutils_c_tadir_type=>table,
        draft_class                    zif_dutils_c_tadir_type=>class,
        draft_data_type                zif_dutils_c_object_type=>structure,
        object_mdl_draft_persistence   zif_dutils_c_tadir_type=>table.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_actions.
    " TODO: Check if only custom actions should be displayed
    SELECT act_class,
           param_data_type,
           export_param_s,
           export_param_tt
      FROM /bobf/act_list
      WHERE name = @bo_name
        AND act_class IS NOT INITIAL
        AND object_model_generated = @abap_false
      INTO TABLE @DATA(bo_actions).

    DEFINE _add_used_obj.
      add_used_object(
        EXPORTING used_obj_name = <action>-&1
                  external_type = &2
        CHANGING  used_objects  = used_objects ).
    END-OF-DEFINITION.

    LOOP AT bo_actions ASSIGNING FIELD-SYMBOL(<action>).
      _add_used_obj:
        act_class        zif_dutils_c_tadir_type=>class,
        param_data_type  zif_dutils_c_object_type=>structure,
        export_param_s   zif_dutils_c_object_type=>structure,
        export_param_tt  zif_dutils_c_tadir_type=>table_type.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_determinatations.
    SELECT det_class
      FROM /bobf/det_list
      WHERE name = @bo_name
        AND det_class IS NOT INITIAL
        AND det_class NOT LIKE @c_bobf_prefix_sql
        AND object_model_generated = @abap_false
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
        AND val_class IS NOT INITIAL
        AND val_class NOT LIKE @c_bobf_prefix_sql
        AND object_model_generated = @abap_false
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
    CHECK: used_obj_name IS NOT INITIAL,
           used_obj_name NP c_bobf_prefix.

    APPEND zcl_dutils_oea_factory=>create_used_object(
      name          = CONV #( used_obj_name )
      external_type = CONV #( external_type ) ) TO used_objects.
  ENDMETHOD.


ENDCLASS.

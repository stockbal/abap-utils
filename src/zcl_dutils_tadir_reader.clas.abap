"! <p class="shorttext synchronized" lang="en">Access to TADIR Table</p>
CLASS zcl_dutils_tadir_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_tadir_reader.

    METHODS:
      constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      package_reader TYPE REF TO zif_dutils_devc_reader,
      where_clause   TYPE TABLE OF string.
    DATA:
      BEGIN OF where_ranges,
        name    TYPE RANGE OF tadir-obj_name,
        type    TYPE RANGE OF tadir-object,
        package TYPE RANGE OF tadir-devclass,
        author  TYPE RANGE OF tadir-author,
      END OF where_ranges.

    METHODS:
      build_where,
      add_to_where
        IMPORTING
          range_name  TYPE string
          table_field TYPE string.
ENDCLASS.



CLASS zcl_dutils_tadir_reader IMPLEMENTATION.

  METHOD constructor.
    me->package_reader = zcl_dutils_reader_factory=>get_package_reader( ).
  ENDMETHOD.

  METHOD zif_dutils_tadir_reader~include_by_name.
    CHECK names IS NOT INITIAL.

    me->where_ranges-name = VALUE #(
      FOR <name> IN names
      ( sign   = 'I'
        option = COND #( WHEN <name> CA '+*' THEN 'CP' ELSE 'EQ' )
        low    = to_upper( <name> ) ) ).

    result = me.
  ENDMETHOD.

  METHOD zif_dutils_tadir_reader~include_by_package.
    CHECK packages IS NOT INITIAL.

    me->where_ranges-package = VALUE #(
      FOR <pack> IN packages
      ( sign   = 'I'
        option = COND #( WHEN <pack> CA '+*' THEN 'CP' ELSE 'EQ' )
        low    = to_upper( <pack> ) ) ).

    IF resolve_subpackages = abap_true.
      me->where_ranges-package = VALUE #(
        BASE me->where_ranges-package
        ( LINES OF me->package_reader->get_subpackages_by_range( me->where_ranges-package ) ) ).

      SORT me->where_ranges-package BY sign option low.
      DELETE ADJACENT DUPLICATES FROM me->where_ranges-package COMPARING sign option low.
    ENDIF.

    result = me.
  ENDMETHOD.

  METHOD zif_dutils_tadir_reader~include_by_type.
    CHECK types IS NOT INITIAL.

    me->where_ranges-type = VALUE #(
      FOR <type> IN types
      ( sign   = 'I'
        option = COND #( WHEN <type> CA '+*' THEN 'CP' ELSE 'EQ' )
        low    = to_upper( <type> ) ) ).

    result = me.
  ENDMETHOD.

  METHOD zif_dutils_tadir_reader~include_by_author.
    CHECK authors IS NOT INITIAL.

    me->where_ranges-author = VALUE #(
      FOR <author> IN authors
      ( sign   = 'I'
        option = COND #( WHEN <author> CA '+*' THEN 'CP' ELSE 'EQ' )
        low    = to_upper( <author> ) ) ).

    result = me.
  ENDMETHOD.

  METHOD zif_dutils_tadir_reader~select.
    build_where( ).

    IF me->where_clause IS INITIAL.
      RETURN.
    ENDIF.

    SELECT object AS type,
           obj_name AS name,
           devclass AS package
      FROM tadir
      WHERE (me->where_clause)
        AND delflag = @abap_false
      ORDER BY type, name
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD zif_dutils_tadir_reader~select_single.
    build_where( ).

    IF me->where_clause IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE object AS type,
                  obj_name AS name,
                  devclass AS package
      FROM tadir
      WHERE (me->where_clause)
        AND delflag = @abap_false
      INTO CORRESPONDING FIELDS OF @result.
  ENDMETHOD.

  METHOD zif_dutils_tadir_reader~reset.
    CLEAR: me->where_clause,
           me->where_ranges.

    result = me.
  ENDMETHOD.

  METHOD build_where.
    add_to_where(
      range_name  = 'where_ranges-name'
      table_field = 'obj_name' ).
    add_to_where(
      range_name  = 'where_ranges-type'
      table_field = 'object' ).
    add_to_where(
      range_name  = 'where_ranges-package'
      table_field = 'devclass' ).
    add_to_where(
      range_name  = 'where_ranges-author'
      table_field = 'author' ).
  ENDMETHOD.

  METHOD add_to_where.
    DATA: where_clause_line TYPE string.

    ASSIGN me->(range_name) TO FIELD-SYMBOL(<range_table>).
    IF sy-subrc <> 0 OR <range_table> IS INITIAL.
      RETURN.
    ENDIF.

    IF me->where_clause IS NOT INITIAL.
      where_clause_line = | AND |.
    ENDIF.

    where_clause_line = |{ where_clause_line }{ table_field } IN @me->{ range_name }|.

    me->where_clause = VALUE #( BASE me->where_clause ( where_clause_line ) ).
  ENDMETHOD.

ENDCLASS.

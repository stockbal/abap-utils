"! <p class="shorttext synchronized" lang="en">Access to Table DD02L (SAP Tables)</p>
CLASS zcl_dutils_ddic_table_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_dutils_ddic_table_reader.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_dutils_ddic_table_reader IMPLEMENTATION.

  METHOD zif_dutils_ddic_table_reader~get_table_wb_type.
    SELECT SINGLE tabclass
      FROM dd02l
      WHERE tabname = @table_name
        AND as4local = 'A'
    INTO @DATA(table_class).

    IF sy-subrc = 0.
      IF table_class = 'INTTAB' OR table_class = 'APPEND'.
        result = swbm_c_type_ddic_structure.
      ELSEIF table_class = 'TRANSP'.
        result = swbm_c_type_ddic_db_table.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

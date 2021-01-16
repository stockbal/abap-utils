"! <p class="shorttext synchronized" lang="en">Access to Table DD02l (SAP Tables)</p>
INTERFACE zif_dutils_ddic_table_reader
  PUBLIC .

  "! <p class="shorttext synchronized" lang="en">Retrieves workbench type of given table</p>
  METHODS get_table_wb_type
    IMPORTING
      table_name    TYPE tabname
    RETURNING
      VALUE(result) TYPE seu_objtyp.
ENDINTERFACE.

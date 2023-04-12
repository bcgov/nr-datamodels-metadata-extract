SELECT a.table_name, column_name
  FROM dba_tab_columns a
 WHERE a.owner = 'THE' – Schema Name
   AND a.table_name NOT LIKE 'BIN$%' – Not in the recycle bin
   AND data_type = 'SDO_GEOMETRY';
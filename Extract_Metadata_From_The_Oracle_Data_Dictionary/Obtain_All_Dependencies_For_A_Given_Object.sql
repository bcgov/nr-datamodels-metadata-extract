SELECT * 
  FROM dba_dependencies 
 WHERE referenced_name = 'ORG_UNIT'
 ORDER BY 1, 3, 2;
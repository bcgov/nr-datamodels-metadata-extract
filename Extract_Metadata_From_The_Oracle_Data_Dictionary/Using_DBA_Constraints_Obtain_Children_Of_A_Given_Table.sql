SELECT con.owner table_owner
     , con.table_name
     , con.r_owner parent_owner
     , ref.table_name parent_table
  FROM dba_constraints con
     , dba_constraints ref
 WHERE ref.table_name = 'CLIENT_LOCATION'
   AND con.constraint_type = 'R'
   AND con.r_constraint_name = ref.constraint_name
 ORDER BY 2;
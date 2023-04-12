SELECT con.owner table_owner
     , con.table_name
     , con.r_owner parent_owner
     , ref.table_name parent_table 
  FROM dba_constraints con
     , dba_constraints ref 
 WHERE con.table_name = 'FOREST_CLIENT'
   AND con.constraint_type = 'R'
   AND con.r_constraint_name = ref.constraint_name;
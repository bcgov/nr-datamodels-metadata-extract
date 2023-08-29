SELECT parent.owner         
     , parent.table_name
     , parent.constraint_name   prim_key
     , children.owner
     , children.table_name
     , children.constraint_name frign_key
  FROM all_constraints parent
     , all_constraints children
 WHERE parent.constraint_name = children.r_constraint_name 
   AND parent.table_name IN ('SILV_BASE_CODE','SILV_TECHNIQUE_CODE') 
   AND parent.constraint_type = 'P'
   AND children.constraint_type = 'R' 
 ORDER BY 2, 4;
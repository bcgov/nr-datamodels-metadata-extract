-- Script used to obtain the security classifications uploaded to the repository for a specific Data Model or table
-- Modifiers:
-- Table, Column or Data Model name.
SELECT p_model.object_name                                            model_name  -- e.g. "RESPROJ%"
     , SUBSTR(p_model.object_name,1,INSTR(p_model.object_name,'_')-1) app_name
--     , p_table.parent_object_key table_key -- OBJECT_ID
     , p_table.object_name                                            table_name  -- e.g. "RESEARCH_CONTACT"
     , clmn.object_name                                               column_name -- e.g. "CONTACT_FIRST_NAME"
     , rbs.current_value                                              sec_clssfctn
  FROM app_erstudio.V_RPT_BOUND_SECURITY rbs
     , app_erstudio.source_key_map clmn
     , app_erstudio.source_key_map p_table 
     , app_erstudio.source_key_map p_model 
 WHERE rbs.bound_object_key = clmn.object_key 
   AND (upper(current_value) LIKE 'PROTECTED%' OR upper(current_value) = 'PUBLIC')
   AND clmn.parent_object_key = p_table.object_key 
   AND p_table.parent_object_key = p_model.object_key 
--   AND skm.object_name = 'CONTACT_FIRST_NAME'
--   AND p_table.object_name = 'RESEARCH_CONTACT'
   AND p_model.object_name LIKE 'RESPROJ%'
 ORDER BY app_name, table_name, column_name
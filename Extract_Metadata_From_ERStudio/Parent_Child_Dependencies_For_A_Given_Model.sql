SELECT Diag_ver.Name as "Application Name"
     , mdl_ver.name as "Model Name"
     , parent_table.table_name AS "Parent Table"
     , child_table.table_name AS "Child Table"
  FROM app_erstudio.diagram diag
     , app_erstudio.diagram_ver diag_ver
     , app_erstudio.model mdl
     , app_erstudio.model_ver mdl_ver
     , app_erstudio.submodel smdl
     , app_erstudio.submodel_ver smdl_ver
     , app_erstudio.entity ent
     , app_erstudio.entity_ver ent_ver
     , app_erstudio.relationship rel
     , app_erstudio.relationship_ver rel_ver
     , (SELECT ent_ver2.entity_ver_id
             , ent_ver2.entity_id
             , ent_ver2.table_name
         FROM app_erstudio.entity ent2
            , app_erstudio.entity_ver ent_ver2
        WHERE ent2.latest_version_id = ent_ver2.entity_ver_id) parent_table
     , (SELECT ent_ver2.entity_ver_id
             , ent_ver2.entity_id
             , ent_ver2.table_name
          FROM app_erstudio.entity ent2
             , app_erstudio.entity_ver ent_ver2
         WHERE ent2.latest_version_id = ent_ver2.entity_ver_id) child_table
 WHERE diag.latest_version_id = diag_ver.diagram_ver_id
   AND diag_ver.diagram_id = mdl.diagram_id
   AND mdl.latest_version_id = mdl_ver.model_ver_id
   AND mdl_ver.model_id = smdl.model_id
   AND smdl.latest_version_id = smdl_ver.submodel_ver_id
   AND mdl.model_id = ent.model_id
   AND ent.latest_version_id = ent_ver.entity_ver_id
   AND ent_ver.ENTITY_ID = rel.PARENT_ENTITY_ID
   AND rel.LATEST_VERSION_ID = rel_ver.RELATIONSHIP_VER_ID
   AND rel_ver.parent_entity_ver_id = parent_table.entity_ver_id
   AND rel_ver.child_entity_ver_id = child_table.entity_ver_id
   AND diag.is_deleted = 0
   AND mdl_ver.name = 'CLIENT_Physical'  -- A given Model name
   AND smdl_ver.Name = 'Main Model'      -- It assumes the name 'Main Model', as it is the default value assigned by ER Studio
 ORDER BY 1, 4;

-- Query modifiers
  AND parent_table.table_name = 'physical table name' -- When present, it will return all "children" of a given table
  AND child_table.table_name = 'physical table name'  -- When present, it will return all "parents" of a given table
  AND mdl_ver.name = 'CLIENT_Physical' -- If excluded or used with LIKE '%Physical' or '%Logical', performs the search 
                                       -- in all specified models across the repository
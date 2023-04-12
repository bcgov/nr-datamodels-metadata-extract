SELECT diagram_Ver.Name as "Diagram Name"
     , model_ver.name as "Model Name"
     , subModel_Ver.Name as "Submodel Name"
     , entity_Ver.Name as "Entity Name"
     , entity_Ver.Table_Name as "Table Name"
     , entity_ver.definition
  FROM app_erstudio.diagram
    , app_erstudio.diagram_ver
    , app_erstudio.entity
    , app_erstudio.entity_ver
    , app_erstudio.model
    , app_erstudio.model_ver
    , app_erstudio.subModel_ver
    , app_erstudio.subModel
 WHERE entity.latest_version_id = entity_ver.entity_ver_id
   AND model.model_id = entity.model_id
   AND submodel.latest_version_id = submodel_ver.submodel_ver_id
   AND model.model_id = submodel.model_id
   AND diagram_ver.diagram_id = model.diagram_id
   AND model.latest_version_id = model_ver.model_ver_id
   AND diagram.latest_version_id = diagram_ver.diagram_Ver_id
   AND diagram.is_deleted = 0
   AND diagram_ver.name LIKE '%LEXIS' -- A Given application
   AND model_ver.name LIKE '%Physical'; -- Filter only physical model by using naming pattern

-- Query Modifiers
-- and diagram_ver.file_name = 'dm1 diagram name'    -- use this where clause to isolate a particular diagram
-- and entity_ver.name = 'logical entity name'       -- use this where clause to isolate a logical entity
-- and entity_ver.table_name = 'physical table name' -- use this where clause to isolate a physical table
-- and submodel_ver.name != 'Main Model'             -- use this where clause to excluded the main model
-- and submodel_ver.name = 'submodel name'           -- use this where clause to isolate a submodel
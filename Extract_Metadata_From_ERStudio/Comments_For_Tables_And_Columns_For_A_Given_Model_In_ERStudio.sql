SELECT Diagram_Ver.Name as "Diagram Name"
     , model_ver.name as "Model Name"
     , SubModel_Ver.Name as "Submodel Name"
     , Entity_Ver.Table_Name as "Table Name"
     , replace(replace(entity_ver.definition,chr(10),' '),chr(13),null) as "Table Definition" 
     , Attribute_Ver.Sequence_Number as "Order"
     , Attribute_Ver.Column_Name AS "Column Name"
     , replace(replace(Attribute_Ver.Definition,chr(10),' '),chr(13),null) AS "Column Definition"
  FROM app_erstudio.Diagram
     , app_erstudio.Diagram_Ver
     , app_erstudio.Entity
     , app_erstudio.Entity_Ver
     , app_erstudio.Model
     , app_erstudio.model_ver
     , app_erstudio.SubModel_Ver
     , app_erstudio.SubModel
     , app_erstudio.Attribute
     , app_erstudio.Attribute_Ver
 WHERE (Entity.Latest_Version_ID = Entity_Ver.Entity_Ver_ID  
        AND Model.Model_ID = Entity.Model_ID  
        AND SubModel.Latest_Version_ID = SubModel_Ver.SubModel_Ver_ID 
        AND Model.Model_ID = SubModel.Model_ID 
        AND Diagram_Ver.Diagram_ID = Model.Diagram_ID 
        AND model.latest_version_id = model_ver.model_ver_id 
        AND Diagram.Latest_Version_ID = Diagram_Ver.Diagram_Ver_ID 
        AND Diagram.is_deleted = 0
        AND Attribute_Ver.Attribute_Ver_ID = Attribute.Latest_Version_ID
        AND Attribute.Entity_ID = Entity.Entity_ID) 
   and model_ver.name = 'CLIENT_Physical'
-- and diagram_ver.file_name = 'enter dm1 name'         -- use this where clause to isolate a particular diagram
-- and entity_ver.name = 'enter logical entity name'    -- use this where clause to isolate a logical entity
-- and entity_ver.table_name = 'CLIENT_TYPE_CODE'       -- use this where clause to isolate a physical table
-- and submodel_ver.name != 'Main Model'                -- use this where clause to excluded the main model
-- and submodel_ver.name = 'enter submodel name'        -- use this where clause to isolate a submodel
 ORDER BY 4, 6;
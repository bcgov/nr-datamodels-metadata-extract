-- COMMENT ON COLUMN 'THE.<TABLE_NAME>.<COLUMN_NAME> IS <'COMMENT'>; '
SELECT 'COMMENT ON COLUMN THE.' || entity_ver.table_name || '.' || Attribute_Ver.Column_Name || ' IS ''' || 
       replace(replace(Attribute_Ver.Definition, chr(10), ' '), chr(13), null) || ''';' AS update_comment
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
   and model_ver.name IN ({models})
ORDER BY 1
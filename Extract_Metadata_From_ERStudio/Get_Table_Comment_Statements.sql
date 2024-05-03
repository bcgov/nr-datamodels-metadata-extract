SELECT --DISTINCT model_ver.name
--     , entdver.backgroundcolor
--     , Entity_Ver.Table_Name as "Table Name"
      'COMMENT ON TABLE THE.'||Entity_Ver.Table_Name||' IS '''||replace(replace(entity_ver.definition,chr(10),' '),chr(13),null)
         ||''';' update_comment
  FROM app_erstudio.Diagram
     , app_erstudio.Diagram_Ver
     , app_erstudio.Entity
     , app_erstudio.Entity_Ver
     , app_erstudio.Model
     , app_erstudio.Model_ver
     , app_erstudio.SubModel_Ver
     , app_erstudio.SubModel
     , app_erstudio.entity_display     entd
     , app_erstudio.entity_display_ver entdver
 WHERE Entity.Latest_Version_ID = Entity_Ver.Entity_Ver_ID  
   AND Model.Model_ID = Entity.Model_ID  
   AND SubModel.Latest_Version_ID = SubModel_Ver.SubModel_Ver_ID 
   AND Model.Model_ID = SubModel.Model_ID 
   AND Diagram_Ver.Diagram_ID = Model.Diagram_ID 
   AND model.latest_version_id = model_ver.model_ver_id 
   AND Diagram.Latest_Version_ID = Diagram_Ver.Diagram_Ver_ID 
   AND Diagram.is_deleted = 0 
   AND Diagram.latest_version_id  = Diagram_Ver.diagram_ver_id
   AND entity.entity_id           = entd.entity_id
   AND entdver.entity_display_ver_id = entd.latest_version_id   
   AND Model_ver.name IN ('CLIENT_Physical','FTA_Physical','HBS_Physical')
   AND (entdver.backgroundcolor = 0 OR entdver.backgroundcolor = 16777215)
   AND trim(entity_ver.definition) IS NOT NULL
   AND Entity_Ver.Table_Name NOT IN ('SDE_LOGFILES','SDE_LOGFILE_DATA','CG_REF_CODES') -- Some models include these SDE objects and other
   AND SUBSTR(Entity_Ver.Table_Name,1,5) NOT IN ('MDXT_','MDRT_','RUPD$','MLOG$');     -- Exclude MViews and MView Logs existing in some models
-- and diagram_ver.file_name = 'enter dm1 name'         -- use this where clause to isolate a particular diagram
-- and entity_ver.name = 'enter logical entity name'    -- use this where clause to isolate a logical entity
-- and entity_ver.table_name = 'CLIENT_TYPE_CODE'       -- use this where clause to isolate a physical table
-- and submodel_ver.name != 'Main Model'                -- use this where clause to excluded the main model
-- and submodel_ver.name = 'enter submodel name'        -- use this where clause to isolate a submodel
 ORDER BY Entity_Ver.Table_Name;
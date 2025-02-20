SELECT 'COMMENT ON TABLE THE.'||Entity_Ver.Table_Name||' IS '''||replace(replace(entity_ver.definition,chr(10),' '),chr(13),null)
         ||''';' update_comment
FROM app_erstudio.Diagram
   , app_erstudio.Diagram_Ver
   , app_erstudio.Entity
   , app_erstudio.Entity_Ver
   , app_erstudio.Model
   , app_erstudio.Model_ver
   , app_erstudio.SubModel_Ver
   , app_erstudio.SubModel
   , app_erstudio.entity_display entd
   , app_erstudio.entity_display_ver entdver
WHERE Entity.Latest_Version_ID = Entity_Ver.Entity_Ver_ID  
AND Model.Model_ID = Entity.Model_ID  
AND SubModel.Latest_Version_ID = SubModel_Ver.SubModel_Ver_ID 
AND Model.Model_ID = SubModel.Model_ID 
AND Diagram_Ver.Diagram_ID = Model.Diagram_ID 
AND model.latest_version_id = model_ver.model_ver_id 
AND Diagram.Latest_Version_ID = Diagram_Ver.Diagram_Ver_ID 
AND Diagram.is_deleted = 0 
AND Diagram.latest_version_id = Diagram_Ver.diagram_ver_id
AND entity.entity_id = entd.entity_id
AND entdver.entity_display_ver_id = entd.latest_version_id   
AND Model_ver.name = ({models})
AND (entdver.backgroundcolor = 0 OR entdver.backgroundcolor = 16777215)
AND trim(entity_ver.definition) IS NOT NULL
AND Entity_Ver.Table_Name NOT IN ('SDE_LOGFILES','SDE_LOGFILE_DATA','CG_REF_CODES') -- Some models include these SDE objects and other
AND SUBSTR(Entity_Ver.Table_Name,1,5) NOT IN ('MDXT_','MDRT_','RUPD$','MLOG$')     -- Exclude MViews and MView Logs existing in some models
ORDER BY 1
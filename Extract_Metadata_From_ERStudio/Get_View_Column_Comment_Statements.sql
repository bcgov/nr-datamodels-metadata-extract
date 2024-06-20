SELECT --model_ver.name, dbview.model_id, dbview.latest_version_id , dbview_ver.dbview_id, dbview_ver.definitionid
      'COMMENT ON COLUMN THE.'||DBView_Ver.Name||' IS '''||replace(replace(DBView_Ver.definitionid,chr(10),' '),chr(13),null)
         ||''';' update_comment
  FROM app_erstudio.Model
     , app_erstudio.Model_ver
     , app_erstudio.Diagram
     , app_erstudio.Diagram_Ver
     , app_erstudio.SubModel
     , app_erstudio.SubModel_Ver
     , app_erstudio.Dbview
     , app_erstudio.Dbview_ver
 WHERE model.latest_version_id = model_ver.model_ver_id 
   AND model_ver.diagram_Ver_id = diagram.latest_Version_id
   AND diagram.latest_version_id = diagram_ver.diagram_Ver_id
   AND diagram_ver.is_deleted = 0
   AND Model.Model_ID = SubModel.Model_ID 
   AND SubModel.Latest_version_id = SubModel_Ver.SubModel_Ver_Id
   AND SubModel_Ver.is_deleted = 0
   AND Model.model_id = DBView.model_id 
   AND DBView.latest_version_id = DBView_Ver.DBView_Ver_id
   AND Model_ver.name IN ('CLIENT_Physical')
   AND trim(DBView_Ver.definitionid) IS NOT NULL
-- and diagram_ver.file_name = 'enter dm1 name'         -- use this where clause to isolate a particular diagram
-- and entity_ver.name = 'enter logical entity name'    -- use this where clause to isolate a logical entity
-- and entity_ver.table_name = 'CLIENT_TYPE_CODE'       -- use this where clause to isolate a physical table
-- and submodel_ver.name != 'Main Model'                -- use this where clause to excluded the main model
-- and submodel_ver.name = 'enter submodel name'        -- use this where clause to isolate a submodel
 --ORDER BY Entity_Ver.Table_Name;
ORDER BY 1;
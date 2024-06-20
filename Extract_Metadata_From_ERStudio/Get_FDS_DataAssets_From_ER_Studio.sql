SELECT DISTINCT REPLACE(SUBSTR(model_ver.name,1,INSTR(model_ver.name,'_')-1),'(FOR)',NULL) application
     , Entity_Ver.Table_Name as "Table Name"
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
   AND Model_ver.name IN ('APT2_Physical'
                         ,'BEC_Physical'
                         ,'CBR_Physical'
                         ,'CLIENT_Physical'
                         ,'CONSEP_Physical'
                         ,'CSP_Physical'
                         ,'ECAS_Physical'
                         ,'ERA_Physical'
                         ,'FNIRS_Physical'
                         ,'FPCT_Physical'
                         ,'FSP_Physical'
                         ,'FTA_Physical'
                         ,'FTC_Physical'
                         ,'GAS2_Physical'
                         ,'GBMS_Physical'
                         ,'HBS_Physical'
                         ,'IAPP_Physical'
                         ,'ILCR_Physical'
                         ,'ISP_Physical'
                         ,'LEXIS_Physical'
                         ,'LTRACK_Physical'
                         ,'MSD_Physical'
                         ,'NSA2_Physical'
                         ,'REPT_Physical'
                         ,'RESPROJ_Physical'
                         ,'RESULTS_Physical'
                         ,'RTM_Physical'
                         ,'SCS_Physical'
                         ,'SPAR_Physical'
                         ,'TSADMRPT_Physical'
                         ,'WASTE(FOR)_Physical'
                         ,'ADAM (FOR)_Physical')
   AND entdver.backgroundcolor <> 16764057 --> "External object"
   AND trim(entity_ver.definition) IS NOT NULL
   AND Entity_Ver.Table_Name NOT IN ('SDE_LOGFILES','SDE_LOGFILE_DATA','CG_REF_CODES') -- Some models include these SDE objects and other
   AND SUBSTR(Entity_Ver.Table_Name,1,5) NOT IN ('MDXT_','MDRT_','RUPD$','MLOG$')     -- Exclude MViews and MView Logs existing in some models
 ORDER BY 1, 2;
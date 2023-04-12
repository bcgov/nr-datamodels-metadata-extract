SELECT Dia.File_Name Name
     , Di.Object_GUID
     , Dia.Version_Number
     , Di.Diagram_ID
     , Dia.ERStudio_Version_ID
     , Dia.Name DiagramName
     , Dia.Definition
  FROM app_erstudio.Diagram Di, app_erstudio.Diagram_Ver Dia
 WHERE Dia.Diagram_Ver_ID = Di.Latest_Version_ID 
   AND Di.Is_Deleted <> 1;
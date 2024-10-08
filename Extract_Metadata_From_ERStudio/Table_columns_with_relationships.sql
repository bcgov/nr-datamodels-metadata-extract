WITH table_cols AS ---from prior starter query in Comments_For_Tables_And_Columns_For_A_Given_Model_In_ERStudio.sql
(
  SELECT Diagram_Ver.Name AS Diagram_Name,
         model_ver.Model_ID,
         model_ver.name AS Model_Name,
         SubModel_Ver.Name AS Submodel_Name,
         Entity_Ver.Table_Name AS Table_Name,
         REPLACE(REPLACE(entity_ver.definition,CHR(10),' '),CHR(13),NULL) AS Table_Definition,
         Attribute_Ver.Sequence_Number AS Order_seq,
         Attribute_Ver.Column_Name AS Column_Name,
         Attribute_Ver.ATTRIBUTE_ID,
         REPLACE(REPLACE(Attribute_Ver.Definition,CHR(10),' '),CHR(13),NULL) AS Column_Definition,
         Attribute_Ver.DATA_TYPE,
         Attribute_Ver.LENGTH,
         Attribute_Ver.Scale,
         Attribute_Ver.IS_IDENTITY_COLUMN,
         Attribute_Ver.PRIMARY_KEY,
         '<<<<---->>>>' AS columns_ended
	 FROM app_erstudio.Diagram,
       app_erstudio.Diagram_Ver,
       app_erstudio.Entity,
       app_erstudio.Entity_Ver,
       app_erstudio.Model,
       app_erstudio.model_ver,
       app_erstudio.SubModel_Ver,
       app_erstudio.SubModel,
       app_erstudio.Attribute,
       app_erstudio.Attribute_Ver
  WHERE (Entity.Latest_Version_ID = Entity_Ver.Entity_Ver_ID AND Model.Model_ID = Entity.Model_ID AND SubModel.Latest_Version_ID = SubModel_Ver.SubModel_Ver_ID AND Model.Model_ID = SubModel.Model_ID AND Diagram_Ver.Diagram_ID = Model.Diagram_ID AND model.latest_version_id = model_ver.model_ver_id AND Diagram.Latest_Version_ID = Diagram_Ver.Diagram_Ver_ID AND Diagram.is_deleted = 0 AND Attribute_Ver.Attribute_Ver_ID = Attribute.Latest_Version_ID AND Attribute.Entity_ID = Entity.Entity_ID)
),
relations_child AS
(
  SELECT r.RELATIONSHIP_ID,
         r.MODEL_ID,
         r.PARENT_ENTITY_ID,
         r.CHILD_ENTITY_ID,
         ep.table_name AS parent_table,
         ec.table_name AS child_table,
         rv.INVERSEPHRASEID,
         rv.VERBPHRASEID,
         rv.NAME,
         rv.PARENTCARDINALITYNO,
         rv.CHILDOPTIONALITYID,
         ROW_NUMBER() OVER (PARTITION BY r.MODEL_ID,ec.table_name ORDER BY r.RELATIONSHIP_ID) rn_rel
  FROM app_erstudio.RELATIONSHIP r
    LEFT JOIN (SELECT e.ENTITY_ID,
                      ev.table_name
               FROM app_erstudio.Entity e
                 LEFT JOIN app_erstudio.Entity_ver ev
                        ON (e.ENTITY_ID = ev.ENTITY_ID
                       AND e.LATEST_VERSION_ID = ev.ENTITY_VER_ID)) ec ON (ec.ENTITY_ID = r.CHILD_ENTITY_ID)
    LEFT JOIN (SELECT e.ENTITY_ID,
                      ev.table_name
               FROM app_erstudio.Entity e
                 LEFT JOIN app_erstudio.Entity_ver ev
                        ON (e.ENTITY_ID = ev.ENTITY_ID
                       AND e.LATEST_VERSION_ID = ev.ENTITY_VER_ID)) ep ON (ep.ENTITY_ID = r.PARENT_ENTITY_ID)
    INNER JOIN app_erstudio.RELATIONSHIP_VER rv
            ON (rv.RELATIONSHIP_VER_ID = r.LATEST_VERSION_ID
           AND r.RELATIONSHIP_ID = rv.RELATIONSHIP_ID)
),
relations_par AS
(
  SELECT r.RELATIONSHIP_ID,
         r.MODEL_ID,
         r.PARENT_ENTITY_ID,
         r.CHILD_ENTITY_ID,
         ep.table_name AS parent_table,
         ec.table_name AS child_table,
         rv.INVERSEPHRASEID,
         rv.VERBPHRASEID,
         rv.NAME,
         rv.PARENTCARDINALITYNO,
         rv.CHILDOPTIONALITYID,
         ROW_NUMBER() OVER (PARTITION BY r.MODEL_ID,ep.table_name ORDER BY r.RELATIONSHIP_ID) rn_rel
  FROM app_erstudio.RELATIONSHIP r
    LEFT JOIN (SELECT e.ENTITY_ID,
                      ev.table_name
               FROM app_erstudio.Entity e
                 LEFT JOIN app_erstudio.Entity_ver ev
                        ON (e.ENTITY_ID = ev.ENTITY_ID
                       AND e.LATEST_VERSION_ID = ev.ENTITY_VER_ID)) ep ON (ep.ENTITY_ID = r.PARENT_ENTITY_ID)
    LEFT JOIN (SELECT e.ENTITY_ID,
                      ev.table_name
               FROM app_erstudio.Entity e
                 LEFT JOIN app_erstudio.Entity_ver ev
                        ON (e.ENTITY_ID = ev.ENTITY_ID
                       AND e.LATEST_VERSION_ID = ev.ENTITY_VER_ID)) ec ON (ec.ENTITY_ID = r.CHILD_ENTITY_ID)
    INNER JOIN app_erstudio.RELATIONSHIP_VER rv
            ON (rv.RELATIONSHIP_VER_ID = r.LATEST_VERSION_ID
           AND r.RELATIONSHIP_ID = rv.RELATIONSHIP_ID)
)
, meta_vw as 
(SELECT DISTINCT tc.*,
       rchild.PARENT_TABLE,
       rchild.CHILDOPTIONALITYID AS cardi_cihld,
       rchild.NAME AS constR_name_child,
       '<<--Parent tables ended-->>' child_ended,
       rpar.CHILD_TABLE,
       rpar.NAME AS constr_name_par,
       rpar.CHILDOPTIONALITYID AS cardi_par,
       rchild.rn_rel rn_rel_1,
       rpar.rn_rel rn_rel_2
FROM table_cols tc
  LEFT OUTER JOIN relations_child rchild
               ON (tc.Table_Name = rchild.child_table
              AND tc.model_id = rchild.Model_ID
              AND tc.ORDER_SEQ = rchild.rn_rel)
  LEFT OUTER JOIN relations_par rpar
               ON (tc.Table_Name = rpar.parent_table
              AND tc.model_id = rpar.Model_ID
              AND tc.ORDER_SEQ = rpar.rn_rel)
)
Select distinct table_name, TABLE_DEFINITION from 
meta_vw where 1=1
AND Diagram_Name LIKE '%RRS%'
AND   Model_Name = 'Physical'
AND   Table_Name = 'ROAD_APPLICATION'
-- ORDER BY TABLE_NAME,
--          ORDER_SEQ,
--          rn_rel_1,
--          rn_rel_2
;
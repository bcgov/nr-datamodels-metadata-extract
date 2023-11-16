with table_cols as (
SELECT Diagram_Ver.Name AS Diagram_Name,
       model_ver.Model_ID,
       model_ver.name AS Model_Name,
       SubModel_Ver.Name AS Submodel_Name,
       Entity_Ver.Table_Name AS Table_Name,
       REPLACE(REPLACE(entity_ver.definition,CHR(10),' '),CHR(13),NULL) AS Table_Definition,
       Attribute_Ver.Sequence_Number AS Order_seq,
       Attribute_Ver.Column_Name AS Column_Name,
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
WHERE (Entity.Latest_Version_ID = Entity_Ver.Entity_Ver_ID 
        AND Model.Model_ID = Entity.Model_ID 
        AND SubModel.Latest_Version_ID = SubModel_Ver.SubModel_Ver_ID 
        AND Model.Model_ID = SubModel.Model_ID 
        AND Diagram_Ver.Diagram_ID = Model.Diagram_ID 
        AND model.latest_version_id = model_ver.model_ver_id AND Diagram.Latest_Version_ID = Diagram_Ver.Diagram_Ver_ID 
        AND Diagram.is_deleted = 0 AND Attribute_Ver.Attribute_Ver_ID = Attribute.Latest_Version_ID 
        AND Attribute.Entity_ID = Entity.Entity_ID
       )
),
relations_child as (
SELECT r.RELATIONSHIP_ID,
       r.MODEL_ID,
       r.PARENT_ENTITY_ID,
       r.CHILD_ENTITY_ID,
       ep.table_name as parent_table,
       ec.table_name as child_table,
       rv.INVERSEPHRASEID,
       rv.VERBPHRASEID,
       rv.NAME,
       rv.PARENTCARDINALITYNO,
       rv.CHILDOPTIONALITYID,
       row_number() over(partition by r.MODEL_ID, ec.table_name order by r.RELATIONSHIP_ID) rn_rel
FROM app_erstudio.RELATIONSHIP r
left join
 (
  Select e.ENTITY_ID, ev.table_name from app_erstudio.Entity e  
  left join app_erstudio.Entity_ver ev on (e.ENTITY_ID = ev.ENTITY_ID and e.LATEST_VERSION_ID = ev.ENTITY_VER_ID) 
) ec on (ec.ENTITY_ID = r.CHILD_ENTITY_ID)
left join 
 (
  Select e.ENTITY_ID, ev.table_name from app_erstudio.Entity e  
  left join app_erstudio.Entity_ver ev on (e.ENTITY_ID = ev.ENTITY_ID and e.LATEST_VERSION_ID = ev.ENTITY_VER_ID) 
) ep on (ep.ENTITY_ID = r.PARENT_ENTITY_ID)
inner join app_erstudio.RELATIONSHIP_VER rv 
  on (rv.RELATIONSHIP_VER_ID = r.LATEST_VERSION_ID and r.RELATIONSHIP_ID = rv.RELATIONSHIP_ID)
),
relations_par as (
SELECT r.RELATIONSHIP_ID,
       r.MODEL_ID,
       r.PARENT_ENTITY_ID,
       r.CHILD_ENTITY_ID,
       ep.table_name as parent_table,
       ec.table_name as child_table,
       rv.INVERSEPHRASEID,
       rv.VERBPHRASEID,
       rv.NAME,
       rv.PARENTCARDINALITYNO,
       rv.CHILDOPTIONALITYID,
       row_number() over(partition by r.MODEL_ID, ep.table_name order by r.RELATIONSHIP_ID) rn_rel
FROM app_erstudio.RELATIONSHIP r
left join 
 (
  Select e.ENTITY_ID, ev.table_name from app_erstudio.Entity e  
  left join app_erstudio.Entity_ver ev on (e.ENTITY_ID = ev.ENTITY_ID and e.LATEST_VERSION_ID = ev.ENTITY_VER_ID) 
) ep on (ep.ENTITY_ID = r.PARENT_ENTITY_ID)
left join
 (
  Select e.ENTITY_ID, ev.table_name from app_erstudio.Entity e  
  left join app_erstudio.Entity_ver ev on (e.ENTITY_ID = ev.ENTITY_ID and e.LATEST_VERSION_ID = ev.ENTITY_VER_ID) 
) ec on (ec.ENTITY_ID = r.CHILD_ENTITY_ID)
inner join app_erstudio.RELATIONSHIP_VER rv 
  on (rv.RELATIONSHIP_VER_ID = r.LATEST_VERSION_ID and r.RELATIONSHIP_ID = rv.RELATIONSHIP_ID)
)
Select distinct tc.* , rchild.PARENT_TABLE, rchild.CHILDOPTIONALITYID as cardi_cihld, rchild.NAME as constR_name_child,'<<--Children ended-->>' child_ended, rpar.CHILD_TABLE, rpar.NAME as constr_name_par, rpar.CHILDOPTIONALITYID as cardi_par, rchild.rn_rel, rpar.rn_rel
 from table_cols tc
left outer join relations_child rchild on (
tc.Table_Name =  rchild.child_table
and tc.model_id = rchild.Model_ID
and tc.ORDER_SEQ = rchild.rn_rel
)
left outer join relations_par rpar on (
tc.Table_Name =  rpar.parent_table
and tc.model_id = rpar.Model_ID
and tc.ORDER_SEQ = rpar.rn_rel
)
where 1=1 
AND   tc.Diagram_Name LIKE '%RRS%'
AND   tc.Model_Name = 'Physical'
AND   tc.Table_Name = 'ROAD_APPLICATION'
ORDER BY tc.TABLE_NAME,
         tc.ORDER_SEQ,
         rchild.rn_rel,
         rpar.rn_rel
         ;
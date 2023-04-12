SELECT COUNT(*)
  FROM dba_objects do
 WHERE do.object_type IN ('TABLE','VIEW','MATERIALIZED VIEW');
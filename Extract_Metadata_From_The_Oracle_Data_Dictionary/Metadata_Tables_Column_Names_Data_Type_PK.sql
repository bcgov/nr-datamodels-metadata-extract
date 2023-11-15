--SQL to pull metadata for column names, data types,primary keys, foreign keys, column position and column comments i.e. definitions.
select col.owner as schema_name,
       col.table_name, 
       col.column_name, 
       col.data_type,
       decode(char_length, 
              0, data_type,
              data_type || '(' || char_length || ')') as data_type_ext,
       col.data_length, 
       col.data_precision,  
       col.data_scale,  
       col.nullable, 
       col.data_default as default_value,
       col.COLUMN_ID Column_position,
       nvl(pk.primary_key, ' ') as primary_key, 
        nvl(fk.foreign_key, ' ') as foreign_key, 

       comm.comments
  from all_tables tab
       inner join all_tab_columns col 
           on col.owner = tab.owner 
          and col.table_name = tab.table_name          
       left join all_col_comments comm
           on col.owner = comm.owner
          and col.table_name = comm.table_name 
          and col.column_name = comm.column_name 
  left join (select constr.owner, 
                         col_const.table_name, 
                         col_const.column_name, 
                         'PK' primary_key
                    from all_constraints constr 
                         inner join all_cons_columns col_const
                             on constr.constraint_name = col_const.constraint_name 
                            and col_const.owner = constr.owner
                   where constr.constraint_type = 'P') pk
           on col.table_name = pk.table_name 
          and col.column_name = pk.column_name
          and col.owner = pk.owner
left join (select constr.owner, 
                         col_const.table_name, 
                         col_const.column_name, 
                         'FK' foreign_key
                    from all_constraints constr
                         inner join all_cons_columns col_const
                             on constr.constraint_name = col_const.constraint_name 
                            and col_const.owner = constr.owner 
                   where constr.constraint_type = 'R'
                   group by constr.owner, 
                            col_const.table_name, 
                            col_const.column_name) fk
           on col.table_name = fk.table_name 
          and col.column_name = fk.column_name
          and col.owner = fk.owner
where tab.owner in ('WHSE_TANTALIS')
and tab.table_name  in ('TA_DISPOSITION_TRANSACTIONS','TA_DISPOSITIONS')
order by 1,2,col.COLUMN_ID;
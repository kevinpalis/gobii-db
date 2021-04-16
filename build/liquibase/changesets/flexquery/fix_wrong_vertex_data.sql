--liquibase formatted sql


--changeset kpalis:GP1-1744_fix_germplasm_type context:general splitStatements:false
--a very dumb mistake, this was initially set to 'germplasm' instead of 'cv'
update vertex set table_name = 'cv' where name = 'germplasm_type';
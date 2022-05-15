--liquibase formatted sql

--changeset kpalis:update_gobiidb_version_3 context:general splitStatements:false runOnChange:true
select * from setdatawarehouseversion('3.0');
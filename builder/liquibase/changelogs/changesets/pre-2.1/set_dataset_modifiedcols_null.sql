--liquibase formatted sql

--This is being done for the new dataset grid in the extractor UI to work

--changeset kpalis:GP1-1542_set_modifiedcols_null context:general splitStatements:false

--remove the default values from the modified columns first
alter table dataset alter column modified_date drop default;
alter table dataset alter column modified_by drop default;

--set the modified columns to null
update dataset set modified_date = null;
update dataset set modified_by = null;
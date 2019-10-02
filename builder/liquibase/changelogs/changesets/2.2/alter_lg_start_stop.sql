--liquibase formatted sql

--to support genetic maps
--changeset kpalis:alter_lg_start_stop context:general splitStatements:false runOnChange:false
ALTER TABLE linkage_group ALTER COLUMN start type NUMERIC(20,3) using start::numeric;
ALTER TABLE linkage_group ALTER COLUMN stop type NUMERIC(20,3) using stop::numeric;
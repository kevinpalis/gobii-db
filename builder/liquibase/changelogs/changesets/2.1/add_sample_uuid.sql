--liquibase formatted sql

--Adding column uuid to dnasample


--changeset kpalis:add_sample_uuid_col context:general splitStatements:false runOnChange:false
ALTER TABLE dnasample ADD COLUMN uuid text;
--update the existing data so we can add a not null constraint
UPDATE dnasample
  SET uuid = 'Pre-2.1_uuid_' || dnasample_id::text
  WHERE uuid IS NULL;
--add the not null and uniqueness constraints
ALTER TABLE dnasample ALTER COLUMN uuid SET NOT NULL;
ALTER TABLE dnasample ADD CONSTRAINT unique_dnasample_uuid UNIQUE ( uuid );

--NOTE: Functions will be added on a separate file that's already on a runOnChange=true.
-- This is an effort to consolidate and organize the many CRUD functions

/* 
  Set a default value to the status column for every table that has it
  	select 'ALTER TABLE ' || table_name || ' ALTER COLUMN ' || column_name || ' SET DEFAULT 1;'
	from information_schema.columns
	where column_name = 'status';
*/
--Column additons/modifications
ALTER TABLE germplasm ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE marker_group ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE platform ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE project ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE analysis ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE dnasample ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE experiment ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE mapset ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE marker ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE dataset ALTER COLUMN status SET DEFAULT 1;
ALTER TABLE mapset ALTER COLUMN status SET DEFAULT 1;

ALTER TABLE dataset_marker ADD COLUMN marker_idx integer;
ALTER TABLE dataset_dnarun ADD COLUMN dnarun_idx integer;

ALTER TABLE display add column rank integer;

/*
  Some tables are not consistent on the column type of created_by and modified_by.
  The following commands will fix that.
*/
 
ALTER TABLE dataset ALTER COLUMN created_by type integer using created_by::integer;
ALTER TABLE dataset ALTER COLUMN modified_by type integer using modified_by::integer;

ALTER TABLE marker_group ALTER COLUMN created_by type integer using created_by::integer;
ALTER TABLE marker_group ALTER COLUMN modified_by type integer using modified_by::integer;

ALTER TABLE platform ALTER COLUMN created_by type integer using created_by::integer;
ALTER TABLE platform ALTER COLUMN modified_by type integer using modified_by::integer;

--to support genetic maps
ALTER TABLE marker_linkage_group ALTER COLUMN start type DECIMAL(13,3);
ALTER TABLE marker_linkage_group ALTER COLUMN stop type DECIMAL(13,3);
--because we can't convert text[] to jsonb
ALTER TABLE marker DROP COLUMN probsets;
ALTER TABLE marker ADD COLUMN probsets jsonb;

--Constraint additions/modifications
--compound-unique constraint on the project table for pi contact (i.e., principle investigator user id) and project name.
ALTER TABLE project ADD CONSTRAINT pi_project_name_key UNIQUE (pi_contact, name);

-- compound unique: in the experiment table: name, projectid,platformid
ALTER TABLE experiment ADD CONSTRAINT name_project_id_platform_id_key UNIQUE (name, project_id, platform_id);
ALTER TABLE experiment ALTER COLUMN platform_id SET NOT NULL;

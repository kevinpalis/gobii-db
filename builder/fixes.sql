
/* 
  Set a default value to the status column for every table that has it
  	select 'ALTER TABLE ' || table_name || ' ALTER COLUMN ' || column_name || ' SET DEFAULT 1;'
	from information_schema.columns
	where column_name = 'status';
*/
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
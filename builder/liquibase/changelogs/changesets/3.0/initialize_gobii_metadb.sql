--liquibase formatted sql

--changeset kpalis:create_config_module context:meta_general splitStatements:false runOnChange:false
--This changeset will create the configuration module that will track all existing crops in a given GOBii instance

CREATE TABLE crop ( 
	id				serial not null,
	name			text not null,
	database_name	text not null,
	owner			text not null,
	creation_date	timestamp with time zone not null DEFAULT now(),
	CONSTRAINT pk_crop_id PRIMARY KEY ( id )
);

COMMENT ON TABLE crop IS 'This table keeps track of all the crops in this GDM instance.'
COMMENT ON COLUMN crop.name IS 'The name of the crop. Ex: maize'
COMMENT ON COLUMN crop.database_name IS 'The postgres database name for this crop. The convention is gobii_<crop_name>.'
COMMENT ON COLUMN crop.owner IS 'The postgres user that owns the crop database, typically, appuser.'
COMMENT ON COLUMN crop.creation_date IS 'This is the date the crop was created - it gets auto-filled by the current date when the row was inserted.'

CREATE TABLE template ( 
	id					serial not null,
	name				text not null,
	crop_id				integer,
	template			jsonb default '{}'::jsonb,
	description			text,
	creation_date		timestamp with time zone not null DEFAULT now(),
	CONSTRAINT pk_template_id PRIMARY KEY ( id )
);

COMMENT ON TABLE template IS 'This table contains the templates for all the types of files we support.'
COMMENT ON COLUMN template.name IS 'The name of the template. This should be descriptive enough to identify the kind of data it applies to.'
COMMENT ON COLUMN template.crop_id IS 'This identifies the crop this template applies to. Leave it empty if the template is generic and applies to all crops.'
COMMENT ON COLUMN template.template IS 'This is the json template.'
COMMENT ON COLUMN template.creation_date IS 'The date this template was created.'


CREATE TABLE job ( 
	id					serial not null,
	name				text not null,
	crop_id				integer not null,
	type_id				integer not null,
	status				integer not null,
	message				text,
	creation_date		timestamp with time zone not null DEFAULT now(),
	CONSTRAINT pk_job_id PRIMARY KEY ( id )
);

COMMENT ON TABLE job IS 'This table contains all jobs in the system along with their origin and status.'
COMMENT ON COLUMN job.name IS 'The name of the job. This can reflect the name of the job from an external system (ex. rabbitMQ) if needed.'
COMMENT ON COLUMN job.crop_id IS 'This identifies the crop this job is on.'
COMMENT ON COLUMN job.type_id IS 'This identifies the type of job, ex: loading, extraction, etc.'
COMMENT ON COLUMN job.status IS 'The current state of this job, ex: in_progress, success, fail.'
COMMENT ON COLUMN job.message IS 'A freetext field the application can use to store any custom status message. Ex. Failed with error code 123, Data loaded successfully at 11-11-21 19:00:01.'
COMMENT ON COLUMN job.creation_date IS 'The date this job was created.'


CREATE TABLE job_type ( 
	id					serial not null,
	name				text not null,
	description			text,
	CONSTRAINT pk_job_type_id PRIMARY KEY ( id )
);

COMMENT ON TABLE job_type IS 'This table contains all job types in the system, for example: data_loading, data_extraction.'
COMMENT ON COLUMN job_type.name IS 'The name of the job type, ex: loading, extraction'


CREATE TABLE status ( 
	id					serial not null,
	name				text not null,
	description			text,
	CONSTRAINT pk_status_id PRIMARY KEY ( id )
);

COMMENT ON TABLE status IS 'This table contains all the possible status of a job, for example: in_progress, success, failed.'
COMMENT ON COLUMN status.name IS 'The name of the status, ex: fail, success, in_progress, etc.'

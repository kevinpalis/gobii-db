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

CREATE TABLE template ( 
	id					serial not null,
	name				text not null,
	crop_id				integer not null,
	load_template		jsonb default '{}'::jsonb,
	extract_template	jsonb default '{}'::jsonb,
	creation_date		timestamp with time zone not null DEFAULT now(),
	CONSTRAINT pk_template_id PRIMARY KEY ( id )
);

COMMENT ON TABLE template IS 'This table contains all templates for all the types of files we support.'

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

CREATE TABLE job_type ( 
	id					serial not null,
	name				text not null,
	description			text,
	CONSTRAINT pk_job_type_id PRIMARY KEY ( id )
);

COMMENT ON TABLE job_type IS 'This table contains all job types in the system, for example: data_loading, data_extraction.'

CREATE TABLE status ( 
	id					serial not null,
	name				text not null,
	description			text,
	CONSTRAINT pk_status_id PRIMARY KEY ( id )
);

COMMENT ON TABLE status IS 'This table contains all the possible status of a job, for example: in_progress, success, failed.'


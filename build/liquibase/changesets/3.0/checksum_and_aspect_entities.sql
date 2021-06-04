--liquibase formatted sql

--changeset kpalis:create_config_template_module context:meta_general splitStatements:false runOnChange:false

#Create the checksum table
CREATE SEQUENCE "public".checksum_id_seq START WITH 1;

CREATE  TABLE "public".checksum ( 
	id                   integer NOT NULL DEFAULT nextval('checksum_id_seq'),
	file_name            text  NOT NULL ,
	md5_hash             uuid  NOT NULL ,
	load_date            timestamptz DEFAULT CURRENT_DATE NOT NULL ,
	CONSTRAINT pk_checksum_id PRIMARY KEY ( id )
 );

COMMENT ON TABLE "public".checksum IS 'This table stores MD5 checksums for easy and efficient duplicate checks. The checksums are updated every time a file is loaded to the system.';

COMMENT ON COLUMN "public".checksum.file_name IS 'Name of the file that was loaded to the system.';

COMMENT ON COLUMN "public".checksum.md5_hash IS 'The md5 checksum of the file. The data type uuid is perfectly suited as it only occupies 16 bytes as opposed to 37 bytes in RAM for the varchar or text representation. There are also a lot of convenient functions in postgres to operate on this field.';

COMMENT ON COLUMN "public".checksum.load_date IS 'The date the file was loaded to the system.';

#Modifications to the job table
ALTER TABLE "public".job ADD checksum_id integer;

COMMENT ON COLUMN "public".job.checksum_id IS 'For jobs that include files, this is a foreign key to the checksum table.';

ALTER TABLE "public".job ADD CONSTRAINT fk_job_checksum FOREIGN KEY ( checksum_id ) REFERENCES "public".checksum( id );

#Modifications to the template table
ALTER TABLE "public"."template" ADD aspect jsonb DEFAULT '{}'::jsonb;

COMMENT ON COLUMN "public"."template".aspect IS 'This is the json aspect file.';

ALTER TABLE "public"."template" DROP COLUMN "template";
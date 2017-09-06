--liquibase formatted sql

--### JOB TABLE, MODIFICATION TO THE DATASET TABLE, AND CORRESPONDING FUNCTIONS ###---

--changeset kpalis:create_job_table context:general splitStatements:false
CREATE TABLE job ( 
	job_id			serial not null,
	type_id			integer not null,
	payload_type_id	integer not null,
	status			integer not null,
	message			text,
	submitted_by	integer not null,
	submitted_date	timestamp with time zone not null DEFAULT now(),
	CONSTRAINT pk_job PRIMARY KEY ( job_id )
);

CREATE INDEX IF NOT EXISTS idx_job_type_id ON job ( type_id );
CREATE INDEX IF NOT EXISTS idx_job_payload_type_id ON job ( payload_type_id );
CREATE INDEX IF NOT EXISTS idx_job_status ON job ( status );
CREATE INDEX IF NOT EXISTS idx_job_submitted_by ON job ( submitted_by );
CREATE INDEX IF NOT EXISTS idx_job_submitted_date ON job ( submitted_date );

COMMENT ON TABLE job IS 'This table keeps track of all the data loading and extraction jobs.';

ALTER TABLE job ADD CONSTRAINT job_type_id_fk FOREIGN KEY ( type_id ) REFERENCES cv( cv_id );
ALTER TABLE job ADD CONSTRAINT job_payload_type_id_fk FOREIGN KEY ( payload_type_id ) REFERENCES cv( cv_id );
ALTER TABLE job ADD CONSTRAINT job_status_fk FOREIGN KEY ( status ) REFERENCES cv( cv_id );
ALTER TABLE job ADD CONSTRAINT job_submitted_by_fx FOREIGN KEY ( submitted_by ) REFERENCES contact( contact_id );

--changeset kpalis:crud_fxns_for_job context:general splitStatements:false
CREATE OR REPLACE FUNCTION createjob(_type_id integer, _payload_type_id integer, _status integer, _message text, _submitted_by integer, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
    BEGIN
        insert into job (type_id, payload_type_id, status, message, submitted_by)
          values (_type_id, _payload_type_id, _status, _message, _submitted_by);
        select lastval() into id;
    END;
$function$;

CREATE OR REPLACE FUNCTION updatejob(id integer, _type_id integer, _payload_type_id integer, _status integer, _message text, _submitted_by integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
    BEGIN
    update job set type_id=_type_id, payload_type_id=_payload_type_id, status=_status, message=_message, submitted_by=_submitted_by where job_id = id;
    END;
$function$;

CREATE OR REPLACE FUNCTION deletejob(id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
    BEGIN
    delete from job where job_id = id;
    return id;
    END;
$function$;


--changeset kpalis:add_dataset_job_link context:general splitStatements:false
ALTER TABLE dataset ADD COLUMN job_id integer;
ALTER TABLE dataset ADD CONSTRAINT dataset_job_id_fk FOREIGN KEY ( job_id ) REFERENCES job ( job_id );

--changeset kpalis:update_dataset_functions_w_jobid context:general splitStatements:false
DROP FUNCTION IF EXISTS createdataset(datasetname text, experimentid integer, callinganalysisid integer, datasetanalyses integer[], datatable text, datafile text, qualitytable text, qualityfile text, createdby integer, createddate date, modifiedby integer, modifieddate date, datasetstatus integer, typeid integer, OUT id integer);
CREATE OR REPLACE FUNCTION createdataset(datasetname text, experimentid integer, callinganalysisid integer, datasetanalyses integer[], datatable text, datafile text, qualitytable text, qualityfile text, createdby integer, createddate date, modifiedby integer, modifieddate date, datasetstatus integer, typeid integer, jobid integer, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
  BEGIN
    insert into dataset (experiment_id, callinganalysis_id, analyses, data_table, data_file, quality_table, quality_file, scores, created_by, created_date, modified_by, modified_date, status, type_id, name, job_id)
      values (experimentId, callinganalysisId, datasetAnalyses, dataTable, dataFile, qualityTable, qualityFile, '{}'::jsonb, createdBy, createdDate, modifiedBy, modifiedDate, datasetStatus, typeId, datasetName, jobid);
    select lastval() into id;
  END;
$function$;

DROP FUNCTION IF EXISTS updatedataset(id integer, datasetname text, experimentid integer, callinganalysisid integer, datasetanalyses integer[], datatable text, datafile text, qualitytable text, qualityfile text, createdby integer, createddate date, modifiedby integer, modifieddate date, datasetstatus integer, typeid integer);
CREATE OR REPLACE FUNCTION updatedataset(id integer, datasetname text, experimentid integer, callinganalysisid integer, datasetanalyses integer[], datatable text, datafile text, qualitytable text, qualityfile text, createdby integer, createddate date, modifiedby integer, modifieddate date, datasetstatus integer, typeid integer, jobid integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
   BEGIN
    update dataset set experiment_id=experimentId, callinganalysis_id=callinganalysisId, analyses=datasetAnalyses, data_table=dataTable, data_file=dataFile, quality_table=qualityTable, quality_file=qualityFile, scores='{}'::jsonb, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=datasetStatus, type_id=typeId, name=datasetName, job_id=jobid
     where dataset_id = id;
   END;
$function$;


/*
CVs to seed for the job table:
type_id
	load
	extract
	analysis
payload_type_id
	samples
	markers
	matrix
	marker_sample
	all_meta
status
	pending
	in_progress
	failed
	completed
*/
--changeset kpalis:job_module_seed_data context:general splitStatements:false
select * from createcvgroup('job_type', 'Types of jobs that will be tracked in the job table', 1);
select * from createCVinGroup('job_type',1,'load','A data loading job',1,null,null,1);
select * from createCVinGroup('job_type',1,'extract','A data extraction job',1,null,null,1);
select * from createCVinGroup('job_type',1,'analysis','A data analysis job',1,null,null,1);

select * from createcvgroup('payload_type', 'Types of payloads that will be tracked in the job table', 1);
select * from createCVinGroup('payload_type',1,'samples','Sample data',1,null,null,1);
select * from createCVinGroup('payload_type',1,'markers','Marker data',1,null,null,1);
select * from createCVinGroup('payload_type',1,'matrix','Matrix/genotype data',1,null,null,1);
select * from createCVinGroup('payload_type',1,'marker_samples','Sample data',1,null,null,1);
select * from createCVinGroup('payload_type',1,'all_meta','All meta data',1,null,null,1);

select * from createcvgroup('job_status', 'Status of jobs', 1);
select * from createCVinGroup('job_status',1,'pending','The job is pending.',1,null,null,1);
select * from createCVinGroup('job_status',1,'in_progress','The job is in progress.',1,null,null,1);
select * from createCVinGroup('job_status',1,'failed','The job has failed.',1,null,null,1);
select * from createCVinGroup('job_status',1,'completed','The job successfully finished.',1,null,null,1);


--changeset kpalis:utility_fxns_for_job_1 context:general splitStatements:false

CREATE OR REPLACE FUNCTION createjob(_type text, _payload_type text, _status text, _message text, _submitted_by integer, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
	DECLARE
        _type_id integer;
        _payload_type_id integer;
        _status_id integer;
    BEGIN
    	select cv_id into _type_id from cv where status=1 and term=_type;
    	select cv_id into _payload_type_id from cv where status=1 and term=_payload_type;
    	select cv_id into _status_id from cv where status=1 and term=_status;
        insert into job (type_id, payload_type_id, status, message, submitted_by)
          values (_type_id, _payload_type_id, _status_id, _message, _submitted_by);
        select lastval() into id;
    END;
$function$;
--select * from createjob('load', 'markers', 'pending', 'Hello world!', 1);

CREATE OR REPLACE FUNCTION updatejob(id integer, _type text, _payload_type text, _status text, _message text, _submitted_by integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
	DECLARE
        _type_id integer;
        _payload_type_id integer;
        _status_id integer;
    BEGIN
    	select cv_id into _type_id from cv where status=1 and term=_type;
    	select cv_id into _payload_type_id from cv where status=1 and term=_payload_type;
    	select cv_id into _status_id from cv where status=1 and term=_status;
    	update job set type_id=_type_id, payload_type_id=_payload_type_id, status=_status_id, message=_message, submitted_by=_submitted_by where job_id = id;
    END;
$function$;
--select * from updatejob(1, 'load', 'markers', 'in_progress', 'Hello running world!', 1);
---========================================================09052017=================================================================================
--changeset kpalis:add_job_status_per_Josh context:general splitStatements:false
--digest
select * from createCVinGroup('job_status',1,'validation','Instruction file validation.',1,null,null,1);
select * from createCVinGroup('job_status',1,'digest','Creating and storing digester files.',1,null,null,1);
select * from createCVinGroup('job_status',1,'transformation','Transforming the matrix files.',1,null,null,1);
select * from createCVinGroup('job_status',1,'metadata_load','Loading metadata files into postgres.',1,null,null,1);
select * from createCVinGroup('job_status',1,'matrix_load','Loading into HDF5 files.',1,null,null,1);

--failure
select * from createCVinGroup('job_status',1,'aborted','The file processing aborted before metadata load.',1,null,null,1);

--extract
select * from createCVinGroup('job_status',1,'metadata_extract','Pulling metadata information.',1,null,null,1);
select * from createCVinGroup('job_status',1,'matrix_extract','Pulling matrix data.',1,null,null,1);
select * from createCVinGroup('job_status',1,'final_assembly','Creating the output files.',1,null,null,1);
select * from createCVinGroup('job_status',1,'qc_processing','Processing a QC job.',1,null,null,1);

--changeset kpalis:streamlining_getting_cv_id context:general splitStatements:false
CREATE OR REPLACE FUNCTION getCvId(_term text, _groupname text, _grouptype integer, OUT cvid integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
    BEGIN
    	select cv.cv_id into cvid 
    	from cv inner join cvgroup cg on cv.cvgroup_id = cg.cvgroup_id
    	where cg.type=_grouptype
    	and cg.name=_groupname
    	and cv.term=_term;
    END;
$function$;
--usage: select * from getCvId('digest', 'job_status', 1);

----changeset kpalis:adding_job_name_col context:general splitStatements:false
ALTER TABLE job ADD COLUMN name text;
ALTER TABLE job ADD CONSTRAINT unique_job_name UNIQUE ( name );
CREATE INDEX IF NOT EXISTS idx_job_name ON job ( name );

--cleanup. It's a grand PITA to be maintaining more functions than I need to.
DROP FUNCTION IF EXISTS createjob(_type_id integer, _payload_type_id integer, _status integer, _message text, _submitted_by integer, OUT id integer);
DROP FUNCTION IF EXISTS updatejob(id integer, _type_id integer, _payload_type_id integer, _status integer, _message text, _submitted_by integer);

--changeset kpalis:updates_on_job_fxns_for_addedcol_cvids context:general splitStatements:false
DROP FUNCTION IF EXISTS createjob(_type text, _payload_type text, _status text, _message text, _submitted_by integer, OUT id integer);
CREATE OR REPLACE FUNCTION createjob(_name text, _type text, _payload_type text, _status text, _message text, _submitted_by integer, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
	DECLARE
        _type_id integer;
        _payload_type_id integer;
        _status_id integer;
    BEGIN
    	select cvid into _type_id from getCvId(_type, 'job_type', 1);
    	select cvid into _payload_type_id from getCvId(_payload_type, 'payload_type', 1);
    	select cvid into _status_id from getCvId(_status, 'job_status', 1);
        insert into job (type_id, payload_type_id, status, message, submitted_by, name)
          values (_type_id, _payload_type_id, _status_id, _message, _submitted_by, _name);
        select lastval() into id;
    END;
$function$;
--select * from createjob('job_with_a_name_1', 'load', 'samples', 'pending', 'Hello samples1!', 1);

DROP FUNCTION IF EXISTS updatejob(id integer, _type text, _payload_type text, _status text, _message text, _submitted_by integer);
CREATE OR REPLACE FUNCTION updatejob(id integer, _name text, _type text, _payload_type text, _status text, _message text, _submitted_by integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
	DECLARE
        _type_id integer;
        _payload_type_id integer;
        _status_id integer;
    BEGIN
    	select cvid into _type_id from getCvId(_type, 'job_type', 1);
    	select cvid into _payload_type_id from getCvId(_payload_type, 'payload_type', 1);
    	select cvid into _status_id from getCvId(_status, 'job_status', 1);
    	update job set type_id=_type_id, name=_name, payload_type_id=_payload_type_id, status=_status_id, message=_message, submitted_by=_submitted_by where job_id = id;
    END;
$function$;
--select * from updatejob(3, 'job_with_added_name_2','load', 'samples', 'completed', 'Hello samples updated!', 1);

--changeset kpalis:utility_fxns_for_job_2 context:general splitStatements:false
--utility fxn for usage of the below fxns
CREATE OR REPLACE FUNCTION getCvTerm(_cv_id integer, OUT cvterm text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
    BEGIN
    	select cv.term into cvterm 
    	from cv
    	where cv.cv_id=_cv_id;
    END;
$function$;

--getAllJobsByStatus
DROP FUNCTION IF EXISTS getAllJobsByStatus(_status text);
CREATE OR REPLACE FUNCTION getAllJobsByStatus(_status text)
  RETURNS table (job_id integer, name text, type text, payload_type text, message text, submitted_by text, submitted_date timestamp with time zone)
  LANGUAGE plpgsql
AS $function$
	DECLARE
        _status_id integer;
	BEGIN
		select cvid into _status_id from getCvId(_status, 'job_status', 1);
		RETURN QUERY 
		select j.job_id, j.name, getCvTerm(j.type_id), getCvTerm(j.payload_type_id), j.message, (select username from contact where contact_id=j.submitted_by), j.submitted_date
		from job j 
		where j.status = _status_id;
	END;
$function$;
--select * from getAllJobsByStatus('pending');

--possible TODOs
--getJobStatus
--getDatasetJobStatus

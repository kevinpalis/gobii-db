--liquibase formatted sql

--### Statistics functions for the job summary table ###---

--changeset kpalis:total_dnaruns_in_dataset context:general splitStatements:false
CREATE OR REPLACE FUNCTION getTotalDnarunsInDataset(_dataset_id text)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
  DECLARE
    total integer; 
  BEGIN
    select count(*) into total from dnarun where dataset_dnarun_idx ? _dataset_id;
    return total;
  END;
$BODY$;

--changeset kpalis:total_markers_in_dataset context:general splitStatements:false
CREATE OR REPLACE FUNCTION getTotalMarkersInDataset(_dataset_id text)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
  DECLARE
    total integer; 
  BEGIN
    select count(*) into total from marker where dataset_marker_idx ? _dataset_id;
    return total;
  END;
$BODY$;

--changeset kpalis:total_markers_in_dataset context:general splitStatements:false
CREATE VIEW jobs_summary AS
	select
		ds.dataset_id,
		ds.name as "datasetname",
		e.experiment_id,
		e.name as "experimentname",
		p.project_id as "projectid",
		p.name as "projectname",
		pr.protocol_id as "protocolid",
		pr.name as "protocolname",
		pl.platform_id as "platformid",
		pl.name as "platformname",
		ds.callinganalysis_id as "callinganalysisid",
		a.name as "callinganalysisname",
		c.contact_id as picontactid,
		c.email as piemail,
		ds.data_table,
		ds.data_file,
		ds.quality_table,
		ds.quality_file,
		ds.status,
		ds.created_by,
		ds.created_date,
		ds.modified_by,
		ds.modified_date,
		ds.analyses,
		ds.type_id as "datatypeid",
		getcvterm(ds.type_id) as datatypename,
		ds.job_id,
		j.status "jobstatusid",
		COALESCE(getcvterm(j.status), 'Unsubmitted') as jobstatusname,
		j.type_id "jobtypeid",
		COALESCE(getcvterm(j.type_id), 'n/a') as jobtypename,
		j.submitted_date as jobsubmitteddate,
		(select * from getTotalDnarunsInDataset(ds.dataset_id::text)) as totalsamples,
		(select * from getTotalMarkersInDataset(ds.dataset_id::text)) as totalmarkers
	from
		dataset ds 
		join experiment e on (ds.experiment_id = e.experiment_id) 
		join project p on (e.project_id = p.project_id) 
		join contact c on (p.pi_contact = c.contact_id) 
		left outer join job j on (ds.job_id = j.job_id) 
		left outer join vendor_protocol vp on (e.vendor_protocol_id = vp.vendor_protocol_id) 
		left outer join protocol pr on (vp.protocol_id = pr.protocol_id) 
		left outer join platform pl on (pr.platform_id = pl.platform_id) join analysis a on (ds.callinganalysis_id = a.analysis_id)
	order by
		j.submitted_date desc,
		lower( ds.name ) asc;
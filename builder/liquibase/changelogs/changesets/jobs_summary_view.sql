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

--changeset kpalis:v_jobs_summary context:general splitStatements:false
CREATE OR REPLACE VIEW v_jobs_summary AS
	select
		ds.dataset_id,
		ds.name as dataset_name,
		e.experiment_id,
		e.name as experiment_name,
		p.project_id as project_id,
		p.name as project_name,
		pr.protocol_id as protocol_id,
		pr.name as protocol_name,
		pl.platform_id as platform_id,
		pl.name as platform_name,
		ds.callinganalysis_id as calling_analysis_id,
		a.name as calling_analysis_name,
		c.contact_id as pi_contact_id,
		c.email as pi_email,
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
		ds.type_id as dataset_type_id,
		getcvterm(ds.type_id) as dataset_type_name,
		ds.job_id,
		j.status as job_status_id,
		COALESCE(getcvterm(j.status), 'Unsubmitted') as job_status_name,
		j.type_id as job_type_id,
		COALESCE(getcvterm(j.type_id), 'n/a') as job_type_name,
		j.submitted_date as job_submitted_date,
		(select * from getTotalDnarunsInDataset(ds.dataset_id::text)) as total_samples,
		(select * from getTotalMarkersInDataset(ds.dataset_id::text)) as total_markers
	from
		dataset ds 
		left join experiment e on (ds.experiment_id = e.experiment_id) 
		left join project p on (e.project_id = p.project_id) 
		left join contact c on (p.pi_contact = c.contact_id) 
		left join job j on (ds.job_id = j.job_id) 
		left join vendor_protocol vp on (e.vendor_protocol_id = vp.vendor_protocol_id) 
		left join protocol pr on (vp.protocol_id = pr.protocol_id) 
		left join platform pl on (pr.platform_id = pl.platform_id) 
		left join analysis a on (ds.callinganalysis_id = a.analysis_id)
	order by
		j.submitted_date desc,
		lower(ds.name) asc;



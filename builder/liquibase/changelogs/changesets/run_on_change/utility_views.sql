--liquibase formatted sql

--### Utility Views ###---

--this view is intended to always be used with a where clause
--changeset kpalis:view_for_markergroup_summary context:general splitStatements:false runOnChange:true
create or replace view v_marker_group_summary as
	select mg.marker_group_id, mg.name as marker_group_name, mg.germplasm_group, m.name as marker_name, p.name as platform, array_to_string(ARRAY(SELECT jsonb_array_elements_text(mg.value)), ',', '?') as favorable_alleles
	from marker m, platform p, (select marker_group_id, name, germplasm_group, (jsonb_each(markers)).* from marker_group) as mg
	where m.marker_id = mg.key::integer
	and p.platform_id = m.platform_id;

--changeset kpalis:view_for_dataset_summary context:general splitStatements:false runOnChange:true
drop view if exists v_dataset_summary;
create or replace view v_dataset_summary as
	select d.dataset_id, d.name as dataset_name, d.experiment_id, e.name as experiment_name, d.callinganalysis_id, a.name as callingnalysis_name, d.analyses, d.data_table, d.data_file, d.quality_table, d.quality_file, d.scores, c1.username created_by_username, d.created_date, c2.username as modified_by_username, d.modified_date, cv1.term as status_name, cv2.term as type_name, j.name as job_name, p.project_id, p.name as project_name, pi.contact_id as pi_id, pi.firstname as pi_firstname, pi.lastname as pi_lastname
	from dataset d 
	left join experiment e on d.experiment_id=e.experiment_id
	left join project p on p.project_id=e.project_id
	left join contact pi on pi.contact_id=p.pi_contact
	left join analysis a on a.analysis_id=d.callinganalysis_id
	left join contact c1 on c1.contact_id=d.created_by
	left join contact c2 on c2.contact_id=d.modified_by
	left join cv cv1 on cv1.cv_id=d.status
	left join cv cv2 on cv2.cv_id=d.type_id
	left join job j on j.job_id=d.job_id;

--#######!!!!
--NOTE: Do not make the mistake of adding another changeset tag in this file as it messes up the execution order in the changelog file. The above changesets show this mistake, although it is not affecting functionality since they are unrelated and both were delivered almost next to each other. However, there is the chance that adding changesets to any file meant to be ran 'onChange' on a much later date can render very unpredictable results on production systems.
-- Just append new functions at the bottom of this file.
-- This changeset is set to run on change. Liquibase will know when it needs to recreate these functions.

--changeset kpalis:utility_views_post1.4 context:general splitStatements:false runOnChange:true

drop view if exists v_marker_summary;
create or replace view v_marker_summary as
	SELECT m.marker_id, m.platform_id, p.name as platform_name, m.variant_id, m.name as marker_name, m.code, m.ref, m.alts, m.sequence, m.reference_id, r.name as reference_name, m.primers, m.strand_id, cv.term as strand_name, m.status, m.probsets, m.dataset_marker_idx, m.props, m.dataset_vendor_protocol
	FROM marker m
	left join platform p on m.platform_id=p.platform_id
	left join reference r on m.reference_id=r.reference_id
	left join cv on m.strand_id=cv.cv_id;




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
create or replace view v_dataset_summary as
	select d.dataset_id, d.name as dataset_name, d.experiment_id, e.name as experiment_name, d.callinganalysis_id, a.name as callingnalysis_name, d.analyses, d.data_table, d.data_file, d.quality_table, d.quality_file, d.scores, c1.username created_by_username, d.created_date, c2.username as modified_by_username, d.modified_date, cv1.term as status_name, cv2.term as type_name, j.name as job_name
	from dataset d 
	left join experiment e on d.experiment_id=e.experiment_id
	left join analysis a on a.analysis_id=d.callinganalysis_id
	left join contact c1 on c1.contact_id=d.created_by
	left join contact c2 on c2.contact_id=d.modified_by
	left join cv cv1 on cv1.cv_id=d.status
	left join cv cv2 on cv2.cv_id=d.type_id
	left join job j on j.job_id=d.job_id;
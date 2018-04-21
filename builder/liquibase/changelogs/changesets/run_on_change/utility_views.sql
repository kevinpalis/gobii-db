--liquibase formatted sql

--### Utility Views ###---

--this view is intended to always be used with a where clause
--changeset kpalis:view_for_markergroup_summary context:general splitStatements:false runOnChange:true
create or replace view v_marker_group_summary as
	select mg.marker_group_id, mg.name as marker_group_name, mg.germplasm_group, m.name as marker_name, p.name as platform, array_to_string(ARRAY(SELECT jsonb_array_elements_text(mg.value)), ',', '?') as favorable_alleles
	from marker m, platform p, (select marker_group_id, name, germplasm_group, (jsonb_each(markers)).* from marker_group) as mg
	where m.marker_id = mg.key::integer
	and p.platform_id = m.platform_id;



--liquibase formatted sql

--changeset kpalis:add_dataset_marker_idx context:general
alter table marker add column dataset_marker_idx jsonb default '{}'::jsonb;
--rollback alter table marker drop column dataset_marker_idx

--changeset kpalis:migrate_dataset_marker_data context:general
update marker m set dataset_marker_idx = dataset_marker_idx || ('{"'||dm.dataset_id::text||'": '||dm.marker_idx||'}')::jsonb
	from dataset_marker dm
	where m.marker_id = dm.marker_id
	and dm.marker_idx is not null;
--will see if rollback is needed here

--changeset kpalis:add_dataset_dnarun_idx context:general
alter table dnarun add column dataset_dnarun_idx jsonb default '{}'::jsonb;
--rollback alter table dnarun drop column dataset_dnarun_idx

--changeset kpalis:migrate_dataset_dnarun_data context:general
update dnarun d set dataset_dnarun_idx = dataset_dnarun_idx || ('{"'||dd.dataset_id::text||'": '||dd.dnarun_idx||'}')::jsonb
	from dataset_dnarun dd
	where d.dnarun_id = dd.dnarun_id
	and dd.dnarun_idx is not null;
--will see if rollback is needed here
--drop tables
--create indices

/*select m.dataset_marker_idx = m.dataset_marker_idx || ('{"'||dm.dataset_id::text||'": '||dm.marker_idx||'}')::jsonb
	from dataset_marker dm, marker m
	where m.marker_id = dm.marker_id
	and m.name = '10003037';

select ('{"'||dm.dataset_id::text||'": '||dm.marker_idx||'}')::jsonb
	from dataset_marker dm, marker m
	where m.marker_id = dm.marker_id
	and m.name = '10003037';

select m.marker_id, dm.dataset_marker_id, m.name, dm.dataset_id, dm.marker_idx
	from dataset_marker dm, marker m
	where m.marker_id = dm.marker_id
	and name = '10003037';

select * from marker where name = '10003037';*/
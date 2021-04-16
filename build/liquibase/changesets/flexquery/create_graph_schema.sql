--liquibase formatted sql

--GP1-1598: Representing graphs on our schema

--changeset kpalis:GP1-1598_vertex_and_edge context:general splitStatements:false
CREATE TABLE IF NOT EXISTS vertex ( 
	vertex_id		serial primary key,
	name			text not null,
	type_id			integer not null references cv(cv_id) on update cascade,
	table_name		text not null,
	data_loc		text not null,
	criterion		text,
	alias			text not null,
	relevance		integer not null, --1=marker, 2=dnarun, 3=both
	is_entry		boolean not null,
	UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS edge ( 
	edge_id			serial primary key,
	start_vertex	integer not null references vertex(vertex_id) on update cascade on delete cascade,
	end_vertex		integer not null references vertex(vertex_id) on update cascade on delete cascade,
	type_id			integer not null references cv(cv_id) on update cascade,
	criterion		text,
	UNIQUE (start_vertex, end_vertex) --no duplicate edges
);

create index typeof_vertex_idx on vertex(type_id);
create index vertex_name_idx on vertex(name);
create index entry_vertex_idx on vertex(is_entry);
create index start_vertex_idx on edge(start_vertex);
create index end_vertex_idx on edge(end_vertex);
create index typeof_edge_idx on edge(type_id);

alter table edge add constraint self_loops_check check (start_vertex <> end_vertex);


--changeset kpalis:GP1-1598_create_functions context:general splitStatements:false
CREATE OR REPLACE FUNCTION createVertex(_name text, _type_id integer, _table_name text, _data_loc text, _criterion text, _alias text, _relevance integer, _is_entry boolean, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
  BEGIN
    insert into vertex (name, type_id, table_name, data_loc, criterion, alias, relevance, is_entry)
      values (_name, _type_id, _table_name, _data_loc, _criterion, _alias, _relevance, _is_entry)
      on conflict (name) DO NOTHING;
    select lastval() into id;
  END;
$function$;


CREATE OR REPLACE FUNCTION createEdge(_start_vertex integer, _end_vertex  integer, _type_id integer, _criterion text, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
  BEGIN
    insert into edge (start_vertex, end_vertex, type_id, criterion)
      values (_start_vertex, _end_vertex, _type_id, _criterion)
      on conflict (start_vertex, end_vertex) DO NOTHING;
    select lastval() into id;
  END;
$function$;

--changeset kpalis:GP1-1598_create_graph_data context:general splitStatements:false
--CV data
select * from createCvgroup('vertex_type', 'Types of entity (vertex) representations that we have in this schema.', 1);
select * from createCvInGroup('vertex_type',1,'standard','The typical relational database representation of entities (ie. table.column)',1,null,null,(select cvid from getCvId('new','status', 1)));
select * from createCvInGroup('vertex_type',1,'standard_subset','The entity being represented is a sub-category of the table, ie. with a filter. ex. PI is a Contact where role=PI',1,null,null,(select cvid from getCvId('new','status', 1)));
select * from createCvInGroup('vertex_type',1,'cv_subset','The entity is represented by a CV group. For example, a dataset type or a mapset type.',1,null,null,(select cvid from getCvId('new','status', 1)));
select * from createCvInGroup('vertex_type',1,'key_value_pair','The representation of property values as key-value pairs in JSONB. Ex {trial_name:"Trial 1"}.',1,null,null,(select cvid from getCvId('new','status', 1)));

select * from createCvgroup('edge_type', 'Types of edge representations that we have in this schema. The join criteria are dictated by this.', 1);
select * from createCvInGroup('edge_type',1,'standard','The typical relational database representation of relationships (ie. table1.column=table2.column)',1,null,null,(select cvid from getCvId('new','status', 1)));
select * from createCvInGroup('edge_type',1,'cv_subset','The relationship is represented by a CV group. This is usually used for entity types.',1,null,null,(select cvid from getCvId('new','status', 1)));
select * from createCvInGroup('edge_type',1,'key_value_pair','The representation of property values as key-value pairs in JSONB. Ex {trial_name:"Trial 1"}.',1,null,null,(select cvid from getCvId('new','status', 1)));

--vertex data
select * from createVertex('principal_investigator',(select cvid from getCvId('standard_subset','vertex_type', 1)),'contact','firstname, lastname','(select role_id from role where role_name=''PI'') = any(pi.roles)','pi',3,'true');
select * from createVertex('project',(select cvid from getCvId('standard','vertex_type', 1)),'project','name',NULL,'p',3,'true');
select * from createVertex('sampling_date',(select cvid from getCvId('key_value_pair','vertex_type', 1)),'project','props->getCvId(''date_sampled'', ''project_prop'', 1)::text','props?getCvId(''date_sampled'', ''project_prop'', 1)::text','sd',3,'true');
select * from createVertex('genotyping_purpose',(select cvid from getCvId('key_value_pair','vertex_type', 1)),'project','props->getCvId(''genotyping_purpose'', ''project_prop'', 1)::text','props?getCvId(''genotyping_purpose'', ''project_prop'', 1)::text','gp',3,'true');
select * from createVertex('division',(select cvid from getCvId('key_value_pair','vertex_type', 1)),'project','props->getCvId(''division'', ''project_prop'', 1)::text','props?getCvId(''division'', ''project_prop'', 1)::text','dv',3,'true');
select * from createVertex('trial_name',(select cvid from getCvId('key_value_pair','vertex_type', 1)),'dnasample','props->getCvId(''trial_name'', ''dnasample_prop'', 1)::text','props?getCvId(''trial_name'', ''dnasample_prop'', 1)::text','tn',2,'true');
select * from createVertex('experiment',(select cvid from getCvId('standard','vertex_type', 1)),'experiment','name',NULL,'e',3,'true');
select * from createVertex('dataset',(select cvid from getCvId('standard','vertex_type', 1)),'dataset','name',NULL,'d',3,'true');
select * from createVertex('dataset_type',(select cvid from getCvId('cv_subset','vertex_type', 1)),'cv','term','cvgroup_id=getCvGroupId(''dataset_type'',1)','dt',3,'true');
select * from createVertex('analysis',(select cvid from getCvId('standard','vertex_type', 1)),'analysis','name',NULL,'a',3,'true');
select * from createVertex('analysis_type',(select cvid from getCvId('cv_subset','vertex_type', 1)),'cv','term','cvgroup_id=getCvGroupId(''analysis_type'',1)','at',3,'true');
select * from createVertex('reference_sample',(select cvid from getCvId('key_value_pair','vertex_type', 1)),'dnasample','props->getCvId(''ref_sample'', ''dnasample_prop'', 1)::text','props?getCvId(''ref_sample'', ''dnasample_prop'', 1)::text','rs',2,'true');
select * from createVertex('marker',(select cvid from getCvId('standard','vertex_type', 1)),'marker','name',NULL,'m',1,'false');
select * from createVertex('platform',(select cvid from getCvId('standard','vertex_type', 1)),'platform','name',NULL,'pl',1,'true');
select * from createVertex('vendor',(select cvid from getCvId('standard','vertex_type', 1)),'organization','name',NULL,'v',1,'true');
select * from createVertex('protocol',(select cvid from getCvId('standard','vertex_type', 1)),'protocol','name',NULL,'pr',1,'true');
select * from createVertex('vendor_protocol',(select cvid from getCvId('standard','vertex_type', 1)),'vendor_protocol','name',NULL,'vp',1,'true');
select * from createVertex('marker_linkage_group',(select cvid from getCvId('standard','vertex_type', 1)),'marker_linkage_group','linkage_group_id, marker_id',NULL,'mlg',1,'false');
select * from createVertex('mapset',(select cvid from getCvId('standard','vertex_type', 1)),'mapset','name',NULL,'mp',1,'true');
select * from createVertex('mapset_type',(select cvid from getCvId('cv_subset','vertex_type', 1)),'cv','term','cvgroup_id=getCvGroupId(''mapset_type'',1)','mt',1,'true');
select * from createVertex('linkage_group',(select cvid from getCvId('standard','vertex_type', 1)),'linkage_group','name',NULL,'lg',1,'true');
select * from createVertex('germplasm_subspecies',(select cvid from getCvId('key_value_pair','vertex_type', 1)),'germplasm','props->getCvId(''germplasm_subsp'', ''germplasm_prop'', 1)::text','props?getCvId(''germplasm_subsp'', ''germplasm_prop'', 1)::text','gss',2,'true');
select * from createVertex('dnasample',(select cvid from getCvId('standard','vertex_type', 1)),'dnasample','name',NULL,'ds',2,'false');
select * from createVertex('germplasm',(select cvid from getCvId('standard','vertex_type', 1)),'germplasm','name',NULL,'g',2,'false');
select * from createVertex('germplasm_species',(select cvid from getCvId('key_value_pair','vertex_type', 1)),'germplasm','props->getCvId(''germplasm_species'', ''germplasm_prop'', 1)::text','props?getCvId(''germplasm_species'', ''germplasm_prop'', 1)::text','gs',2,'true');
select * from createVertex('germplasm_type',(select cvid from getCvId('cv_subset','vertex_type', 1)),'germplasm','term','cvgroup_id=getCvGroupId(''germplasm_type'',1)','gt',2,'true');
select * from createVertex('dnarun',(select cvid from getCvId('standard','vertex_type', 1)),'dnarun','name',NULL,'dr',2,'false');

--edge data
select * from createEdge(1,2,(select cvid from getCvId('standard','edge_type', 1)),'contact_id=pi_contact');
select * from createEdge(2,3,(select cvid from getCvId('key_value_pair','edge_type', 1)),NULL);
select * from createEdge(2,4,(select cvid from getCvId('key_value_pair','edge_type', 1)),NULL);
select * from createEdge(2,5,(select cvid from getCvId('key_value_pair','edge_type', 1)),NULL);
select * from createEdge(2,7,(select cvid from getCvId('standard','edge_type', 1)),'project_id=project_id');
select * from createEdge(7,8,(select cvid from getCvId('standard','edge_type', 1)),'experiment_id=experiment_id');
select * from createEdge(8,27,(select cvid from getCvId('key_value_pair','edge_type', 1)),'dataset_dnarun_idx?dataset_id::text');
select * from createEdge(8,13,(select cvid from getCvId('key_value_pair','edge_type', 1)),'dataset_marker_idx?dataset_id::text');
select * from createEdge(9,8,(select cvid from getCvId('cv_subset','edge_type', 1)),'cv_id=type_id');
select * from createEdge(10,8,(select cvid from getCvId('standard','edge_type', 1)),'analysis_id=callinganalysis_id');
select * from createEdge(11,10,(select cvid from getCvId('cv_subset','edge_type', 1)),'cv_id=type_id');
select * from createEdge(13,18,(select cvid from getCvId('standard','edge_type', 1)),'marker_id=marker_id');
select * from createEdge(14,13,(select cvid from getCvId('standard','edge_type', 1)),'platform_id=platform_id');
select * from createEdge(14,16,(select cvid from getCvId('standard','edge_type', 1)),'platform_id=platform_id');
select * from createEdge(15,17,(select cvid from getCvId('standard','edge_type', 1)),'organization_id=vendor_id');
select * from createEdge(16,17,(select cvid from getCvId('standard','edge_type', 1)),'protocol_id=protocol_id');
select * from createEdge(17,7,(select cvid from getCvId('standard','edge_type', 1)),'vendor_protocol_id=vendor_protocol_id');
select * from createEdge(19,21,(select cvid from getCvId('standard','edge_type', 1)),'mapset_id=map_id');
select * from createEdge(20,19,(select cvid from getCvId('cv_subset','edge_type', 1)),'cv_id=type_id');
select * from createEdge(21,18,(select cvid from getCvId('standard','edge_type', 1)),'linkage_group_id=linkage_group_id');
select * from createEdge(23,6,(select cvid from getCvId('key_value_pair','edge_type', 1)),NULL);
select * from createEdge(23,12,(select cvid from getCvId('key_value_pair','edge_type', 1)),NULL);
select * from createEdge(23,27,(select cvid from getCvId('standard','edge_type', 1)),'dnasample_id=dnasample_id');
select * from createEdge(24,22,(select cvid from getCvId('key_value_pair','edge_type', 1)),NULL);
select * from createEdge(24,23,(select cvid from getCvId('standard','edge_type', 1)),'germplasm_id=germplasm_id');
select * from createEdge(24,25,(select cvid from getCvId('key_value_pair','edge_type', 1)),NULL);
select * from createEdge(26,24,(select cvid from getCvId('cv_subset','edge_type', 1)),'cv_id=type_id');

--changeset kpalis:GP1-1598_transitive_closure context:general splitStatements:false
drop table if exists transitive_closure;

create table transitive_closure as
	with recursive r_transitive_closure (start_vertex, end_vertex, distance, path_string) as
	(
		select start_vertex, end_vertex, 1 as distance, '.' || start_vertex || '.' || end_vertex || '.' as path_string
		from edge
		union all
		select tc.start_vertex, e.end_vertex, tc.distance + 1, tc.path_string || e.end_vertex || '.' as path_string
		from edge as e
			join r_transitive_closure as tc
			on e.start_vertex = tc.end_vertex
		where tc.path_string not like '%.' || e.end_vertex || '.%'
	)
	select * from r_transitive_closure
	order by start_vertex, end_vertex, distance;

--86 rows. Created successfully in 31 msec.
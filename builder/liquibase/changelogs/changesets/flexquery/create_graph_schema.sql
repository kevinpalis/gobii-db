--liquibase formatted sql

--GP1-1598: Representing graphs on our schema

--changeset kpalis:GP1-1598_vertex_and_edge context:general splitStatements:false
CREATE TABLE vertex ( 
	vertex_id		serial primary key,
	name			text not null,
	type_id			integer not null,
	table_name		text not null,
	data_loc		text not null,
	criterion		text,
	alias			text not null,
	relevance		integer not null, --1=marker, 2=dnarun, 3=both
	is_entry		boolean not null
);

CREATE TABLE edge ( 
	edge_id			serial primary key,
	start_vertex	integer not null references vertex(vertex_id) on update cascade on delete cascade,
	end_vertex		integer not null references vertex(vertex_id) on update cascade on delete cascade,
	type_id			integer not null,
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

--changeset kpalis:GP1-1598_create_functions context:general splitStatements:false
CREATE OR REPLACE FUNCTION createVertex(_name text, _type text, _table_name text, _data_loc text, _criterion text, _alias text, _relevance integer, _is_entry boolean, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
  BEGIN
    insert into contact (lastname, firstname, code, email, roles, created_by, created_date, modified_by, modified_date, organization_id, username)
      values (lastName, firstName, contactCode, contactEmail, contactRoles, createdBy, createdDate, modifiedBy, modifiedDate, organizationId, uname)
      on conflict (username) DO NOTHING;
    select lastval() into id;
  END;
$function$;

--vertex data

--edge data


--changeset kpalis:GP1-1598_transitive_closure context:general splitStatements:false
create table transitive_closure as
	with recursive r_transitive_closure (start_vertex, end_vertex, distance, path_string) as
	(
		select start_vertex, end_vertex, 1 as distance, '.' || start_vertex || '.' || end_vertex || '.' as path_string
		from edge
		from edge as e
			join r_transitive_closure as tc
			on e.start_vertex = tc.end_vertex
		where tc.path_string not like '%.' || edge.end_vertex || '.%'
	)
	select * from r_transitive_closure
	order by start_vertex, end_vertex, distance;


--transitive_closure (start, end, hops, path)

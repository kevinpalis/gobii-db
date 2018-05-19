--liquibase formatted sql

--GP1-1598: Representing graphs on our schema

--changeset kpalis:GP1-1598_graph_schema context:general splitStatements:false
CREATE TABLE vertex ( 
	vertex_id		serial primary key,
	type_id			integer not null,
	name			text not null,
	table_name		text not null,
	criterion		text,
	UNIQUE (name)
);

CREATE TABLE edge ( 
	edge_id			serial primary key,
	start_vertex	integer not null references vertex(vertex_id) on update cascade on delete cascade,
	end_vertex		integer not null references vertex(vertex_id) on update cascade on delete cascade,
	type_id			integer not null,
	criterion		text not null,
	UNIQUE (start_vertex, end_vertex) --no duplicate edges
);

create index typeof_vertex_idx on vertex(type_id);
create index vertex_name_idx on vertex(name);
create index start_vertex_idx on edge(start_vertex);
create index end_vertex_idx on edge(end_vertex);
create index typeof_edge_idx on edge(type_id);

alter table edge add constraint self_loops_check check (start_vertex <> end_vertex);


--changeset kpalis:create_cvs_for_flex_query context:general splitStatements:false
select * from createcvgroup('vertex_type', 'Types of entity (vertex) representations that we have in this schema.', 1);
select * from createCVinGroup('vertex_type',1,'standard','The typical relational database representation of entities (ie. table.column)',1,null,null,<get cv where term=new>);
select * from createCVinGroup('vertex_type',1,'standard_subset','The entity being represented is a sub-category of the table, ie. with a filter. ex. PI is a Contact where role=PI',1,null,null,1);
select * from createCVinGroup('vertex_type',1,'cv_subset','The entity is represented by a CV group. For example, a dataset type or a mapset type.',1,null,null,1);
select * from createCVinGroup('vertex_type',1,'key_value_pair','The representation of property values as key-value pairs in JSONB. Ex {trial_name:"Trial 1"}.',1,null,null,1);
/*
create or replace function createVertex(type)
--add an on conflict clause to the create contact function
CREATE OR REPLACE FUNCTION createcontact(lastname text, firstname text, contactcode text, contactemail text, contactroles integer[], createdby integer, createddate date, modifiedby integer, modifieddate date, organizationid integer, uname text, OUT id integer)
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
/*


Vertex:
vertex_id	|	entity_name	|	entity_type
1				Experiment		Standard
2				Dataset			Standard
3				Marker			Standard

Edge:
Subject_id	|	Object_id	|	type
1				2				Standard
2				3				KVP (jsonb)


A function will be implemented that computes for the SHORTEST PATH (using the transitive_closure table) between any given vertices A and B, such that:
shortest_path(1, 3) ---> will return 1->2->3 in the example above.

The library will then automatically generate the corresponding SQL call to generate the needed information required for the flex query. In the example above, it will be:

select marker_id
from experiment e, dataset d, marker m
where e.experiment_id=d.experiment_id
and m.dataset_marker_idx ? d.dataset_id::string;


--------------======A walk through the algorithm======----------------------
1. Given the set of nodes and edges below, a table transitive_closure (start, end, hops, path) will be computed

Vertex:
ID	|	Type				Table_name	|	Name		|	Criterion				|	Alias	|	Data_loc
1		standard_subset		Contact			PI				roles="PI"					c			contact.firstname || contact.lastname
2		standard			Project			Project			null						p			project.name
3		kvp					Project			date_sampled	props?"date_sampled"		p			project.props->'date_sampled'
4		standard			Experiment		Experiment		null						e			experiment.name
		
Edge:
ID	|	Start	|	End			|	Type		|	Criterion
1		PI			Project			Standard		contact.contact_id=project.pi_contact	
2		Project		date_sampled	KVP				null
3		Project		Experiment		Standard		project.project_id=experiment.project_id

2. A function that 

Walkthrough:
1.
Filter 1 (PI):
-- the getPath function returns null as this is the starting vertex
-- the dynamic query is then constructed based on the vertex alone

select c.firstname || c.lastname <-- vertex.data_loc
from contact as c		<-- vertex.table_name as vertex.alias
where c.roles has PI;	<-- vertex.criterion

-- the output is what will be displayed in the selector box
-- the query will run via psycopg2 and the result set will be written in a file

2.
--assuming user selected PI 1, 4, and 5
--getPath(1, 2) will hit the TC (transitive_closure) and return with path=1->2, which means there's a direct edge
--the dynamic query is then constructed based on the 2 vertices (1 and 2) and edge 1.

Filter 2 (PI->Project):
select p.name 		 <-- edge1.end's data_loc
from contact c, project p <-- vertex1.table_name as vertex1.alias, vertex2.table_name as vertex2.alias
where c.roles has PI <-- vertex1.criterion (a standard_subset type)
and p.pi_contact=c.contact_id <--- edge1.criterion
and c.contact_id in (1, 4, 5); <--- filter1's selection (passed in as a parameter)

-- same as above: the output is what will be displayed in the selector box
-- the query will run via psycopg2 and the result set will be written in a file

3.
--assuming user selected projects 9 and 15
--getPath({1,2}, 3) will hit the TC (transitive_closure) and return with path=1->2->3, the first parameter to get

Filter 3 (PI->Project->Date_sampled)
select p.props->'date_sampled'
from contact c, project p
where c.roles has PI
and p.pi_contact=c.contact_id
and c.contact_id in (1, 4, 5)
and p.project_id in (9, 15)
and p.props?'date_sampled';



1. Standard = The typical relational database representation of data (ie. table.column)
2. Standard Subset = same as 1, just with a filter (ie. Where clause)
3. CV Subset = set of CV terms filtered by group
4. KVP = acronym for key-value pair. This is our representation of property values. Ex {trial_name:"Trial 1"}*/
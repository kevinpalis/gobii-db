--liquibase formatted sql

--GP1-1598: Representing graphs on our schema

--changeset kpalis:GP1-1598_graph_schema context:general splitStatements:false
CREATE TABLE vertex ( 
	vertex_id		serial primary key,
	type_id			integer not null,
	name			text  not null
);

CREATE TABLE edge ( 
	edge_id			serial primary key,
	start_vertex	integer not null references vertex(vertex_id) on update cascade on delete cascade,
	end_vertex		integer not null references vertex(vertex_id) on update cascade on delete cascade,
	type_id			integer not null,
	criterion		text not null
);

/*
Updates on Datawarehouse Layer of Flex Query:

1. Directed Acyclic Graph (DAG) has been finalized. (see graph in Excel attached to the GR)
2. Representation of the graph in postgres:

Vertex:
vertex_id	|	entity_name	|	entity_type
1				Experiment		Standard
2				Dataset			Standard
3				Marker			Standard

Edge:
Subject_id	|	Object_id	|	type
1				2				Standard
2				3				KVP (jsonb)


Edges are not weighted. Also, the implied relationship is has_many. The transitive_closure will be pre-computed and stored in a separate table.


A function will be implemented that computes for the SHORTEST PATH (using the transitive_closure table) between any given vertices A and B, such that:
shortest_path(1, 3) ---> will return 1->2->3 in the example above.

The library will then automatically generate the corresponding SQL call to generate the needed information required for the flex query. In the example above, it will be:

select marker_id
from experiment e, dataset d, marker m
where e.experiment_id=d.experiment_id
and m.dataset_marker_idx ? d.dataset_id::string;


1. Standard = The typical relational database representation of data (ie. table.column)
2. Standard Subset = same as 1, just with a filter (ie. Where clause)
3. CV Subset = set of CV terms filtered by group
4. KVP = acronym for key-value pair. This is our representation of property values. Ex {trial_name:"Trial 1"}*/
--liquibase formatted sql

--changeset raza:getMarkerMapsetInfoByDataset context:general splitStatements:false
DROP FUNCTION IF EXISTS getMarkerMapsetInfoByDataset( integer, integer);

CREATE OR REPLACE FUNCTION getMarkerMapsetInfoByDataset(dsId integer,mapId integer)
RETURNS table (marker_id integer,marker_name text,linkage_group_name text,linkage_group_start integer,linkage_group_stop integer,mapset_name text,map_id integer) AS $$
BEGIN
	RETURN QUERY 
	with mlgt as (
		select mlg.marker_id, lg.name as linkage_group_name, lg.start as linkage_group_start,lg.start as linkage_group_stop,  mlg.start, mlg.stop, ms.name as mapset_name, lg.map_id
		from marker_linkage_group mlg
		left join linkage_group lg on lg.linkage_group_id = mlg.linkage_group_id
		left join mapset ms on ms.mapset_id = lg.map_id
		where lg.map_id = mapId
	)
	select m.marker_id, m.name,mlgt.linkage_group_name::text, mlgt.linkage_group_start, mlgt.linkage_group_stop,mlgt.mapset_name,mlgt.map_id
	from marker m
	left join mlgt on mlgt.marker_id = m.marker_id
	where m.dataset_marker_idx ? dsId::text
	order by m.dataset_marker_idx -> dsId::text;
END;
$$ LANGUAGE plpgsql;



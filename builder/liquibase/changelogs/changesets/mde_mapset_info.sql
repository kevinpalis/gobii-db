--liquibase formatted sql

--changeset raza:getMarkerMapsetInfoByDataset context:general splitStatements:false
DROP FUNCTION IF EXISTS getMarkerMapsetInfoByDataset( integer, integer);
-- This
CREATE OR REPLACE FUNCTION getMarkerMapsetInfoByDataset(dsId integer,mapId integer)
RETURNS table (marker_name text,platform text,linkage_group_name text,linkage_group_start integer,linkage_group_stop integer,marker_linkage_group_start integer,marker_linkage_group_stop integer,mapset_name text) AS $$
BEGIN
	RETURN QUERY 
	with mlgt as (
		select mlg.marker_id, lg.name as linkage_group_name, lg.start as lg_start,lg.start as lg_stop,  mlg.start, mlg.stop, ms.name as mapset_name
		from marker_linkage_group mlg
		left join linkage_group lg on lg.linkage_group_id = mlg.linkage_group_id
		left join mapset ms on ms.mapset_id = lg.map_id
		where lg.map_id = mapId
	)
	select m.name,p.name,mlgt.linkage_group_name::text, mlgt.lg_start, mlgt.lg_stop,mlgt.start::integer,mlgt.stop::integer,mlgt.mapset_name
	from marker m
	join platform p on p.platform_id = m.platform_id
	left join mlgt on mlgt.marker_id = m.marker_id
	where m.dataset_marker_idx ? dsId::text
	order by m.dataset_marker_idx -> dsId::text;
END;
$$ LANGUAGE plpgsql;






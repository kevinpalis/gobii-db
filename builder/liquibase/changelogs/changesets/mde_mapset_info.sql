--liquibase formatted sql

--changeset raza:getMarkerMapsetInfoByDataset context:general splitStatements:false
DROP FUNCTION IF EXISTS getMarkerMapsetInfoByDataset( integer, integer);

CREATE OR REPLACE FUNCTION getMarkerMapsetInfoByDataset(dsId integer,mapId integer)
RETURNS table (marker_name text,platform text,reference_name text, reference_version text,linkage_group_name text,linkage_group_start text,linkage_group_stop text,marker_linkage_group_start text,marker_linkage_group_stop text,mapset_name text) AS $$
BEGIN
	RETURN QUERY 
	with mlgt as (
			select distinct on (mlg.marker_id, mapset_id) mlg.marker_id, lg.name as linkage_group_name, lg.start as lg_start,lg.start as lg_stop,  mlg.start, mlg.stop,ms.mapset_id, ms.name as mapset_name
			from marker_linkage_group mlg
			left join linkage_group lg on lg.linkage_group_id = mlg.linkage_group_id
			left join mapset ms on ms.mapset_id = lg.map_id
			join marker mr on mr.marker_id = mlg.marker_id and mr.dataset_marker_idx ? dsId::text		
		)
		select m.name,p.name,r.name,r.version
			,COALESCE(t.lgn,mlgt.linkage_group_name::text) as lg_name 
			,COALESCE(t.lgst,mlgt.lg_start::text) as lg_start
			,COALESCE(t.lgsp,mlgt.lg_stop::text) as lg_stop
			,COALESCE(t.mlgst,mlgt.start::text) as mlg_start
			,COALESCE(t.mlgst,mlgt.stop::text) as mlg_stop
			, COALESCE(t.mpsn,mlgt.mapset_name) as mapset_name
		from marker m
		join platform p on p.platform_id = m.platform_id
		left join reference r on r.reference_id = m.reference_id
		left join mlgt on mlgt.marker_id = m.marker_id 
		left join (	
			select  ' '::text as lgn
				,' '::text as mpsn	
				,' '::text as lgst
				,' '::text as lgsp
				,' '::text as mlgst
				,' '::text as mlgsp			
		) t on mlgt.mapset_id != mapId
		where m.dataset_marker_idx ? dsId::text
		order by m.dataset_marker_idx -> dsId::text;
END;
$$ LANGUAGE plpgsql;





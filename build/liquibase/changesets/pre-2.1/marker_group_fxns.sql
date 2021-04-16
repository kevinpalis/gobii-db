--liquibase formatted sql

/*
* Marker Group CRUD functions
*/

--changeset kpalis:upsertMarkerGroup context:general splitStatements:false

--NOTE: Since JDBC still doesn't support jsonb as of the time I'm writing this, the markers parameter is of type text and is casted to jsonb in the function body. The expected format is your typical json (doh) of maker_id:[favorable_allele,...], ie. {"1":["A","C"], "4":["G"]}
--this is a prerequisite for the 'on conflict' clause
ALTER TABLE marker_group DROP CONSTRAINT IF EXISTS unq_markergrp_name;
ALTER TABLE marker_group ADD CONSTRAINT unq_markergrp_name UNIQUE (name);

DROP FUNCTION IF EXISTS upsertMarkerGroup(name text, code text, markers text, germplasm_group text, created_by integer, created_date date, modified_by integer, modified_date date, status integer, OUT id integer);
CREATE OR REPLACE FUNCTION upsertMarkerGroup(_name text, _code text, _markers text, _germplasm_group text, _created_by integer, _created_date date, _modified_by integer, _modified_date date, _status integer, OUT id integer)
  RETURNS integer
  LANGUAGE plpgsql
 AS $function$
   BEGIN
     insert into marker_group (name, code, markers, germplasm_group, created_by, created_date, modified_by, modified_date, status)
      values (_name, _code, _markers::jsonb, _germplasm_group, _created_by, _created_date, _modified_by, _modified_date, _status)
      on CONFLICT (name) do UPDATE
      	set name=_name, code=_code, markers=_markers::jsonb, germplasm_group=_germplasm_group, created_by=_created_by, created_date=_created_date, modified_by=_modified_by, modified_date=_modified_date, status=_status;
    select marker_group_id from marker_group where name=_name into id;
   END;
 $function$;

--sample usage: select upsertMarkerGroup('MGroup1', 'mgroup1_code', '{"1":["A","C"], "4":["G"]}', 'germplasmGroup1', 1, CURRENT_DATE, 1, CURRENT_DATE, 1);
--select * from upsertMarkerGroup('MGroup4', 'mgroup4_code', '{"10":["C","T"], "4":["G"],"190":["G"] }', 'germplasmGroup1', 1, CURRENT_DATE, 1, CURRENT_DATE, 1);

--TODO: Functions for querying favorable alleles
--Reference queries:
--select jsonb_array_elements(value) from (select (jsonb_each(markers)).* from marker_group where name='MGroup1') fa where key='1';
--select jsonb_array_elements_text(value) from (select (jsonb_each(markers)).* from marker_group where name='MGroup1') fa where key='1';

--changeset kpalis:deleteMarkerGroupByName context:general splitStatements:false
DROP FUNCTION IF EXISTS deleteMarkerGroupByName(_name text);
CREATE OR REPLACE FUNCTION deleteMarkerGroupByName(_name text)
RETURNS integer AS $$
	DECLARE
        i integer;
    BEGIN
    	delete from marker_group where name = _name;
    	GET DIAGNOSTICS i = ROW_COUNT;
      	return i;
    END;
$$ LANGUAGE plpgsql;

--changeset kpalis:updateMarkerGroupName context:general splitStatements:false
DROP FUNCTION IF EXISTS updateMarkerGroupName(_id integer, _name text);
CREATE OR REPLACE FUNCTION updateMarkerGroupName(_id integer, _name text)
RETURNS integer AS $$
	DECLARE
        i integer;
    BEGIN
    	update marker_group set name=_name
     	where marker_group_id = _id;
     	GET DIAGNOSTICS i = ROW_COUNT;
      	return i;
    END;
$$ LANGUAGE plpgsql;

--changeset kpalis:getAllMarkersInMarkerGroups context:general splitStatements:false
DROP FUNCTION IF EXISTS getAllMarkersInMarkerGroups(_nameList text);
CREATE OR REPLACE FUNCTION  getAllMarkersInMarkerGroups(_nameList text)
RETURNS table (marker_group_name text, marker_id text, favorable_alleles text) AS $$
  BEGIN
    return query
    select mgl.group_name, (jsonb_each_text(mg.markers)).*
    from unnest(_nameList::text[]) mgl(group_name) --implicit lateral join
    left join marker_group mg on mgl.group_name = mg.name;
  END;
$$ LANGUAGE plpgsql;
-- Sample usage: select * from getallmarkersinmarkergroups('{MGroup1, MGroup2}');

--changeset kpalis:getAllMarkersInMarkerGroupsById context:general splitStatements:false
DROP FUNCTION IF EXISTS getAllMarkersInMarkerGroupsById(_idList text);
CREATE OR REPLACE FUNCTION  getAllMarkersInMarkerGroupsById(_idList text)
RETURNS table (marker_group_id integer, marker_group_name text, marker_id text, favorable_alleles text) AS $$
  BEGIN
    return query
    select mg.marker_group_id, mg.name, (jsonb_each_text(mg.markers)).*
    from unnest(_idList::text[]) mgl(marker_group_id)
    left join marker_group mg on mgl.marker_group_id::integer = mg.marker_group_id;
  END;
$$ LANGUAGE plpgsql;
-- Sample usage: select * from getAllMarkersInMarkerGroupsById('{1, 3}')

--changeset kpalis:getAllMarkersInMarkerGroupsByIdAndPlatform context:general splitStatements:false
DROP FUNCTION IF EXISTS getAllMarkersInMarkerGroups(_idList text, _platformList text);
CREATE OR REPLACE FUNCTION  getAllMarkersInMarkerGroups(_idList text, _platformList text)
RETURNS table (marker_group_id integer, marker_group_name text, marker_id text, favorable_alleles text) AS $$
  BEGIN
    return query
    select t1.* from 
    (select mg.marker_group_id, mg.name, (jsonb_each_text(mg.markers)).*
    from unnest(_idList::text[]) mgl(marker_group_id)
    left join marker_group mg on mgl.marker_group_id::integer = mg.marker_group_id) as t1
    inner join marker m on m.marker_id = t1.key::integer
    where (_platformList is null OR m.platform_id in (select * from unnest(_platformList::integer[])));
  END;
$$ LANGUAGE plpgsql;
--select * from getAllMarkersInMarkerGroups('{1, 3}', '{2}')




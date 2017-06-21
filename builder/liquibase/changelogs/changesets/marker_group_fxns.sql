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
CREATE OR REPLACE FUNCTION deleteMarkerGroupByName(_name text)
RETURNS integer AS $$
    BEGIN
    delete from marker_group where name = _name;
    return id;
    END;
$$ LANGUAGE plpgsql;
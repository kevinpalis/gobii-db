--liquibase formatted sql

--Timescope Application Utility Functions

--NOTE: Do not make the mistake of adding another changeset tag in this file as it messes up the execution order in the changelog file.
-- Just append new functions at the bottom of this file.
-- This changeset is set to run on change. Liquibase will know when it needs to recreate these functions.

--changeset kpalis:timescope_utility_functions context:general splitStatements:false runOnChange:true
DROP FUNCTION IF EXISTS deleteDatasetMarkerIndices(integer);
CREATE OR REPLACE FUNCTION deleteDatasetMarkerIndices(datasetId integer) RETURNS integer
    LANGUAGE plpgsql
  AS $$
    DECLARE
        i integer;
  BEGIN
    update marker
    set dataset_marker_idx = dataset_marker_idx - datasetId::text
    where dataset_marker_idx ? datasetId::text;
    GET DIAGNOSTICS i  = ROW_COUNT;
    return i;
  END;
$$;


DROP FUNCTION IF EXISTS deleteDatasetDnarunIndices(integer);
CREATE OR REPLACE FUNCTION deleteDatasetDnarunIndices(datasetId integer) RETURNS integer
    LANGUAGE plpgsql
  AS $$
    DECLARE
        i integer;
  BEGIN
    update dnarun
    set dataset_dnarun_idx = dataset_dnarun_idx - datasetId::text
    where dataset_dnarun_idx ? datasetId::text;
    GET DIAGNOSTICS i  = ROW_COUNT;
    return i;
  END;
$$;

DROP FUNCTION IF EXISTS getAllDatasetsByMarker(integer);
CREATE OR REPLACE FUNCTION getAllDatasetsByMarker(_markerId integer) RETURNS TABLE(dataset_id integer, hdf5_index integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select key::integer as dataset_id, value::integer as hdf5_index from
     jsonb_each_text((select dataset_marker_idx from marker where marker_id=_markerId));
  END;
$$;

DROP FUNCTION IF EXISTS getLinkageGroupsByMarker(integer);
CREATE OR REPLACE FUNCTION getLinkageGroupsByMarker(_markerId integer) RETURNS TABLE(
  linkage_group_id integer,
  name character varying,
  start integer,
  stop integer,
  map_id integer,
  created_by integer,
  created_date date,
  modified_by integer,
  modified_date date)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select distinct lg.linkage_group_id,
      lg.name,
      lg.start,
      lg.stop,
      lg.map_id,
      lg.created_by,
      lg.created_date,
      lg.modified_by,
      lg.modified_date 
    from marker m
    left join marker_linkage_group mlg on m.marker_id=mlg.marker_id
    left join linkage_group lg on mlg.linkage_group_id=lg.linkage_group_id
    where m.marker_id=_markerId;
  END;
$$;

DROP FUNCTION IF EXISTS getMarkerGroupsByMarker(integer);
CREATE OR REPLACE FUNCTION getMarkerGroupsByMarker(_markerId integer) RETURNS TABLE(
  marker_group_id integer,
  name text,
  code text,
  markers jsonb,
  germplasm_group text,
  created_by integer,
  created_date date,
  modified_by integer,
  modified_date date,
  status integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select mg.marker_group_id,
      mg.name,
      mg.code,
      mg.markers,
      mg.germplasm_group,
      mg.created_by,
      mg.created_date,
      mg.modified_by,
      mg.modified_date,
      mg.status
    from marker_group mg
    where mg.markers ? _markerId::text;
  END;
$$;

--utility functions added for Timescope's marker tab - but can be useful for a lot of 
--different cases

--by project
DROP FUNCTION IF EXISTS getDatasetsInProject(integer);
CREATE OR REPLACE FUNCTION getDatasetsInProject(_projectId integer) RETURNS TABLE(
    dataset_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select d.dataset_id
  from project p
  left join experiment e on p.project_id=e.project_id
  left join dataset d on e.experiment_id=d.experiment_id
  where p.project_id=_projectId;
  END;
$$;

DROP FUNCTION IF EXISTS getMarkersInProject(integer);
CREATE OR REPLACE FUNCTION getMarkersInProject(_projectId integer) RETURNS TABLE(
    marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
  from marker m 
  where m.dataset_marker_idx ?| (select array_agg(dataset_id::text) from getDatasetsInProject(_projectId));
  END;
$$;



--by experiment
DROP FUNCTION IF EXISTS getDatasetsInExperiment(integer);
CREATE OR REPLACE FUNCTION getDatasetsInExperiment(_experimentId integer) RETURNS TABLE(
    dataset_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select d.dataset_id
  from experiment e
  left join dataset d on e.experiment_id=d.experiment_id
  where e.experiment_id=_experimentId;
  END;
$$;


DROP FUNCTION IF EXISTS getMarkersInExperiment(integer);
CREATE OR REPLACE FUNCTION getMarkersInExperiment(_experimentId integer) RETURNS TABLE(
    marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
  from marker m 
  where m.dataset_marker_idx ?| (select array_agg(dataset_id::text) from getDatasetsInExperiment(_experimentId));
  END;
$$;


--by vendor_protocol
DROP FUNCTION IF EXISTS getDatasetsInVendorProtocol(integer);
CREATE OR REPLACE FUNCTION getDatasetsInVendorProtocol(_vendor_protocol_id integer) RETURNS TABLE(
    dataset_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select d.dataset_id
  from vendor_protocol vp
  left join experiment e on vp.vendor_protocol_id=e.vendor_protocol_id
  left join dataset d on e.experiment_id=d.experiment_id
  where vp.vendor_protocol_id=_vendor_protocol_id;
  END;
$$;

DROP FUNCTION IF EXISTS getMarkersInVendorProtocol(integer);
CREATE OR REPLACE FUNCTION getMarkersInVendorProtocol(_vendor_protocol_id integer) RETURNS TABLE(
    marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
  from marker m 
  where m.dataset_marker_idx ?| (select array_agg(dataset_id::text) from getDatasetsInVendorProtocol(_vendor_protocol_id));
  END;
$$;


--by linkage_group

DROP FUNCTION IF EXISTS getMarkersInLinkageGroup(integer);
CREATE OR REPLACE FUNCTION getMarkersInLinkageGroup(_linkage_group_id integer) RETURNS TABLE(
    marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
    from marker m
    join marker_linkage_group mlg on m.marker_id=mlg.marker_id
    join linkage_group lg on mlg.linkage_group_id=lg.linkage_group_id
    where lg.linkage_group_id=_linkage_group_id;
  END;
$$;

--by mapset
DROP FUNCTION IF EXISTS getMarkersInMapset(integer);
CREATE OR REPLACE FUNCTION getMarkersInMapset(_mapset_id integer) RETURNS TABLE(
    marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
    from marker m
    join marker_linkage_group mlg on m.marker_id=mlg.marker_id
    join linkage_group lg on mlg.linkage_group_id=lg.linkage_group_id
    join mapset ms on lg.map_id=ms.mapset_id
    where ms.mapset_id=_mapset_id;
  END;
$$;

--by callingAnalysis
DROP FUNCTION IF EXISTS getMarkersInCallingAnalysis(integer);
CREATE OR REPLACE FUNCTION getMarkersInCallingAnalysis(_calling_analysis_id integer) RETURNS TABLE(
    marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    with filteredDataset as (
      select dataset_id
      from dataset
      where callinganalysis_id=_calling_analysis_id)
    select m.marker_id
    from marker m 
    where m.dataset_marker_idx ?| (select array_agg(dataset_id::text) from filteredDataset);
  END;
$$;

--by analyses
DROP FUNCTION IF EXISTS getMarkersInAnalysis(integer);
CREATE OR REPLACE FUNCTION getMarkersInAnalysis(_analysis_id integer) RETURNS TABLE(
    marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    with filteredDataset as (
      select dataset_id
      from dataset
      where _analysis_id=ANY (analyses))
    select m.marker_id
    from marker m 
    where m.dataset_marker_idx ?| (select array_agg(dataset_id::text) from filteredDataset);
  END;
$$;

--sample usage:
/*
select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getmarkersinproject(4));

select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getMarkersInExperiment(2));

select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getMarkersInVendorProtocol(1));

select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getMarkersInLinkageGroup(5));

select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getMarkersInMapset(3));

select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getMarkersInCallingAnalysis(2));

select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getMarkersInAnalysis(1));

--a demonstration of how versatile this can be:
select * from v_marker_summary vms
where vms.marker_id in (select marker_id from getmarkersinproject(4))
and vms.marker_id in (select marker_id from getMarkersInExperiment(2))
and vms.marker_id in (select marker_id from getMarkersInVendorProtocol(1))
and vms.marker_id in (select marker_id from getMarkersInLinkageGroup(5))
and vms.marker_id in (select marker_id from getMarkersInMapset(3))
and vms.marker_id in (select marker_id from getMarkersInCallingAnalysis(2))
and vms.marker_id in (select marker_id from getMarkersInAnalysis(1))
and vms.platform_name = 'KASP'
and vms.strand_name = '+'
and vms.status = 57;
*/
--duplicate check
/*
with dupTable as (
select m.marker_id as id
from marker m
join marker_linkage_group mlg on m.marker_id=mlg.marker_id
join linkage_group lg on mlg.linkage_group_id=lg.linkage_group_id
where lg.linkage_group_id>=1)
select * from (
  SELECT id,
  ROW_NUMBER() OVER(PARTITION BY id ORDER BY id asc) AS Row
  FROM dupTable
) dups
where 
dups.Row > 1
*/
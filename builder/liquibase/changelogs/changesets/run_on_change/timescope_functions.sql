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
 

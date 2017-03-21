--liquibase formatted sql

/*
* All the functions here enable the MDE to do extraction by marker list based on the derived marker ids from the functions provided on mde_derive_sample_ids.sql.
*/


--Functions that derive marker IDs based on either markerNames, platformList, or both. This will be used by the extraction by marker list.
--changeset kpalis:createFunctionsForDerivingMarkerIdsFromSampleIds  context:general splitStatements:false
DROP FUNCTION IF EXISTS getMarkerIdsBySamplesPlatformsAndDatasetType(sampleList text, platformList text, datasetTypeId integer);
CREATE OR REPLACE FUNCTION getMarkerIdsBySamplesPlatformsAndDatasetType(sampleList text, platformList text, datasetTypeId integer)
RETURNS table (marker_id integer)
  AS $$
  BEGIN
    return query
    with dataset_list as (
			select distinct jsonb_object_keys(dataset_dnarun_idx)::integer as ds_id
			from unnest(sampleList::integer[]) sl(s_id)
			left join dnarun dr on sl.s_id = dr.dnarun_id
			order by ds_id
		)
    select m.marker_id
    from dataset_list dl inner join dataset d on dl.ds_id = d.dataset_id
    inner join marker m on m.dataset_marker_idx ? d.dataset_id::text
    inner join unnest(platformList::integer[]) p(p_id) on m.platform_id = p.p_id
    where d.type_id = datasetTypeId;
  END;
$$ LANGUAGE plpgsql;

--sample usage:
--select * from getMarkerIdsBySamplesPlatformsAndDatasetType('{1,2,3,4,5,6,7,8,9,10}', '{1,7,8}', 164);

DROP FUNCTION IF EXISTS getMarkerIdsBySamplesAndDatasetType(sampleList text, datasetTypeId integer);
CREATE OR REPLACE FUNCTION getMarkerIdsBySamplesAndDatasetType(sampleList text, datasetTypeId integer)
RETURNS table (marker_id integer)
  AS $$
  BEGIN
    return query
    with dataset_list as (
			select distinct jsonb_object_keys(dataset_dnarun_idx)::integer as ds_id
			from unnest(sampleList::integer[]) sl(s_id)
			left join dnarun dr on sl.s_id = dr.dnarun_id
			order by ds_id
		)
    select m.marker_id
    from dataset_list dl inner join dataset d on dl.ds_id = d.dataset_id
    inner join marker m on m.dataset_marker_idx ? d.dataset_id::text
    where d.type_id = datasetTypeId;
  END;
$$ LANGUAGE plpgsql;

--sample usage:
--select * from getMarkerIdsBySamplesAndDatasetType('{1,2,3,4,5,6,7,8,9,10}', 164);


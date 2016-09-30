--liquibase formatted sql

--changeset kpalis:getMinimalMarkerMetadataByDataset_fix context:general splitStatements:false
DROP FUNCTION getMinimalMarkerMetadataByDataset(integer);
CREATE OR REPLACE FUNCTION getMinimalMarkerMetadataByDataset(datasetId integer)
RETURNS table (marker_name text, alleles text, chrom varchar, pos numeric, strand text) AS $$
  BEGIN
    return query
    select m.name as marker_name, m.ref || '/' || array_to_string(m.alts, ',', '?') as alleles, mlp.linkage_group_name as chrom, mlp.stop as pos, cv.term as strand
    from marker m
    left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
    left join cv on m.strand_id = cv.cv_id
    where m.dataset_marker_idx ? datasetId::text
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$ LANGUAGE plpgsql;

--changeset kpalis:getAllMarkerMetadataByDataset_fix context:general splitStatements:false
DROP FUNCTION getAllMarkerMetadataByDataset(integer);
CREATE OR REPLACE FUNCTION getAllMarkerMetadataByDataset(datasetId integer)
RETURNS table (marker_name text, linkage_group_name varchar, start numeric, stop numeric, mapset_name text, platform_name text, variant_id integer, code text, ref text, alts text, sequence text, reference_name text, primers jsonb, probsets jsonb, strand_name text) AS $$
  BEGIN
    return query
    select m.name as marker_name, mlp.linkage_group_name, mlp.start, mlp.stop, mlp.mapset_name, p.name as platform_name, m.variant_id, m.code, m.ref, array_to_string(m.alts, ',', '?'), m.sequence, r.name as reference_name, m.primers, m.probsets, cv.term as strand_name
	from marker m inner join platform p on m.platform_id = p.platform_id
	left join reference r on m.reference_id = r.reference_id
	left join cv on m.strand_id = cv.cv_id 
	left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
	where m.dataset_marker_idx ? datasetId::text
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$ LANGUAGE plpgsql;

--changeset kpalis:getMinimalSampleMetadataByDataset_fix context:general splitStatements:false
DROP FUNCTION getMinimalSampleMetadataByDataset(integer);
CREATE OR REPLACE FUNCTION getMinimalSampleMetadataByDataset(datasetId integer)
RETURNS table (dnarun_name text, sample_name text, germplasm_name text, external_code text, germplasm_type text, species text, platename text, num text, well_row text, well_col text) AS $$
  BEGIN
	return query
	select dr.name as dnarun_name, ds.name as sample_name, g.name as germplasm_name, g.external_code, c1.term as germplasm_type, c2.term as species, ds.platename, ds.num, ds.well_row, ds.well_col
	from dnarun dr
	inner join dnasample ds on dr.dnasample_id = ds.dnasample_id 
	inner join germplasm g on ds.germplasm_id = g.germplasm_id 
	left join cv as c1 on g.type_id = c1.cv_id 
	left join cv as c2 on g.species_id = c2.cv_id
	where dr.dataset_dnarun_idx ? datasetId::text
	order by dr.dataset_dnarun_idx->datasetId::text;
  END;
$$ LANGUAGE plpgsql;

--changeset kpalis:getAllSampleMetadataByDataset_fix context:general splitStatements:false
DROP FUNCTION getAllSampleMetadataByDataset(integer);
CREATE OR REPLACE FUNCTION getAllSampleMetadataByDataset(datasetId integer)
RETURNS table (dnarun_name text, sample_name text, germplasm_name text, external_code text, germplasm_type text, species text, platename text, num text, well_row text, well_col text) AS $$
  BEGIN
	return query
	select dr.name as dnarun_name, ds.name as sample_name, g.name as germplasm_name, g.external_code, c1.term as germplasm_type, c2.term as species, ds.platename, ds.num, ds.well_row, ds.well_col
	from dnarun dr
	inner join dnasample ds on dr.dnasample_id = ds.dnasample_id 
	inner join germplasm g on ds.germplasm_id = g.germplasm_id 
	left join cv as c1 on g.type_id = c1.cv_id 
	left join cv as c2 on g.species_id = c2.cv_id
	where dr.dataset_dnarun_idx ? datasetId::text
	order by dr.dataset_dnarun_idx->datasetId::text;
  END;
$$ LANGUAGE plpgsql;
/*
CREATE OR REPLACE FUNCTION getMarkerNamesByDataset(datasetId integer)
RETURNS table (marker_id integer, marker_name text) AS $$
  BEGIN
    return query
    with dm as (select dm.marker_id, dm.marker_idx from dataset_marker dm where dm.dataset_id=datasetId)
    select m.marker_id, m.name as marker_name
      from marker m, dm
      where m.marker_id = dm.marker_id 
      order by dm.marker_idx;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getDnarunNamesByDataset(datasetId integer)
RETURNS table (dnarun_id integer, dnarun_name text) AS $$
  BEGIN
    return query
    with dd as (select dd.dnarun_id, dd.dnarun_idx from dataset_dnarun dd where dd.dataset_id=datasetId)
    select  dr.dnarun_id, dr.name as dnarun_name 
      from dnarun dr, dd
      where dr.dnarun_id = dd.dnarun_id
      order by dd.dnarun_idx;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getAllProjectMetadataByDataset(datasetId integer)
RETURNS table (project_name text, description text, PI text, experiment_name text, platform_name text, dataset_name text, analysis_name text) AS $$
  BEGIN
    return query
    select p.name as project_name, p.description, c.firstname || ' ' || c.lastname as PI, e.name as experiment_name, pf.name as platform_name, d.name as dataset_name, a.name as analysis_name
      from dataset d, experiment e, project p, contact c, platform pf, analysis a
      where d.dataset_id = datasetId
      and d.callinganalysis_id = a.analysis_id
      and d.experiment_id = e.experiment_id
      and e.project_id = p.project_id
      and p.pi_contact = c.contact_id
      and e.platform_id = pf.platform_id;
  END;
$$ LANGUAGE plpgsql;
*/
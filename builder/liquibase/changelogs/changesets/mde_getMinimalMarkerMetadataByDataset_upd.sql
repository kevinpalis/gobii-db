--liquibase formatted sql

--changeset raza:getPropertyIdByName context:general splitStatements:false
CREATE OR REPLACE FUNCTION getPropertyIdByName(propName text)
RETURNS integer AS $$
BEGIN
	RETURN ( 
	select cv.cv_id
	from cv
	where term=propName);
END;
$$ LANGUAGE plpgsql;

--changeset raza:upd_getMinimalMarkerMetadataByDataset context:general splitStatements:false
DROP FUNCTION IF EXISTS getMinimalMarkerMetadataByDataset(integer);

CREATE OR REPLACE FUNCTION getMinimalMarkerMetadataByDataset(datasetId integer)
RETURNS table (marker_name text,platform_name text, variant_id integer, variant_code text, ref text, alts text, sequence text, marker_strand text
		,marker_primer_forw1 text
		,marker_primer_forw2 text
		,marker_primer_rev1 text
		,marker_primer_rev2 text
		,marker_probe1 text
		,marker_probe2 text
		,marker_polymorphism_type text
		,marker_synonym text
		,marker_source text
		,marker_gene_id text
		,marker_gene_annotation text
		,marker_polymorphism_annotation text
		,marker_marker_dom text
		,marker_clone_id_pos text
		,marker_genome_build text
		,marker_typeofrefallele_alleleorder text
) AS $$
  BEGIN
    return query
    select m.name as marker_name, p.name as platform_name, v.variant_id, v.code, m.ref, array_to_string(m.alts, ',', '?'), m.sequence, cv.term as strand_name
		,(m.props->getPropertyIdByName('primer_forw1')::text)::text
		,(m.props->getPropertyIdByName('primer_forw2')::text)::text
		,(m.props->getPropertyIdByName('primer_rev1')::text)::text
		,(m.props->getPropertyIdByName('primer_rev2')::text)::text
		,(m.props->getPropertyIdByName('probe1')::text)::text
		,(m.props->getPropertyIdByName('probe2')::text)::text
		,(m.props->getPropertyIdByName('polymorphism_type')::text)::text
		,(m.props->getPropertyIdByName('synonym')::text)::text
		,(m.props->getPropertyIdByName('source')::text)::text
		,(m.props->getPropertyIdByName('gene_id')::text)::text
		,(m.props->getPropertyIdByName('gene_annotation')::text)::text
		,(m.props->getPropertyIdByName('polymorphism_annotation')::text)::text
		,(m.props->getPropertyIdByName('marker_dom')::text)::text
		,(m.props->getPropertyIdByName('clone_id_pos')::text)::text
		,(m.props->getPropertyIdByName('genome_build')::text)::text
		,(m.props->getPropertyIdByName('typeofrefallele_alleleorder')::text)::text
	from marker m inner join platform p on m.platform_id = p.platform_id
	left join cv on m.strand_id = cv.cv_id 
	left join variant v on m.variant_id = v.variant_id
	where m.dataset_marker_idx ? datasetId::text
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$ LANGUAGE plpgsql;

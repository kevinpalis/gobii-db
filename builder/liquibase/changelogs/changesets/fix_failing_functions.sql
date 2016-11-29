--liquibase formatted sql

--changeset kpalis:fix_createmarker context:general splitStatements:false
DROP FUNCTION createMarker(platformId integer, variantId integer, markerName text, markerCode text, markerRef text, markerAlts text[], markerSequence text, referenceId integer, strandId integer, markerStatus integer, OUT id integer);

CREATE OR REPLACE FUNCTION createMarker(platformId integer, variantId integer, markerName text, markerCode text, markerRef text, markerAlts text[], markerSequence text, referenceId integer, strandId integer, markerStatus integer, OUT id integer)
RETURNS integer AS $$
  BEGIN
    insert into marker (platform_id, variant_id, name, code, ref, alts, sequence, reference_id, primers, probsets, strand_id, status)
      values (platformId, variantId, markerName, markerCode, markerRef, markerAlts, markerSequence, referenceId, '{}'::jsonb, '{}'::jsonb, strandId, markerStatus); 
    select lastval() into id;
  END;
$$ LANGUAGE plpgsql;

--changeset kpalis:remove_obsolete_marker_fxn context:general splitStatements:false
DROP FUNCTION createMarker(platformid integer, variantid integer, markername text, markercode text, markerref text, markeralts text[], markersequence text, referenceid integer, markerprimers jsonb, markerprobsets text[], strandid integer, markerstatus integer);
DROP FUNCTION updateMarker(id integer, platformid integer, variantid integer, markername text, markercode text, markerref text, markeralts text[], markersequence text, referenceid integer, markerprimers jsonb, markerprobsets text[], strandid integer, markerstatus integer);

--changeset kpalis:fix_upsertmapsetpropertybyname context:general splitStatements:false
DROP FUNCTION upsertmapsetpropertybyname(id integer, propertyname text, propertyvalue text);
CREATE OR REPLACE FUNCTION upsertmapsetpropertybyname(id integer, propertyname text, propertyvalue text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update mapset set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where mapset_id=id;
    return propertyId;
  END;
$function$
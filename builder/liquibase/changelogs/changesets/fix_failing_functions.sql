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

/*
FIXING MISSING RETURN VALUES!!!
*/

--changeset kpalis:fixing_fix_functions_dnasample context:general splitStatements:false
DROP FUNCTION IF EXISTS creatednasample(dnasamplename text, dnasamplecode text, dnasampleplatename text, dnasamplenum text, wellrow text, wellcol text, projectid integer, germplasmid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, dnasamplestatus integer, OUT id integer);

CREATE OR REPLACE FUNCTION creatednasample(dnasamplename text, dnasamplecode text, dnasampleplatename text, dnasamplenum text, wellrow text, wellcol text, projectid integer, germplasmid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, dnasamplestatus integer, OUT id integer)
RETURNS integer AS $$
BEGIN
	insert into dnasample(name, code, platename, num, well_row, well_col, project_id, germplasm_id, created_by, created_date, modified_by, modified_date, status)
	values(dnasamplename, dnasamplecode, dnasampleplatename, dnasamplenum, wellrow, wellcol, projectid, germplasmid, createdby, createddate, modifiedby, modifieddate,dnasamplestatus);
	select lastval() into id;
END;
$$ LANGUAGE plpgsql;

--changeset kpalis:fixing_fix_functions_platform context:general splitStatements:false
DROP FUNCTION IF EXISTS createPlatform(platformName text, platformCode text, vendorId integer, platformDescription text, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, platformStatus integer, typeId integer, OUT id integer);

CREATE OR REPLACE FUNCTION createPlatform(platformName text, platformCode text, vendorId integer, platformDescription text, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, platformStatus integer, typeId integer, OUT id integer)
RETURNS integer AS $$
  BEGIN
    insert into platform (name, code, vendor_id, description, created_by, created_date, modified_by, modified_date, status, type_id)
      values (platformName, platformCode, vendorId, platformDescription, createdBy, createdDate, modifiedBy, modifiedDate, platformStatus, typeId);
    select lastval() into id;
  END;
$$ LANGUAGE plpgsql;

--changeset kpalis:fixing_fix_functions_dnarun context:general splitStatements:false
--createDnarun
DROP FUNCTION IF EXISTS createDnarun(experimentId integer, dnasampleId integer, dnarunName text, dnarunCode text, OUT id integer);

CREATE OR REPLACE FUNCTION createDnarun(experimentId integer, dnasampleId integer, dnarunName text, dnarunCode text, OUT id integer)
RETURNS integer AS $$
  BEGIN
    insert into dnarun (experiment_id, dnasample_id, name, code)
      values (experimentId, dnasampleId, dnarunName, dnarunCode);
    select lastval() into id;
  END;
$$ LANGUAGE plpgsql;


--changeset kpalis:fixing_fix_functions_project context:general splitStatements:false
--createproject
DROP FUNCTION IF EXISTS createProject(projectName text, projectCode text, projectDescription text, piContact integer, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, projectStatus integer, OUT projectId integer);

CREATE OR REPLACE FUNCTION createProject(projectName text, projectCode text, projectDescription text, piContact integer, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, projectStatus integer, OUT projectId integer)
RETURNS integer AS $$
    BEGIN
	    insert into project (name, code, description, pi_contact, created_by, created_date, modified_by, modified_date, status)
	      values (projectName, projectCode, projectDescription, piContact, createdBy, createdDate, modifiedBy, modifiedDate, projectStatus);
	    select lastval() into id;
    END;
$$ LANGUAGE plpgsql;

--changeset kpalis:fixing_fix_functions_germplasm context:general splitStatements:false
--creategermplasm
DROP FUNCTION IF EXISTS createGermplasm(germplasmName text, externalCode text, speciesId integer, typeId integer, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, germplasmStatus integer, germplasmCode text, OUT id integer);

CREATE OR REPLACE FUNCTION createGermplasm(germplasmName text, externalCode text, speciesId integer, typeId integer, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, germplasmStatus integer, germplasmCode text, OUT id integer)
RETURNS integer AS $$
  BEGIN
    insert into germplasm (name, external_code, species_id, type_id, created_by, created_date, modified_by, modified_date, status, code)
      values (germplasmName, externalCode, speciesId, typeId, createdBy, createdDate, modifiedBy, modifiedDate, germplasmStatus, germplasmCode);
    select lastval() into id;
  END;
$$ LANGUAGE plpgsql;

--changeset kpalis:fixing_fix_functions_marker context:general splitStatements:false
DROP FUNCTION IF EXISTS createMarker(platformId integer, variantId integer, markerName text, markerCode text, markerRef text, markerAlts text[], markerSequence text, referenceId integer, strandId integer, markerStatus integer, OUT id integer);

CREATE OR REPLACE FUNCTION createMarker(platformId integer, variantId integer, markerName text, markerCode text, markerRef text, markerAlts text[], markerSequence text, referenceId integer, strandId integer, markerStatus integer, OUT id integer)
RETURNS integer AS $$
  BEGIN
    insert into marker (platform_id, variant_id, name, code, ref, alts, sequence, reference_id, primers, probsets, strand_id, status)
      values (platformId, variantId, markerName, markerCode, markerRef, markerAlts, markerSequence, referenceId, '{}'::jsonb, '{}'::jsonb, strandId, markerStatus);
    select lastval() into id;
  END;
$$ LANGUAGE plpgsql;

--changeset kpalis:fixing_fix_functions_mapset_createmapset context:general splitStatements:false
DROP FUNCTION IF EXISTS createMapset(mapsetName text, mapsetCode text, mapsetDescription text, referenceId integer, typeId integer, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, mapsetStatus integer, OUT id integer);

CREATE OR REPLACE FUNCTION createMapset(mapsetName text, mapsetCode text, mapsetDescription text, referenceId integer, typeId integer, createdBy integer, createdDate date, modifiedBy integer, modifiedDate date, mapsetStatus integer, OUT id integer)
RETURNS integer AS $$
  BEGIN
    insert into mapset (name, code, description, reference_id, type_id,
created_by, created_date, modified_by, modified_date, status)
      values (mapsetName, mapsetCode, mapsetDescription, referenceId, typeId, createdBy, createdDate, modifiedBy, modifiedDate, mapsetStatus);
    select lastval() into id;
  END;
$$ LANGUAGE plpgsql;


--liquibase formatted sql

--### CREATE FUNCTIONS ###--
--## Most are just insert statement wrappers because we weren't able to get an ORM that supports jsonb.

--changeset kpalis:create_functions context:general splitStatements:false runOnChange:true

CREATE OR REPLACE FUNCTION createanalysis(analysisname text, analysisdescription text, typeid integer, analysisprogram text, analysisprogramversion text, aanalysisalgorithm text, analysissourcename text, analysissourceversion text, analysissourceuri text, referenceid integer, analysistimeexecuted timestamp without time zone, analysisstatus integer, createdby integer, createddate date, modifiedby integer, modifieddate date, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN	
		insert into analysis (name, description, type_id, program, programversion, algorithm, sourcename, sourceversion, sourceuri, reference_id, parameters, timeexecuted, status,created_by, created_date, modified_by, modified_date)
		values (analysisName, analysisDescription, typeId, analysisProgram, analysisProgramversion, aanalysisAlgorithm, analysisSourcename, analysisSourceversion, analysisSourceuri, referenceId, '{}'::jsonb, analysisTimeexecuted, analysisStatus, createdBy, createdDate, modifiedBy, modifiedDate);
    		select lastval() into id;
	END;
$$;

CREATE OR REPLACE FUNCTION createanalysis(analysisname text, analysisdescription text, typeid integer, analysisprogram text, analysisprogramversion text, aanalysisalgorithm text, analysissourcename text, analysissourceversion text, analysissourceuri text, referenceid integer, analysisparameters jsonb, analysistimeexecuted timestamp without time zone, analysisstatus integer, createdby integer, createddate date, modifiedby integer, modifieddate date, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN   
        insert into analysis (name, description, type_id, program, programversion, algorithm, sourcename, sourceversion, sourceuri, reference_id, parameters, timeexecuted, status,created_by, created_date, modified_by, modified_date)
        values (analysisName, analysisDescription, typeId, analysisProgram, analysisProgramversion, aanalysisAlgorithm, analysisSourcename, analysisSourceversion, analysisSourceuri, referenceId, analysisparameters, analysisTimeexecuted, analysisStatus, createdBy, createdDate, modifiedBy, modifiedDate);
            select lastval() into id;
    END;
$$;

-----
--update all usernames that are blank to be the same as their emails for the unique constraint to work
UPDATE contact set username = email where username = '';
--add a unique constraint on the username column
ALTER TABLE contact DROP CONSTRAINT IF EXISTS contact_username_key;
ALTER TABLE contact ADD CONSTRAINT contact_username_key UNIQUE (username);

--add an on conflict clause to the create contact function
CREATE OR REPLACE FUNCTION createcontact(lastname text, firstname text, contactcode text, contactemail text, contactroles integer[], createdby integer, createddate date, modifiedby integer, modifieddate date, organizationid integer, uname text, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
  BEGIN
    insert into contact (lastname, firstname, code, email, roles, created_by, created_date, modified_by, modified_date, organization_id, username)
      values (lastName, firstName, contactCode, contactEmail, contactRoles, createdBy, createdDate, modifiedBy, modifiedDate, organizationId, uname)
      on conflict (username) DO NOTHING;
    select lastval() into id;
  END;
$function$;



CREATE OR REPLACE FUNCTION createcv(pcvgroupid integer, pcvterm text, pcvdefinition text, pcvrank integer, pabbreviation text, pdbxrefid integer, pstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   BEGIN
     insert into cv (cvgroup_id, term, definition, rank, abbreviation, dbxref_id, status)
       values (pcvgroupid, pcvterm, pcvdefinition, pcvrank, pabbreviation, pdbxrefid, pstatus);
     select lastval() into id;
   END;
 $$;

CREATE OR REPLACE FUNCTION createcvgroup(pname text, pdefinition text, ptype integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   BEGIN
     insert into cvgroup (name, definition, type)
       values (pname, pdefinition, ptype);
     select lastval() into id;
   END;
 $$;

CREATE OR REPLACE FUNCTION createcvingroup(pgroupname text, pgrouptype integer, pcvterm text, pcvdefinition text, pcvrank integer, pabbreviation text, pdbxrefid integer, pstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   DECLARE
    groupId integer;
   BEGIN
     select cvgroup_id into groupId from cvgroup where name=pgroupname and type=pgrouptype;
     insert into cv (cvgroup_id, term, definition, rank, abbreviation, dbxref_id, status)
       values (groupId, pcvterm, pcvdefinition, pcvrank, pabbreviation, pdbxrefid, pstatus)
       on conflict (term, cvgroup_id) DO NOTHING;
     select lastval() into id;
   END;
 $$;

CREATE OR REPLACE FUNCTION createdataset(datasetname text, experimentid integer, callinganalysisid integer, datasetanalyses integer[], datatable text, datafile text, qualitytable text, qualityfile text, createdby integer, createddate date, modifiedby integer, modifieddate date, datasetstatus integer, typeid integer, jobid integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into dataset (experiment_id, callinganalysis_id, analyses, data_table, data_file, quality_table, quality_file, scores, created_by, created_date, modified_by, modified_date, status, type_id, name, job_id)
      values (experimentId, callinganalysisId, datasetAnalyses, dataTable, dataFile, qualityTable, qualityFile, '{}'::jsonb, createdBy, createdDate, modifiedBy, modifiedDate, datasetStatus, typeId, datasetName, jobid);
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createdbxref(paccession text, pver text, pdescription text, pdbname text, purl text, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   BEGIN
     insert into dbxref (accession, ver, description, db_name, url)
       values (paccession, pver, pdescription, pdbname, purl);
     select lastval() into id;
   END;
 $$;

CREATE OR REPLACE FUNCTION createdisplay(tablename text, columnname text, displayname text, createdby integer, createddate date, modifiedby integer, modifieddate date, displayrank integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into display (table_name, column_name, display_name, created_by, created_date, modified_by, modified_date, rank)
      values (tableName, columnName, displayName, createdBy, createdDate, modifiedBy, modifiedDate, displayRank); 
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION creatednarun(experimentid integer, dnasampleid integer, dnarunname text, dnaruncode text, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into dnarun (experiment_id, dnasample_id, name, code)
      values (experimentId, dnasampleId, dnarunName, dnarunCode);
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION creatednasample(dnasamplename text, dnasamplecode text, dnasampleplatename text, dnasamplenum text, wellrow text, wellcol text, projectid integer, germplasmid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, dnasamplestatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	insert into dnasample(name, code, platename, num, well_row, well_col, project_id, germplasm_id, created_by, created_date, modified_by, modified_date, status)
	values(dnasamplename, dnasamplecode, dnasampleplatename, dnasamplenum, wellrow, wellcol, projectid, germplasmid, createdby, createddate, modifiedby, modifieddate,dnasamplestatus);
	select lastval() into id;
END;
$$;

CREATE OR REPLACE FUNCTION createexperiment(pname text, pcode text, pprojectid integer, pvendorprotocolid integer, pmanifestid integer, pdatafile text, pcreatedby integer, pcreateddate date, pmodifiedby integer, pmodifieddate date, pstatus integer, OUT expid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     BEGIN
     insert into experiment (name, code, project_id, manifest_id, data_file, created_by, created_date, modified_by, modified_date, status, vendor_protocol_id)
       values (pname, pcode, pprojectid, pmanifestid, pdatafile, pcreatedby, pcreateddate, pmodifiedby, pmodifieddate, pstatus, pvendorprotocolid);
     select lastval() into expId;
     END;
 $$;

CREATE OR REPLACE FUNCTION creategermplasm(germplasmname text, externalcode text, speciesid integer, typeid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, germplasmstatus integer, germplasmcode text, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into germplasm (name, external_code, species_id, type_id, created_by, created_date, modified_by, modified_date, status, code)
      values (germplasmName, externalCode, speciesId, typeId, createdBy, createdDate, modifiedBy, modifiedDate, germplasmStatus, germplasmCode);
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createjob(_name text, _type_id integer, _payload_type_id integer, _status integer, _message text, _submitted_by integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
        insert into job (type_id, payload_type_id, status, message, submitted_by, name)
          values (_type_id, _payload_type_id, _status, _message, _submitted_by, _name);
        select lastval() into id;
    END;
$$;

CREATE OR REPLACE FUNCTION createjob(_name text, _type text, _payload_type text, _status text, _message text, _submitted_by integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
        _type_id integer;
        _payload_type_id integer;
        _status_id integer;
    BEGIN
    	select cvid into _type_id from getCvId(_type, 'job_type', 1);
    	select cvid into _payload_type_id from getCvId(_payload_type, 'payload_type', 1);
    	select cvid into _status_id from getCvId(_status, 'job_status', 1);
        insert into job (type_id, payload_type_id, status, message, submitted_by, name)
          values (_type_id, _payload_type_id, _status_id, _message, _submitted_by, _name);
        select lastval() into id;
    END;
$$;

CREATE OR REPLACE FUNCTION createlinkagegroup(linkagegroupname text, linkagegroupstart integer, linkagegroupstop integer, mapid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		insert into linkage_group(name, start, stop, map_id, created_by, created_date,modified_by, modified_date) values(linkageGroupName, linkageGroupStart, linkageGroupStop, mapId, createdBy, createdDate, modifiedBy, modifiedDate);
		select lastval() into id;
	END;
$$;

CREATE OR REPLACE FUNCTION createmanifest(manifestname text, manifestcode text, filepath text, createdby integer, createddate date, modifiedby integer, modifieddate date, OUT mid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into manifest (name, code, file_path, created_by, created_date, modified_by, modified_date)
      values (manifestName, manifestCode, filePath, createdBy, createdDate, modifiedBy, modifiedDate); 
    select lastval() into mId;
  END;
$$;

CREATE OR REPLACE FUNCTION createmapset(mapsetname text, mapsetcode text, mapsetdescription text, referenceid integer, typeid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, mapsetstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into mapset (name, code, description, reference_id, type_id,
created_by, created_date, modified_by, modified_date, status)
      values (mapsetName, mapsetCode, mapsetDescription, referenceId, typeId, createdBy, createdDate, modifiedBy, modifiedDate, mapsetStatus);
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createmarker(platformid integer, variantid integer, markername text, markercode text, markerref text, markeralts text[], markersequence text, referenceid integer, strandid integer, markerstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into marker (platform_id, variant_id, name, code, ref, alts, sequence, reference_id, primers, probsets, strand_id, status)
      values (platformId, variantId, markerName, markerCode, markerRef, markerAlts, markerSequence, referenceId, '{}'::jsonb, '{}'::jsonb, strandId, markerStatus);
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createmarkergroup(markergroupname text, markergroupcode text, germplasmgroup text, createdby integer, createddate date, modifiedby integer, modifieddate date, markergroupstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into marker_group (name, code, markers, germplasm_group, created_by, created_date, modified_by, modified_date, status)
      values (markerGroupName, markerGroupCode, '{}'::jsonb, germplasmGroup, createdBy, createdDate, modifiedBy, modifiedDate, markerGroupStatus); 
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createmarkerlinkagegroup(markerid integer, markerlinkagegroupstart numeric, markerlinkagegroupstop numeric, linkagegroupid integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into marker_linkage_group (marker_id, start, stop, linkage_group_id)
      values (markerId, markerLinkageGroupStart, markerLinkageGroupStop, linkageGroupId); 
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createorganization(orgname text, orgaddress text, orgwebsite text, createdby integer, createddate date, modifiedby integer, modifieddate date, orgstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into organization (name, address, website, created_by, created_date, modified_by, modified_date, status)
      values (orgName, orgAddress, orgWebsite, createdBy, createdDate, modifiedBy, modifiedDate, orgStatus); 
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createplatform(platformname text, platformcode text, platformdescription text, createdby integer, createddate date, modifiedby integer, modifieddate date, platformstatus integer, typeid integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   BEGIN
     insert into platform (name, code, description, created_by, created_date, modified_by, modified_date, status, type_id)
       values (platformName, platformCode, platformDescription, createdBy, createdDate, modifiedBy, modifiedDate, platformStatus, typeId);
     select lastval() into id;
   END;
 $$;

CREATE OR REPLACE FUNCTION createproject(projectname text, projectcode text, projectdescription text, picontact integer, createdby integer, createddate date, modifiedby integer, modifieddate date, projectstatus integer, OUT projectid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
	    insert into project (name, code, description, pi_contact, created_by, created_date, modified_by, modified_date, status)
	      values (projectName, projectCode, projectDescription, piContact, createdBy, createdDate, modifiedBy, modifiedDate, projectStatus);
	    select lastval() into projectId;
    END;
$$;

CREATE OR REPLACE FUNCTION createprotocol(pname text, pdescription text, ptypeid integer, pplatformid integer, pcreatedby integer, pcreateddate date, pmodifiedby integer, pmodifieddate date, pstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    insert into protocol (name, description, type_id, platform_id, created_by, created_date, modified_by, modified_date, status)
      values (pname, pdescription, ptypeid, pplatformid, pcreatedby, pcreateddate, pmodifiedby, pmodifieddate, pstatus); 
    select lastval() into id;
    END;
$$;

CREATE OR REPLACE FUNCTION createreference(referencename text, referenceversion text, referencelink text, filepath text, createdby integer, createddate date, modifiedby integer, modifieddate date, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		insert into reference(name,version,link, file_path, created_by, created_date,modified_by, modified_date) values(referencename, referenceversion, referencelink, filepath, createdBy, createdDate, modifiedBy, modifiedDate);
		select lastval() into id;
	END;
$$;

CREATE OR REPLACE FUNCTION createrole(rolename text, rolecode text, readtables integer[], writetables integer[], OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into role (role_name, role_code, read_tables, write_tables)
      values (roleName, roleCode, readTables, writeTables); 
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createvariant(variantcode text, createdby integer, createddate date, modifiedby integer, modifieddate date, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into variant (code, created_by, created_date, modified_by, modified_date)
      values (variantCode, createdBy, createdDate, modifiedBy, modifiedDate); 
    select lastval() into id;
  END;
$$;

CREATE OR REPLACE FUNCTION createvendorprotocol(pname text, pvendorid integer, pprotocolid integer, pstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    insert into vendor_protocol (name, vendor_id, protocol_id, status)
      values (pname, pvendorid, pprotocolid, pstatus); 
    select lastval() into id;
    END;
$$;

--changeset kpalis:dnasample_uuid_updated_fxns context:general splitStatements:false runOnChange:true
--also, as much as I would like to switch to a more reasonable convention of param names starting with '_', I can't -- the me 2 years ago disagrees with 3000+ LOC. :(
CREATE OR REPLACE FUNCTION creatednasample(dnasamplename text, dnasamplecode text, dnasampleplatename text, dnasamplenum text, wellrow text, wellcol text, projectid integer, germplasmid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, dnasamplestatus integer, _uuid text, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  insert into dnasample(name, code, platename, num, well_row, well_col, project_id, germplasm_id, created_by, created_date, modified_by, modified_date, status, uuid)
  values(dnasamplename, dnasamplecode, dnasampleplatename, dnasamplenum, wellrow, wellcol, projectid, germplasmid, createdby, createddate, modifiedby, modifieddate, dnasamplestatus, _uuid);
  select lastval() into id;
END;
$$;
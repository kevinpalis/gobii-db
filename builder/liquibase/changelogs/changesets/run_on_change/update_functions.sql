--liquibase formatted sql

--### UPDATE FUNCTIONS ###---
--## These probably are the most silly functions you have seen, but with the lack of a proper ORM and the requirements of the GOBII front-end, these needed to be written.

--changeset kpalis:update_functions context:general splitStatements:false runOnChange:true
CREATE OR REPLACE FUNCTION updateanalysis(id integer, analysisname text, analysisdescription text, typeid integer, analysisprogram text, analysisprogramversion text, aanalysisalgorithm text, analysissourcename text, analysissourceversion text, analysissourceuri text, referenceid integer, analysisparameters jsonb, analysistimeexecuted timestamp without time zone, analysisstatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update analysis set name=analysisName, description=analysisDescription, type_id=typeId, program=analysisProgram, programversion=analysisProgramversion, algorithm=aanalysisAlgorithm, sourcename=analysisSourcename, sourceversion=analysisSourceversion, sourceuri=analysisSourceuri, reference_id=referenceId, parameters=analysisParameters, timeexecuted=analysisTimeexecuted, status=analysisStatus
     where analysis_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updateanalysis(id integer, analysisname text, analysisdescription text, typeid integer, analysisprogram text, analysisprogramversion text, aanalysisalgorithm text, analysissourcename text, analysissourceversion text, analysissourceuri text, referenceid integer, analysistimeexecuted timestamp without time zone, analysisstatus integer, createdby integer, createddate date, modifiedby integer, modifieddate date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update analysis set name=analysisName, description=analysisDescription, type_id=typeId, program=analysisProgram, programversion=analysisProgramversion, algorithm=aanalysisAlgorithm, sourcename=analysisSourcename, sourceversion=analysisSourceversion, sourceuri=analysisSourceuri, reference_id=referenceId, timeexecuted=analysisTimeexecuted, status=analysisStatus, created_by = createdBy, created_date = createdDate, modified_by = modifiedBy, modified_date = modifiedDate
     where analysis_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updateanalysis(id integer, analysisname text, analysisdescription text, typeid integer, analysisprogram text, analysisprogramversion text, aanalysisalgorithm text, analysissourcename text, analysissourceversion text, analysissourceuri text, referenceid integer, analysisparameters jsonb, analysistimeexecuted timestamp without time zone, analysisstatus integer, createdby integer, createddate date, modifiedby integer, modifieddate date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update analysis set name=analysisName, description=analysisDescription, type_id=typeId, program=analysisProgram, programversion=analysisProgramversion, algorithm=aanalysisAlgorithm, sourcename=analysisSourcename, sourceversion=analysisSourceversion, sourceuri=analysisSourceuri, reference_id=referenceId, parameters=analysisParameters, timeexecuted=analysisTimeexecuted, status=analysisStatus, created_by = createdBy, created_date = createdDate, modified_by = modifiedBy, modified_date = modifiedDate
     where analysis_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatecontact(contactid integer, contactlastname text, contactfirstname text, contactcode text, contactemail text, contactroles integer[], createdby integer, createddate date, modifiedby integer, modifieddate date, organizationid integer, uname text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update contact set lastname=contactLastName, firstname=contactFirstName, code=contactCode, email=contactEmail, roles=contactRoles, created_by=createdBy, created_date=createdDate,
      modified_by=modifiedBy, modified_date=modifiedDate, organization_id=organizationId, username=uname
     where contact_id = contactId;
    END;
$$;

CREATE OR REPLACE FUNCTION updatecv(pid integer, pcvgroupid integer, pcvterm text, pcvdefinition text, pcvrank integer, pabbreviation text, pdbxrefid integer, pstatus integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     DECLARE
        i integer;
     BEGIN
     update cv set cvgroup_id=pcvgroupid, term=pcvterm, definition=pcvdefinition, rank=pcvrank, abbreviation=pabbreviation, dbxref_id=pdbxrefid, status=pstatus
      where cv_id = pid;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION updatecvgroup(pid integer, pname text, pdefinition text, ptype integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     DECLARE
        i integer;
     BEGIN
     update cvgroup set name=pname, definition=pdefinition, type=ptype
      where cvgroup_id = pid;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION updatedataset(id integer, datasetname text, experimentid integer, callinganalysisid integer, datasetanalyses integer[], datatable text, datafile text, qualitytable text, qualityfile text, createdby integer, createddate date, modifiedby integer, modifieddate date, datasetstatus integer, typeid integer, jobid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
   BEGIN
    update dataset set experiment_id=experimentId, callinganalysis_id=callinganalysisId, analyses=datasetAnalyses, data_table=dataTable, data_file=dataFile, quality_table=qualityTable, quality_file=qualityFile, scores='{}'::jsonb, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=datasetStatus, type_id=typeId, name=datasetName, job_id=jobid
     where dataset_id = id;
   END;
$$;

CREATE OR REPLACE FUNCTION updatedatasetmarker(id integer, datasetid integer, markerid integer, callrate real, datasetmarkermaf real, datasetmarkerreproducibility real, datasetmarkerscores jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update dataset_marker set dataset_id=datasetId, marker_id=markerId, call_rate=callRate, maf=datasetMarkerMaf, reproducibility=datasetMarkerReproducibility, scores=datasetMarkerScores
     where dataset_marker_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatedbxref(pid integer, paccession text, pver text, pdescription text, pdbname text, purl text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     DECLARE
        i integer;
     BEGIN
     update dbxref set accession=paccession, ver=pver, description=pdescription, db_name=pdbname, url=purl
      where dbxref_id = pid;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION updatedisplay(id integer, tablename text, columnname text, displayname text, createdby integer, createddate date, modifiedby integer, modifieddate date, displayrank integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update display set table_name=tableName, column_name=columnName, display_name=displayName, created_by=createdBy, created_date=createdDate, 
      modified_by=modifiedBy, modified_date=modifiedDate, rank=displayRank
     where display_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatednarun(id integer, experimentid integer, dnasampleid integer, dnarunname text, dnaruncode text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update dnarun set experiment_id=experimentId, dnasample_id=dnasampleId, name=dnarunName, code=dnarunCode
     where dnarun_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatednarunpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update dnarun set props = jsonb_set(props, ('{'||propertyId::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      where dnarun_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updatednarunpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update dnarun
      set props = jsonb_set(props, ('{'||property.cv_id::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      from property
      where dnarun_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updatednasample(id integer, dnasamplename text, dnasamplecode text, dnasampleplatename text, dnasamplenum text, wellrow text, wellcol text, projectid integer, germplasmid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, dnasamplestatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update dnasample set name=dnaSampleName, code=dnaSampleCode, platename=dnaSamplePlateName, num=dnaSampleNum, well_row=wellRow, well_col=wellCol, project_id=projectId, germplasm_id=germplasmId, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=dnaSampleStatus
     where dnasample_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatednasamplepropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update dnasample set props = jsonb_set(props, ('{'||propertyId::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      where dnasample_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updatednasamplepropertybyname(id integer, propertyname text, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update dnasample
      set props = jsonb_set(props, ('{'||property.cv_id::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      from property
      where dnasample_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updateexperiment(pid integer, pname text, pcode text, pprojectid integer, pvendorprotocolid integer, pmanifestid integer, pdatafile text, pcreatedby integer, pcreateddate date, pmodifiedby integer, pmodifieddate date, pstatus integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i integer;
     BEGIN
     update experiment set name=pname, code=pcode, project_id=pprojectid, manifest_id=pmanifestid, data_file=pdatafile,
       created_by=pcreatedby, created_date=pcreateddate, modified_by=pmodifiedby, modified_date=pmodifieddate, status=pstatus, vendor_protocol_id=pvendorprotocolid 
       where experiment_id = pId;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION updategermplasm(id integer, germplasmname text, externalcode text, speciesid integer, typeid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, germplasmstatus integer, germplasmcode text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update germplasm set name=germplasmName, external_code=externalCode, species_id=speciesId, type_id=typeId, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=germplasmStatus, code=germplasmCode
     where germplasm_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updategermplasmpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update germplasm set props = jsonb_set(props, ('{'||propertyId::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      where germplasm_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updategermplasmpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update germplasm
      set props = jsonb_set(props, ('{'||property.cv_id::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      from property
      where germplasm_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updatejob(id integer, _name text, _type_id integer, _payload_type_id integer, _status integer, _message text, _submitted_by integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update job set type_id=_type_id, payload_type_id=_payload_type_id, status=_status, message=_message, submitted_by=_submitted_by, name=_name where job_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatejob(id integer, _name text, _type text, _payload_type text, _status text, _message text, _submitted_by integer) RETURNS void
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
        update job set type_id=_type_id, name=_name, payload_type_id=_payload_type_id, status=_status_id, message=_message, submitted_by=_submitted_by where job_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatelinkagegroup(id integer, linkagegroupname text, linkagegroupstart numeric, linkagegroupstop numeric, mapid integer, createdby integer, createddate date, modifiedby integer, modifieddate date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update linkage_group set name=linkageGroupName, start=linkageGroupStart, stop=linkageGroupStop, map_id=mapId, created_by = createdBy, created_date = createdDate, modified_by = modifiedBy, modified_date = modifiedDate
     where linkage_group_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemanifest(manifestid integer, manifestname text, manifestcode text, filepath text, createdby integer, createddate date, modifiedby integer, modifieddate date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update manifest set name=manifestName, code=manifestCode, file_path=filePath, created_by=createdBy, 
      created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate
     where manifest_id = manifestId;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemapset(id integer, mapsetname text, mapsetcode text, mapsetdescription text, referenceid integer, typeid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, mapsetstatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update mapset set name=mapsetName, code=mapsetCode, description=mapsetDescription, reference_id=referenceId, type_id=typeId, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=mapsetStatus
     where mapset_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemapsetpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update mapset set props = jsonb_set(props, ('{'||propertyId::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      where mapset_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updatemapsetpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update mapset
      set props = jsonb_set(props, ('{'||property.cv_id::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      from property
      where mapset_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updatemarker(id integer, platformid integer, variantid integer, markername text, markercode text, markerref text, markeralts text[], markersequence text, referenceid integer, strandid integer, markerstatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update marker set  platform_id=platformId, variant_id=variantId, name=markerName, code=markerCode, ref=markerRef, alts=markerAlts, sequence=markerSequence, reference_id=referenceId, primers='{}'::jsonb, probsets='{}'::jsonb, strand_id=strandId, status=markerStatus
     where marker_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemarkergroup(id integer, markergroupname text, markergroupcode text, germplasmgroup text, createdby integer, createddate date, modifiedby integer, modifieddate date, markergroupstatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update marker_group set name=markerGroupName, code=markerGroupCode, markers='{}'::jsonb, germplasm_group=germplasmGroup, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=markerGroupStatus
     where marker_group_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemarkergroup(id integer, markergroupname text, markergroupcode text, markergroupmarkers jsonb, germplasmgroup text, createdby integer, createdate date, modifiedby text, modifieddate date, markergroupstatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update marker_group set name=markerGroupName, code=markerGroupCode, markers=markerGroupMarkers, germplasm_group=germplasmGroup, created_by=createdBy, create_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=markerGroupStatus
     where marker_group_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemarkergroupname(_id integer, _name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i integer;
    BEGIN
        update marker_group set name=_name
        where marker_group_id = _id;
        GET DIAGNOSTICS i = ROW_COUNT;
        return i;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemarkerlinkagegroup(id integer, markerid integer, markerlinkagegroupstart numeric, markerlinkagegroupstop numeric, linkagegroupid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update marker_linkage_group set marker_id=markerId, start=markerLinkageGroupStart, stop=markerLinkageGroupStop, linkage_group_id=linkageGroupId
     where marker_linkage_group_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatemarkerpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update marker set props = jsonb_set(props, ('{'||propertyId::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      where marker_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updatemarkerpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update marker
      set props = jsonb_set(props, ('{'||property.cv_id::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      from property
      where marker_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updateorganization(orgid integer, orgname text, orgaddress text, orgwebsite text, createdby integer, createddate date, modifiedby integer, modifieddate date, orgstatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update organization set name=orgName, address=orgAddress, website=orgWebsite, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=orgStatus
     where organization_id = orgId;
    END;
$$;

CREATE OR REPLACE FUNCTION updateplatform(id integer, platformname text, platformcode text, platformdescription text, createdby integer, createddate date, modifiedby integer, modifieddate date, platformstatus integer, typeid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     DECLARE
        i integer;
     BEGIN
     update platform set name=platformName, code=platformCode, description=platformDescription, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=platformStatus, type_id=typeId
      where platform_id = id;
      GET DIAGNOSTICS i = ROW_COUNT;
      return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION updateplatformpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update platform set props = jsonb_set(props, ('{'||propertyId::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      where platform_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updateplatformpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update platform
      set props = jsonb_set(props, ('{'||property.cv_id::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      from property
      where platform_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION updateproject(pid integer, projectname text, projectcode text, projectdescription text, picontact integer, createdby integer, createddate date, modifiedby integer, modifieddate date, projectstatus integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update project set name = projectName, code = projectCode, description = projectDescription, pi_contact = piContact, created_by = createdBy, created_date = createdDate, 
      modified_by = modifiedBy, modified_date = modifiedDate, status = projectStatus where project_id = pId;
    END;
$$;

CREATE OR REPLACE FUNCTION updateprojectpropertybyid(projectid integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update project set props = jsonb_set(props, ('{'||propertyId::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      where project_id=projectId;
  END;
$$;

CREATE OR REPLACE FUNCTION updateprojectpropertybyname(projectid integer, propertyname text, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update project
      set props = jsonb_set(props, ('{'||property.cv_id::text||'}')::text[], ('"'||propertyValue||'"')::jsonb)
      from property
      where project_id=projectId;
  END;
$$;

CREATE OR REPLACE FUNCTION updateprotocol(pid integer, pname text, pdescription text, ptypeid integer, pplatformid integer, pcreatedby integer, pcreateddate date, pmodifiedby integer, pmodifieddate date, pstatus integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i integer;
    BEGIN
    update protocol set name=pname, description=pdescription, type_id=ptypeid, platform_id=pplatformid, created_by=pcreatedby, created_date=pcreateddate, modified_by=pmodifiedby, modified_date=pmodifieddate, status=pstatus
     where protocol_id = pid;
      GET DIAGNOSTICS i = ROW_COUNT;
      return i;
    END;
$$;

CREATE OR REPLACE FUNCTION updatereference(id integer, referencename text, referenceversion text, referencelink text, filepath text, createdby integer, createddate date, modifiedby integer, modifieddate date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        update reference set name=referenceName, version=referenceVersion, link=referenceLink, file_path=filePath, created_by = createdBy, created_date = createdDate, modified_by = modifiedBy, modified_date = modifiedDate
        where reference_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updaterole(roleid integer, rolename text, rolecode text, readtables integer[], writetables integer[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update role set role_name=roleName, role_code=roleCode, read_tables=readTables, write_tables=writeTables
     where role_id = roleId;
    END;
$$;

CREATE OR REPLACE FUNCTION updatevariant(id integer, variantcode text, createdby integer, createddate date, modifiedby integer, modifieddate date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update variant set code=variantCode, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate
     where variant_id = id;
    END;
$$;

CREATE OR REPLACE FUNCTION updatevendorprotocol(pid integer, pname text, pvendorid integer, pprotocolid integer, pstatus integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i integer;
    BEGIN
    update vendor_protocol set name=pname, vendor_id=pvendorid, protocol_id=pprotocolid, status=pstatus
     where vendor_protocol_id = pid;
      GET DIAGNOSTICS i = ROW_COUNT;
      return i;
    END;
$$;

--changeset kpalis:dnasample_uuid_update context:general splitStatements:false runOnChange:true
CREATE OR REPLACE FUNCTION updatednasample(id integer, dnasamplename text, dnasamplecode text, dnasampleplatename text, dnasamplenum text, wellrow text, wellcol text, projectid integer, germplasmid integer, createdby integer, createddate date, modifiedby integer, modifieddate date, dnasamplestatus integer, _uuid text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update dnasample set name=dnaSampleName, code=dnaSampleCode, platename=dnaSamplePlateName, num=dnaSampleNum, well_row=wellRow, well_col=wellCol, project_id=projectId, germplasm_id=germplasmId, created_by=createdBy, created_date=createdDate, modified_by=modifiedBy, modified_date=modifiedDate, status=dnaSampleStatus, uuid=_uuid
     where dnasample_id = id;
    END;
$$;
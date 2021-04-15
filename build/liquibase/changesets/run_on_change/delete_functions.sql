--liquibase formatted sql

--### DELETE FUNCTIONS ###---
--## These are just wrappers to delete statements. We are using this approach because we weren't able to find a good ORM that supports jsonb.

--changeset kpalis:delete_functions context:general splitStatements:false runOnChange:true

CREATE OR REPLACE FUNCTION deleteanalysis(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from analysis where analysis_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deleteanalysisparameter(id integer, parametername text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update analysis set parameters = parameters - parameterName
      where analysis_id=id;
    return parameterName;
  END;
$$;

CREATE OR REPLACE FUNCTION deletecontact(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from contact where contact_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletecv(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from cv where cv_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletecvgroup(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     DECLARE
      i integer;
     BEGIN
     delete from cvgroup where cvgroup_id = id;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION deletedataset(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from dataset where dataset_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletedbxref(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     DECLARE
      i integer;
     BEGIN
     delete from dbxref where dbxref_id = id;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION deletedisplay(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from display where display_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletednarun(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from dnarun where dnarun_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletednarunpropertybyid(id integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update dnarun
    set props = props - propertyId::text
    where dnarun_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deletednarunpropertybyname(id integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update dnarun
      set props = props - property.cv_id::text
      from property
      where dnarun_id=id;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deletednasample(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from dnasample where dnasample_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletednasamplepropertybyid(id integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update dnasample
    set props = props - propertyId::text
    where dnasample_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deletednasamplepropertybyname(id integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update dnasample
      set props = props - property.cv_id::text
      from property
      where dnasample_id=id;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deleteexperiment(eid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from experiment where experiment_id = eId;
    return eId;
    END;
$$;

CREATE OR REPLACE FUNCTION deletegermplasm(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from germplasm where germplasm_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletegermplasmpropertybyid(id integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update germplasm
    set props = props - propertyId::text
    where germplasm_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deletegermplasmpropertybyname(id integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update germplasm
      set props = props - property.cv_id::text
      from property
      where germplasm_id=id;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deletejob(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from job where job_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletelinkagegroup(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from linkage_group where linkage_group_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletemanifest(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from manifest where manifest_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletemapset(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from mapset where mapset_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletemapsetpropertybyid(id integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update mapset
    set props = props - propertyId::text
    where mapset_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deletemapsetpropertybyname(id integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update mapset
      set props = props - property.cv_id::text
      from property
      where mapset_id=id;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deletemarker(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from marker where marker_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletemarkergroup(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from marker_group where marker_group_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletemarkergroupbyname(_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
        i integer;
    BEGIN
    	delete from marker_group where name = _name;
    	GET DIAGNOSTICS i = ROW_COUNT;
      	return i;
    END;
$$;

CREATE OR REPLACE FUNCTION deletemarkerinmarkergroupbyid(id integer, markerid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update marker_group 
    set markers = markers - markerId::text
    where marker_group_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION deletemarkerinmarkergroupbyname(id integer, markername text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with markerInfo as (select marker_id from marker where name=markerName)
    update marker_group 
      set markers = markers - markerInfo.marker_id::text
      from markerInfo
      where marker_group_id=id;
    return markerName;
  END;
$$;

CREATE OR REPLACE FUNCTION deletemarkerlinkagegroup(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from marker_linkage_group where marker_linkage_group_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletemarkerpropertybyid(id integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update marker
    set props = props - propertyId::text
    where marker_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deletemarkerpropertybyname(id integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update marker
      set props = props - property.cv_id::text
      from property
      where marker_id=id;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deleteorganization(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from organization where organization_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deleteplatform(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
 	 DECLARE
 	 	i integer;
     BEGIN
     delete from platform where platform_id = id;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;

CREATE OR REPLACE FUNCTION deleteplatformpropertybyid(id integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update platform
    set props = props - propertyId::text
    where platform_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deleteplatformpropertybyname(id integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update platform
      set props = props - property.cv_id::text
      from property
      where platform_id=id;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deleteproject(pid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from project where project_id = pId;
    return pId;
    END;
$$;

CREATE OR REPLACE FUNCTION deleteprojectpropertybyid(projectid integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update project
    set props = props - propertyId::text
    where project_id=projectId;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deleteprojectpropertybyname(projectid integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update project
      set props = props - property.cv_id::text
      from property
      where project_id=projectId;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deleteprotocol(pid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i integer;
    BEGIN
    delete from protocol where protocol_id = pId;
    GET DIAGNOSTICS i = ROW_COUNT;
    return i;
    END;
$$;

CREATE OR REPLACE FUNCTION deleteprotocolpropertybyid(protocolid integer, propertyid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update protocol 
    set props = props - propertyId::text
    where protocol_id=protocolId;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION deleteprotocolpropertybyname(protocolid integer, propertyname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    with property as (select cv_id from cv where term=propertyName)
    update protocol 
      set props = props - property.cv_id::text
      from property
      where protocol_id=protocolId;
    return propertyName;
  END;
$$;

CREATE OR REPLACE FUNCTION deletereference(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from reference where reference_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deleterole(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from role where role_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletevariant(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    delete from variant where variant_id = id;
    return id;
    END;
$$;

CREATE OR REPLACE FUNCTION deletevendorprotocol(pid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i integer;
    BEGIN
    delete from vendor_protocol where vendor_protocol_id = pId;
    GET DIAGNOSTICS i = ROW_COUNT;
    return i;
    END;
$$;
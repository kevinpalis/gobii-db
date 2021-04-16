--liquibase formatted sql

--### UPSERT FUNCTIONS ###---
--## Upsert = update OR insert. These functions handle jsonb upsert mechanism.

--changeset kpalis:upsert_functions context:general splitStatements:false runOnChange:true

CREATE OR REPLACE FUNCTION upsertanalysisparameter(id integer, parametername text, parametervalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    paramCol jsonb;
  BEGIN
    select parameters into paramCol from analysis where analysis_id=id;
    if paramCol is null then
      update analysis set parameters = ('{"'||parameterName||'": "'||parameterValue||'"}')::jsonb
        where analysis_id=id;
    else
      update analysis set parameters = parameters || ('{"'||parameterName||'": "'||parameterValue||'"}')::jsonb
        where analysis_id=id;
    end if;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertdatasetvendorprotocol(pid integer, pdatasetid integer, pvendorprotocolid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i integer;
    BEGIN
	    update marker m set dataset_vendor_protocol = dataset_vendor_protocol || ('{"'||pdatasetid||'": "'||pvendorprotocolid||'"}')::jsonb
		where m.marker_id = pid;
	    GET DIAGNOSTICS i = ROW_COUNT;
	    return i;
    END;
$$;

CREATE OR REPLACE FUNCTION upsertdnarunpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update dnarun set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where dnarun_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertdnarunpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update dnarun set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where dnarun_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertdnasamplepropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update dnasample set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where dnasample_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertdnasamplepropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update dnasample set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where dnasample_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertgermplasmpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update germplasm set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where germplasm_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertgermplasmpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update germplasm set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where germplasm_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertkvpfromforeigntable(foreigntable text, sourcekeycol text, sourcevaluecol text, targettable text, targetidcol text, targetjsonbcol text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
    declare
        rec distinct_source_keys;
        total integer;
        i integer;
    BEGIN
        total = 0;
        i = 0;
        for rec in
            execute format ('select distinct %I from %I', sourceKeyCol, foreignTable)
        loop
            execute format ('
            update %I t set %I = %I || (''{"''||f.%I||''": "''||f.%I||''"}'')::jsonb
            from %I f
            where t.%I=f.%I::integer
            and f.%I=$1
            and f.%I is not null;
            ', targetTable, targetJsonbCol, targetJsonbCol, sourceKeyCol, sourceValueCol, foreignTable, targetIdCol, targetIdCol, sourceKeyCol, sourceValueCol)
            using rec.key;
            GET DIAGNOSTICS i = ROW_COUNT;
            total = total + i;
        end loop;
        return total;
    END;
$_$;

CREATE OR REPLACE FUNCTION upsertmapsetpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update mapset set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where mapset_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertmapsetpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update mapset set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where mapset_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertmarkergroup(_name text, _code text, _markers text, _germplasm_group text, _created_by integer, _created_date date, _modified_by integer, _modified_date date, _status integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   BEGIN
     insert into marker_group (name, code, markers, germplasm_group, created_by, created_date, modified_by, modified_date, status)
      values (_name, _code, _markers::jsonb, _germplasm_group, _created_by, _created_date, _modified_by, _modified_date, _status)
      on CONFLICT (name) do UPDATE
      	set name=_name, code=_code, markers=_markers::jsonb, germplasm_group=_germplasm_group, created_by=_created_by, created_date=_created_date, modified_by=_modified_by, modified_date=_modified_date, status=_status;
    select marker_group_id from marker_group where name=_name into id;
   END;
 $$;

CREATE OR REPLACE FUNCTION upsertmarkerpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update marker set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where marker_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertmarkerpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update marker set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where marker_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertmarkertomarkergroupbyid(id integer, markerid integer, favallele text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update marker_group set markers = markers || ('{"'||markerId::text||'": "'||favAllele||'"}')::jsonb
      where marker_group_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertmarkertomarkergroupbyname(id integer, markername text, favallele text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    markerId integer;
  BEGIN
    select marker_id into markerId from marker where name=markerName;
    update marker_group set markers = markers || ('{"'||markerId::text||'": "'||favAllele||'"}')::jsonb
      where marker_group_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertplatformpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update platform set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where platform_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertplatformpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update platform set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where platform_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertprojectpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update project set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where project_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertprojectpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update project set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where project_id=id;
    return propertyId;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertprotocolpropertybyid(id integer, propertyid integer, propertyvalue text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    update protocol set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where protocol_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION upsertprotocolpropertybyname(id integer, propertyname text, propertyvalue text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update protocol set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where protocol_id=id;
    return propertyId;
  END;
$$;

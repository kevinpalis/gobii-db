--liquibase formatted sql

--### GET/READ FUNCTIONS ###---

--changeset kpalis:get_functions context:general splitStatements:false runOnChange:true

CREATE OR REPLACE FUNCTION getallanalysisparameters(id integer) RETURNS TABLE(property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select (jsonb_each_text(parameters)).* from analysis where analysis_id=id;
    END;
$$;

CREATE OR REPLACE FUNCTION getallchrlenbydataset(datasetid integer) RETURNS TABLE(linkage_group_name character varying, linkage_group_length integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select distinct mlp.linkage_group_name, (mlp.linkage_group_stop - mlp.linkage_group_stop)::integer
    from marker m
    left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
    where m.dataset_marker_idx ? datasetId::text;
  END;
$$;

CREATE OR REPLACE FUNCTION getallchrlenbydatasetandmap(datasetid integer, mapid integer) RETURNS TABLE(linkage_group_name character varying, linkage_group_length integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
  return query
  select distinct mlp.linkage_group_name, (mlp.linkage_group_stop - mlp.linkage_group_stop)::integer
  from marker m
  left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
  where m.dataset_marker_idx ? datasetId::text
  and mlp.map_id=mapId;
  END;
$$;

CREATE OR REPLACE FUNCTION getallchrlenbymarkerlist(markerlist text) RETURNS TABLE(linkage_group_name character varying, linkage_group_length integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select distinct mlp.linkage_group_name, (mlp.linkage_group_stop - mlp.linkage_group_stop)::integer
    from unnest(markerList::integer[]) ml(m_id) 
    left join marker m on ml.m_id = m.marker_id
    left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getallcontactsbyrole(roleid integer) RETURNS SETOF contact
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select c.* from contact c, role r where r.role_id = roleId and r.role_id = any(c.roles);
  END;
$$;

CREATE OR REPLACE FUNCTION getalljobsbystatus(_status text) RETURNS TABLE(job_id integer, name text, type text, payload_type text, message text, submitted_by text, submitted_date timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
	DECLARE
        _status_id integer;
	BEGIN
		select cvid into _status_id from getCvId(_status, 'job_status', 1);
		RETURN QUERY 
		select j.job_id, j.name, getCvTerm(j.type_id), getCvTerm(j.payload_type_id), j.message, (select username from contact where contact_id=j.submitted_by), j.submitted_date
		from job j 
		where j.status = _status_id;
	END;
$$;

CREATE OR REPLACE FUNCTION getallmarkermetadatabydataset(datasetid integer) RETURNS TABLE(marker_name text, linkage_group_name character varying, start numeric, stop numeric, mapset_name text, platform_name text, variant_id integer, code text, ref text, alts text, sequence text, reference_name text, primers jsonb, probsets jsonb, strand_name text)
    LANGUAGE plpgsql
    AS $$
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
$$;

CREATE OR REPLACE FUNCTION getallmarkermetadatabydatasetandmap(datasetid integer, mapid integer) RETURNS TABLE(marker_name text, linkage_group_name character varying, start numeric, stop numeric, mapset_name text, platform_name text, variant_id integer, code text, ref text, alts text, sequence text, reference_name text, primers jsonb, probsets jsonb, strand_name text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.name as marker_name, mlp.linkage_group_name, mlp.start, mlp.stop, mlp.mapset_name, p.name as platform_name, m.variant_id, m.code, m.ref, array_to_string(m.alts, ',', '?'), m.sequence, r.name as reference_name, m.primers, m.probsets, cv.term as strand_name
	from marker m inner join platform p on m.platform_id = p.platform_id
	left join reference r on m.reference_id = r.reference_id
	left join cv on m.strand_id = cv.cv_id 
	left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
	where m.dataset_marker_idx ? datasetId::text
	and mlp.map_id=mapId
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$;

CREATE OR REPLACE FUNCTION getallmarkersinmarkergroup(id integer) RETURNS TABLE(marker_id integer, marker_name text, favorable_allele text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as marker_id, marker.name as marker_name, p1.value as favorable_allele
    from marker, (select (jsonb_each_text(markers)).* from marker_group where marker_group_id=id) as p1
    where marker.marker_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallmarkersinmarkergroups(_namelist text) RETURNS TABLE(marker_group_name text, marker_id text, favorable_alleles text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select mgl.group_name, (jsonb_each_text(mg.markers)).*
    from unnest(_nameList::text[]) mgl(group_name)     left join marker_group mg on mgl.group_name = mg.name;
  END;
$$;

CREATE OR REPLACE FUNCTION getallmarkersinmarkergroups(_idlist text, _platformlist text) RETURNS TABLE(marker_group_id integer, marker_group_name text, marker_id text, favorable_alleles text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select t1.* from 
    (select mg.marker_group_id, mg.name, (jsonb_each_text(mg.markers)).*
    from unnest(_idList::text[]) mgl(marker_group_id)
    left join marker_group mg on mgl.marker_group_id::integer = mg.marker_group_id) as t1
    inner join marker m on m.marker_id = t1.key::integer
    where (_platformList is null OR m.platform_id in (select * from unnest(_platformList::integer[])));
  END;
$$;

CREATE OR REPLACE FUNCTION getallmarkersinmarkergroupsbyid(_idlist text) RETURNS TABLE(marker_group_id integer, marker_group_name text, marker_id text, favorable_alleles text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select mg.marker_group_id, mg.name, (jsonb_each_text(mg.markers)).*
    from unnest(_idList::text[]) mgl(marker_group_id)
    left join marker_group mg on mgl.marker_group_id::integer = mg.marker_group_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getallprojectmetadatabydataset(datasetid integer) RETURNS TABLE(project_pi_contact text, project_name text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, platform_name text, vendor_protocol_name text, vendor_name text, protocol_name text, analysis_name text, dataset_name text, dataset_type text)
    LANGUAGE plpgsql
    AS $$
   BEGIN
     return query
     select c.firstname || ' ' || c.lastname as PI
	    ,p.name as project_name
	    ,(p.props->>getPropertyIdByNamesAndType('project_prop','genotyping_purpose',1)::text)
	    ,(p.props->>getPropertyIdByNamesAndType('project_prop','date_sampled',1)::text)
	    ,(p.props->>getPropertyIdByNamesAndType('project_prop','division',1)::text)
	    ,(p.props->>getPropertyIdByNamesAndType('project_prop','study_name',1)::text)
	    ,e.name as exp_name
	    ,plt.name  as plt_name
	    ,vp.name as vp_name
	    ,v.name as v_name
	    ,pr.name as pr_name
	    ,a.name as analysis_name
	    ,d.name as dataset_name
	    ,cv.term as dateset_type
       from dataset d
	left join analysis a on d.callinganalysis_id = a.analysis_id
	left join experiment e on d.experiment_id = e.experiment_id
	left join project p on p.project_id = e.project_id
	left join contact c on p.pi_contact = c.contact_id
	left join vendor_protocol vp on vp.vendor_protocol_id = e.vendor_protocol_id
	left join organization v on v.organization_id = vp.vendor_id
	left join protocol pr on pr.protocol_id = vp.protocol_id
	left join platform plt on pr.platform_id = plt.platform_id
	left join cv on cv.cv_id = d.type_id
       where d.dataset_id = datasetId;
   END;
 $$;

CREATE OR REPLACE FUNCTION getallpropertiesofdnarun(id integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from dnarun where dnarun_id=id) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallpropertiesofdnasample(id integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from dnasample where dnasample_id=id) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallpropertiesofgermplasm(id integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from germplasm where germplasm_id=id) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallpropertiesofmapset(id integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from mapset where mapset_id=id) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallpropertiesofmarker(id integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from marker where marker_id=id) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallpropertiesofplatform(id integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from platform where platform_id=id) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallpropertiesofproject(projectid integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from project where project_id=projectId) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallpropertiesofprotocol(protocolid integer) RETURNS TABLE(property_id integer, property_name text, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select p1.key::int as property_id, cv.term as property_name, p1.value as property_value
    from cv, (select (jsonb_each_text(props)).* from protocol where protocol_id=protocolId) as p1
    where cv.cv_id = p1.key::int;
    END;
$$;

CREATE OR REPLACE FUNCTION getallsamplemetadatabydataset(datasetid integer) RETURNS TABLE(dnarun_name text, sample_name text, germplasm_name text, external_code text, germplasm_type text, species text, platename text, num text, well_row text, well_col text)
    LANGUAGE plpgsql
    AS $$
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
$$;

CREATE OR REPLACE FUNCTION getcvid(_term text, _groupname text, _grouptype integer, OUT cvid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
    	select cv.cv_id into cvid 
    	from cv inner join cvgroup cg on cv.cvgroup_id = cg.cvgroup_id
    	where cg.type=_grouptype
    	and cg.name=_groupname
    	and cv.term=_term;
    END;
$$;

CREATE OR REPLACE FUNCTION getcvterm(_cv_id integer, OUT cvterm text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
    	select cv.term into cvterm 
    	from cv
    	where cv.cv_id=_cv_id;
    END;
$$;

CREATE OR REPLACE FUNCTION getcvtermsbycvgroupname(cvgroupname text) RETURNS TABLE(term text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN query
	select cv.term from cv, cvgroup
	where cv.cvgroup_id = cvgroup.cvgroup_id and cvgroup.name = cvgroupName;
END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbydnasamplenames(dnasamplenames text) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	select dr.dnarun_id
	from dnasample ds
	inner join unnest(dnasampleNames::text[]) dsn(s_name) on ds.name = dsn.s_name
	inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
	order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbydnasamplenamesandpi(dnasamplenames text, piid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
        select dr.dnarun_id
        from dnasample ds
        inner join unnest(dnasampleNames::text[]) dsn(s_name) on ds.name = dsn.s_name
        inner join project p on p.project_id = ds.project_id
        inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
        where p.pi_contact = piId
        order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbydnasamplenamesandproject(dnasamplenames text, projectid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
        select dr.dnarun_id
        from dnasample ds
        inner join unnest(dnasampleNames::text[]) dsn(s_name) on ds.name = dsn.s_name
        inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
        where ds.project_id = projectId
        order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbyexternalcodes(externalcodes text) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	select dr.dnarun_id
	from germplasm g
	inner join unnest(externalCodes::text[]) gx(ex_code) on g.external_code = gx.ex_code
	inner join dnasample ds on ds.germplasm_id = g.germplasm_id
	inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
	order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbyexternalcodesandpi(externalcodes text, piid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
        select dr.dnarun_id
        from germplasm g
        inner join unnest(externalCodes::text[]) gx(ex_code) on g.external_code = gx.ex_code
        inner join dnasample ds on ds.germplasm_id = g.germplasm_id
        inner join project p on p.project_id = ds.project_id
        inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
        where p.pi_contact = piId
        order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbyexternalcodesandproject(externalcodes text, projectid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
        select dr.dnarun_id
        from germplasm g
        inner join unnest(externalCodes::text[]) gx(ex_code) on g.external_code = gx.ex_code
        inner join dnasample ds on ds.germplasm_id = g.germplasm_id
        inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
        where ds.project_id = projectId
        order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbygermplasmnames(germplasmnames text) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	select dr.dnarun_id
	from germplasm g
	inner join unnest(germplasmNames::text[]) gn(g_name) on g.name = gn.g_name
	inner join dnasample ds on ds.germplasm_id = g.germplasm_id
	inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
	order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbygermplasmnamesandpi(germplasmnames text, piid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
        select dr.dnarun_id
        from germplasm g
        inner join unnest(germplasmNames::text[]) gn(g_name) on g.name = gn.g_name
        inner join dnasample ds on ds.germplasm_id = g.germplasm_id
        inner join project p on p.project_id = ds.project_id
        inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
        where p.pi_contact = piId
        order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbygermplasmnamesandproject(germplasmnames text, projectid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
        select dr.dnarun_id
        from germplasm g
        inner join unnest(germplasmNames::text[]) gn(g_name) on g.name = gn.g_name
        inner join dnasample ds on ds.germplasm_id = g.germplasm_id
        inner join dnarun dr on dr.dnasample_id = ds.dnasample_id
        where ds.project_id = projectId
        order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbypi(piid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	select dr.dnarun_id
	from project p
	inner join dnasample ds on p.project_id = ds.project_id
	inner join dnarun dr on ds.dnasample_id = dr.dnasample_id
	where p.pi_contact = piId
	order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunidsbyproject(projectid integer) RETURNS TABLE(dnarun_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	select dr.dnarun_id
	from project p
	inner join dnasample ds on p.project_id = ds.project_id
	inner join dnarun dr on ds.dnasample_id = dr.dnasample_id
	where p.project_id = projectId
	order by dr.dnarun_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunnamesbydataset(datasetid integer) RETURNS TABLE(dnarun_id integer, dnarun_name text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select  dr.dnarun_id, dr.name as dnarun_name 
	from dnarun dr
	where dr.dataset_dnarun_idx ? datasetId::text
	order by dr.dataset_dnarun_idx->datasetId::text;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunpropertybyid(id integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from dnarun where dnarun_id=id;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnarunpropertybyname(id integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from dnarun, property
      where dnarun_id=id);
  END;
$$;

CREATE OR REPLACE FUNCTION getdnasamplepropertybyid(id integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from dnasample where dnasample_id=id;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getdnasamplepropertybyname(id integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from dnasample, property
      where dnasample_id=id);
  END;
$$;

CREATE OR REPLACE FUNCTION getexperimentnamesbyprojectid(projectid integer) RETURNS TABLE(id integer, experiment_name text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select experiment_id, name from experiment where project_id = projectId;
  END;
$$;

CREATE OR REPLACE FUNCTION getexperimentsbyprojectid(projectid integer) RETURNS SETOF experiment
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select * from experiment where project_id = projectId;
  END;
$$;

CREATE OR REPLACE FUNCTION getgermplasmpropertybyid(id integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from germplasm where germplasm_id=id;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getgermplasmpropertybyname(id integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from germplasm, property
      where germplasm_id=id);
  END;
$$;

CREATE OR REPLACE FUNCTION getmanifestbyexperimentid(experimentid integer) RETURNS SETOF manifest
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select * from manifest where manifest_id in (select manifest_id from experiment where experiment_id = experimentId);
  END;
$$;

CREATE OR REPLACE FUNCTION getmapsetpropertybyid(id integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from mapset where mapset_id=id;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getmapsetpropertybyname(id integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from mapset, property
      where mapset_id=id);
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkerallmapsetinfobydataset(dsid integer, mapid integer) RETURNS TABLE(marker_name text, platform_name text, mapset_id integer, mapset_name text, mapset_type text, linkage_group_name text, linkage_group_start text, linkage_group_stop text, marker_linkage_group_start text, marker_linkage_group_stop text, reference_name text, reference_version text)
    LANGUAGE plpgsql
    AS $$
BEGIN
        RETURN QUERY
        with mlgt as (
                        select distinct on (mr.marker_id, mapset_id) mr.marker_id, lg.name as linkage_group_name, lg.start as lg_start,lg.stop as lg_stop,  mlg.start, mlg.stop,ms.mapset_id, ms.name as mapset_name,ms.type_id,mr.name as marker_name,mr.platform_id,mr.reference_id,mr.dataset_marker_idx
                        from marker mr
                        left join marker_linkage_group mlg on mr.marker_id = mlg.marker_id
                        left join linkage_group lg on lg.linkage_group_id = mlg.linkage_group_id
                        left join mapset ms on ms.mapset_id = lg.map_id
                        where mr.dataset_marker_idx ? dsId::text
                )
                select mlgt.marker_name
                                ,p.name
                                ,mlgt.mapset_id
                        ,mlgt.mapset_name as mapset_name
                        ,cv.term as map_type
                        ,mlgt.linkage_group_name::text as lg_name
                        ,mlgt.lg_start::text as lg_start
                        ,mlgt.lg_stop::text as lg_stop
                        ,mlgt.start::text as mlg_start
                        ,mlgt.stop::text as mlg_stop
                        ,r.name,r.version
                from mlgt
                left join platform p on p.platform_id = mlgt.platform_id
                left join reference r on r.reference_id = mlgt.reference_id
                left join cv on cv_id =  mlgt.type_id
                order by mlgt.mapset_id, (mlgt.dataset_marker_idx->>dsId::text)::integer;
END;
$$;

CREATE OR REPLACE FUNCTION getmarkerids(markernames text, platformlist text) RETURNS TABLE(marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
	from marker m
	left outer join unnest(markerNames::text[]) mn(m_name) on m.name = mn.m_name
	left outer join unnest(platformList::integer[]) p(p_id) on m.platform_id = p.p_id
	where p.p_id is not null
	and mn.m_name is not null
	order by m.marker_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkeridsbymarkernames(markernames text) RETURNS TABLE(marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
	from marker m
	inner join unnest(markerNames::text[]) mn(m_name) on m.name = mn.m_name
	order by m.marker_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkeridsbymarkernamesandplatformlist(markernames text, platformlist text) RETURNS TABLE(marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
	from marker m
	inner join unnest(markerNames::text[]) mn(m_name) on m.name = mn.m_name
	inner join unnest(platformList::integer[]) p(p_id) on m.platform_id = p.p_id
	order by m.marker_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkeridsbyplatformlist(platformlist text) RETURNS TABLE(marker_id integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id
	from marker m
	inner join unnest(platformList::integer[]) p(p_id) on m.platform_id = p.p_id
	order by m.marker_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkeridsbysamplesanddatasettype(samplelist text, datasettypeid integer) RETURNS TABLE(marker_id integer)
    LANGUAGE plpgsql
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
$$;

CREATE OR REPLACE FUNCTION getmarkeridsbysamplesplatformsanddatasettype(samplelist text, platformlist text, datasettypeid integer) RETURNS TABLE(marker_id integer)
    LANGUAGE plpgsql
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
$$;

CREATE OR REPLACE FUNCTION getmarkerinmarkergroupbyid(id integer, markerid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select markers->markerId::text into value from marker_group where marker_group_id=id;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkerinmarkergroupbyname(id integer, markername text) RETURNS TABLE(marker_id integer, favorable_allele text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    with markerInfo as (select marker_id from marker where name=markerName)
    select markerInfo.marker_id, (props->markerInfo.marker_id::text)::text as favAllele
      from marker_group, markerInfo
      where marker_group_id=id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkermapsetinfobydataset(dsid integer, mapid integer) RETURNS TABLE(marker_name text, platform_name text, mapset_name text, mapset_type text, linkage_group_name text, linkage_group_start text, linkage_group_stop text, marker_linkage_group_start text, marker_linkage_group_stop text, reference_name text, reference_version text)
    LANGUAGE plpgsql
    AS $$
BEGIN
        RETURN QUERY
        with mlgt as (
                        select distinct on (mr.marker_id, mapset_id) mr.marker_id, lg.name as linkage_group_name, lg.start as lg_start,lg.stop as lg_stop,  mlg.start, mlg.stop,ms.mapset_id, ms.name as mapset_name,ms.type_id,mr.name as marker_name,mr.platform_id,mr.reference_id
                        from marker mr
                        left join marker_linkage_group mlg on mr.marker_id = mlg.marker_id
                        left join linkage_group lg on lg.linkage_group_id = mlg.linkage_group_id
                        left join mapset ms on ms.mapset_id = lg.map_id
                        where mr.dataset_marker_idx ? dsId::text
                )
                select mlgt.marker_name,p.name
                        , COALESCE(t.mpsn,mlgt.mapset_name) as mapset_name
                        , COALESCE(t.mpstype,cv.term) as mapset_type
                        ,COALESCE(t.lgn,mlgt.linkage_group_name::text) as lg_name
                        ,COALESCE(t.lgst,mlgt.lg_start::text) as lg_start
                        ,COALESCE(t.lgsp,mlgt.lg_stop::text) as lg_stop
                        ,COALESCE(t.mlgst,mlgt.start::text) as mlg_start
                        ,COALESCE(t.mlgst,mlgt.stop::text) as mlg_stop
                        ,r.name,r.version
                from mlgt
                left join platform p on p.platform_id = mlgt.platform_id
                left join reference r on r.reference_id = mlgt.reference_id
                left join cv on cv_id =  mlgt.type_id
                left join (
                        select  ' '::text as lgn
                                ,' '::text as mpsn
                                ,' '::text as lgst
                                ,' '::text as lgsp
                                ,' '::text as mlgst
                                ,' '::text as mlgsp
                                ,' '::text as mpstype
                ) t on mlgt.mapset_id != mapId
                order by mlgt.mapset_id;
END;
$$;

CREATE OR REPLACE FUNCTION getmarkermapsetinfobymarkerlist(markerlist text) RETURNS TABLE(marker_name text, platform_name text, mapset_id integer, mapset_name text, mapset_type text, linkage_group_name text, linkage_group_start text, linkage_group_stop text, marker_linkage_group_start text, marker_linkage_group_stop text, reference_name text, reference_version text)
    LANGUAGE plpgsql
    AS $$
BEGIN
        RETURN QUERY
        with mlgt as (
                        select distinct on (mr.marker_id, mapset_id) mr.marker_id, lg.name as linkage_group_name, lg.start as lg_start,lg.stop as lg_stop,  mlg.start, mlg.stop,ms.mapset_id, ms.name as mapset_name,ms.type_id,mr.name as marker_name,mr.platform_id,mr.reference_id
                        from unnest(markerList::integer[]) ml(m_id)
                        left join marker mr on ml.m_id = mr.marker_id
                        left join marker_linkage_group mlg on mr.marker_id = mlg.marker_id
                        left join linkage_group lg on lg.linkage_group_id = mlg.linkage_group_id
                        left join mapset ms on ms.mapset_id = lg.map_id
                )
                select mlgt.marker_name
                                ,p.name
                                ,mlgt.mapset_id
                        ,mlgt.mapset_name as mapset_name
                        ,cv.term as map_type
                        ,mlgt.linkage_group_name::text as lg_name
                        ,mlgt.lg_start::text as lg_start
                        ,mlgt.lg_stop::text as lg_stop
                        ,mlgt.start::text as mlg_start
                        ,mlgt.stop::text as mlg_stop
                        ,r.name,r.version
                from mlgt
                left join platform p on p.platform_id = mlgt.platform_id
                left join reference r on r.reference_id = mlgt.reference_id
                left join cv on cv_id =  mlgt.type_id
                order by mlgt.mapset_id, mlgt.marker_id;
END;
$$;

CREATE OR REPLACE FUNCTION getmarkernamesbydataset(datasetid integer) RETURNS TABLE(marker_id integer, marker_name text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id, m.name as marker_name
	from marker m
	where m.dataset_marker_idx ? datasetId::text
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkernamesbydatasetandmap(datasetid integer, mapid integer) RETURNS TABLE(marker_id integer, marker_name text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.marker_id, m.name as marker_name
	from marker m
	left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
	where m.dataset_marker_idx ? datasetId::text
	and mlp.map_id=mapId
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkerpropertybyid(id integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from marker where marker_id=id;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkerpropertybyname(id integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from marker, property
      where marker_id=id);
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkerqcmetadatabydataset(datasetid integer) RETURNS TABLE(marker_name text, platform_name text, variant_id integer, variant_code text, marker_ref text, marker_alts text, marker_sequence text, marker_strand text, marker_primer_forw1 text, marker_primer_forw2 text, marker_primer_rev1 text, marker_primer_rev2 text, marker_probe1 text, marker_probe2 text, marker_polymorphism_type text, marker_synonym text, marker_source text, marker_gene_id text, marker_gene_annotation text, marker_polymorphism_annotation text, marker_marker_dom text, marker_clone_id_pos text, marker_genome_build text, marker_typeofrefallele_alleleorder text, marker_strand_data_read text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.name as marker_name, p.name as platform_name, v.variant_id, v.code, m.ref, array_to_string(m.alts, ',', '?'), m.sequence, cv.term as strand_name
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_forw1',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_forw2',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_rev1',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_rev2',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','probe1',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','probe2',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','polymorphism_type',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','synonym',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','source',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','gene_id',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','gene_annotation',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','polymorphism_annotation',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','marker_dom',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','clone_id_pos',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','genome_build',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','typeofrefallele_alleleorder',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','strand_data_read',1)::text)
	from marker m left join platform p on m.platform_id = p.platform_id
	left join cv on m.strand_id = cv.cv_id 
	left join variant v on m.variant_id = v.variant_id
	where m.dataset_marker_idx ? datasetId::text
	order by (m.dataset_marker_idx->>datasetId::text)::integer; 
  END;
$$;

CREATE OR REPLACE FUNCTION getmarkerqcmetadatabymarkerlist(markerlist text) RETURNS TABLE(marker_name text, platform_name text, variant_id integer, variant_code text, marker_ref text, marker_alts text, marker_sequence text, marker_strand text, marker_primer_forw1 text, marker_primer_forw2 text, marker_primer_rev1 text, marker_primer_rev2 text, marker_probe1 text, marker_probe2 text, marker_polymorphism_type text, marker_synonym text, marker_source text, marker_gene_id text, marker_gene_annotation text, marker_polymorphism_annotation text, marker_marker_dom text, marker_clone_id_pos text, marker_genome_build text, marker_typeofrefallele_alleleorder text, marker_strand_data_read text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.name as marker_name, p.name as platform_name, v.variant_id, v.code, m.ref, array_to_string(m.alts, ',', '?'), m.sequence, cv.term as strand_name
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_forw1',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_forw2',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_rev1',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','primer_rev2',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','probe1',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','probe2',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','polymorphism_type',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','synonym',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','source',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','gene_id',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','gene_annotation',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','polymorphism_annotation',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','marker_dom',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','clone_id_pos',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','genome_build',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','typeofrefallele_alleleorder',1)::text)
		,(m.props->>getPropertyIdByNamesAndType('marker_prop','strand_data_read',1)::text)
	from unnest(markerList::integer[]) ml(m_id) 
	left join marker m on ml.m_id = m.marker_id
	left join platform p on m.platform_id = p.platform_id
	left join cv on m.strand_id = cv.cv_id 
	left join variant v on m.variant_id = v.variant_id
	order by m.marker_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmatrixposofmarkers(markerlist text) RETURNS TABLE(dataset_id integer, positions text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	with marker_list as ( select *
	from unnest(markerList::integer[]) ml(m_id) 
	left join marker m on ml.m_id = m.marker_id),
	dataset_list as (
		select  distinct jsonb_object_keys(dataset_marker_idx)::integer as dataset_id
		from marker_list ml
		order by dataset_id)
	select dl.dataset_id, string_agg(COALESCE(ml.dataset_marker_idx ->> dl.dataset_id::text, '-1'), ', ') as idx
	from marker_list ml cross join
	dataset_list dl
	group by dl.dataset_id
	order by dl.dataset_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmatrixposofmarkers(markerlist text, datasettypeid integer) RETURNS TABLE(dataset_id integer, positions text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	with marker_list as ( select *
		from unnest(markerList::integer[]) ml(m_id) 
		left join marker m on ml.m_id = m.marker_id
		order by ml.m_id),
	dataset_list as (
		select distinct jsonb_object_keys(dataset_marker_idx)::integer as dataset_id
		from marker_list ml
		order by dataset_id)
	select rdl.dataset_id, string_agg(COALESCE(ml.dataset_marker_idx ->> rdl.dataset_id::text, '-1'), ', ') as idx
	from marker_list ml cross join
	(select dl.dataset_id from dataset_list dl inner join dataset d on dl.dataset_id = d.dataset_id where d.type_id=datasetTypeId) rdl
	group by rdl.dataset_id
	order by rdl.dataset_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getmatrixposofsamples(samplelist text, datasettypeid integer) RETURNS TABLE(dataset_id integer, positions text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
	with sample_list as ( select *
		from unnest(sampleList::integer[]) sl(s_id) 
		left join dnarun dr on sl.s_id = dr.dnarun_id
		order by sl.s_id),
	dataset_list as (
		select distinct jsonb_object_keys(dataset_dnarun_idx)::integer as dataset_id
		from sample_list sl
		order by dataset_id)
	select rdl.dataset_id, string_agg(COALESCE(sl.dataset_dnarun_idx ->> rdl.dataset_id::text, '-1'), ', ') as idx
	from sample_list sl cross join
	(select dl.dataset_id from dataset_list dl inner join dataset d on dl.dataset_id = d.dataset_id where d.type_id=datasetTypeId) rdl
	group by rdl.dataset_id
	order by rdl.dataset_id;
  END;
$$;

CREATE OR REPLACE FUNCTION getminimalmarkermetadatabydataset(datasetid integer) RETURNS TABLE(marker_name text, alleles text, chrom character varying, pos numeric, strand text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select m.name as marker_name, m.ref || '/' || array_to_string(m.alts, ',', '?') as alleles, mlp.linkage_group_name as chrom, mlp.stop as pos, cv.term as strand
    from marker m
    left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
    left join cv on m.strand_id = cv.cv_id
    where m.dataset_marker_idx ? datasetId::text
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$;

CREATE OR REPLACE FUNCTION getminimalmarkermetadatabydatasetandmap(datasetid integer, mapid integer) RETURNS TABLE(marker_name text, alleles text, chrom character varying, pos numeric, strand text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
	return query
	select m.name as marker_name, m.ref || '/' || array_to_string(m.alts, ',', '?') as alleles, mlp.linkage_group_name as chrom, mlp.stop as pos, cv.term as strand
	from marker m
	left join v_marker_linkage_physical mlp on m.marker_id = mlp.marker_id
	left join cv on m.strand_id = cv.cv_id
	where m.dataset_marker_idx ? datasetId::text
	and mlp.map_id=mapId
	order by m.dataset_marker_idx->datasetId::text;
  END;
$$;

CREATE OR REPLACE FUNCTION getminimalsamplemetadatabydataset(datasetid integer) RETURNS TABLE(dnarun_name text, sample_name text, germplasm_name text, external_code text, germplasm_type text, species text, platename text, num text, well_row text, well_col text)
    LANGUAGE plpgsql
    AS $$
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
$$;

CREATE OR REPLACE FUNCTION getplatformpropertybyid(id integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from platform where platform_id=id;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getplatformpropertybyname(id integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from platform, property
      where platform_id=id);
  END;
$$;

CREATE OR REPLACE FUNCTION getprojectnamesbypi(_contact_id integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    DECLARE
      projects refcursor;
    BEGIN
      OPEN projects FOR 
      select p.project_id, 
					p.name 
			from project p
			where p.pi_contact=_contact_id;
      RETURN projects;
    END;
$$;

CREATE OR REPLACE FUNCTION getprojectpropertybyid(projectid integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from project where project_id=projectId;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getprojectpropertybyname(projectid integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from project, property
      where project_id=projectId);
  END;
$$;

CREATE OR REPLACE FUNCTION getpropertyidbynamesandtype(groupname text, propname text, cvtype integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN ( 
	select cv.cv_id
	from cv inner join cvgroup cg on cv.cvgroup_id = cg.cvgroup_id
	where cg.name = groupName
	and cg.type = cvType
	and term=propName);
END;
$$;

CREATE OR REPLACE FUNCTION getprotocolpropertybyid(protocolid integer, propertyid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    value text;
  BEGIN
    select props->propertyId::text into value from protocol where protocol_id=protocolId;
    return value;
  END;
$$;

CREATE OR REPLACE FUNCTION getprotocolpropertybyname(protocolid integer, propertyname text) RETURNS TABLE(property_id integer, property_value text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    (with property as (select cv_id from cv where term=propertyName)
    select property.cv_id, (props->property.cv_id::text)::text as value
      from protocol, property
      where protocol_id=protocolId);
  END;
$$;

CREATE OR REPLACE FUNCTION getrolesofcontact(contactid integer) RETURNS SETOF role
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select r.* from contact c, role r where c.contact_id = contactId and r.role_id = any(c.roles);
  END;
$$;

CREATE OR REPLACE FUNCTION getsampleqcmetadatabydataset(datasetid integer) RETURNS TABLE(dnarun_name text, germplasm_name text, germplasm_pedigree text, germplasm_type text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_external_code text, germplasm_species text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
        return query
        select dr.name as dnarun_name
                ,g.name as germplasm_name
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','pedigree',1)::text)
                ,cv2.term as type
                ,(dr.props->>getPropertyIdByNamesAndType('dnarun_prop','barcode',1)::text)
                ,p.name as project_name
                ,c.firstname||' '||c.lastname as pi_contact
                ,(p.props->>getPropertyIdByNamesAndType('project_prop','genotyping_purpose',1)::text) as prj
                ,(p.props->>getPropertyIdByNamesAndType('project_prop','date_sampled',1)::text)
                ,(p.props->>getPropertyIdByNamesAndType('project_prop','division',1)::text)
                ,(p.props->>getPropertyIdByNamesAndType('project_prop','study_name',1)::text)
                ,e.name as experiment_name
                ,vp.name as vp_name
                ,v.name as v_name
                ,pr.name as pr_name
                ,ds.name as dataset_name
                ,g.external_code
                ,cv.term as species
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_id',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','seed_source_id',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_subsp',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_heterotic_group',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1_type',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2_type',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3_type',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4',1)::text)
                ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4_type',1)::text)
                ,dns.name  as dnasample_name
                ,dns.platename
                ,dns.num
                ,dns.well_row
                ,dns.well_col
                ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','trial_name',1)::text)
                ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group',1)::text)
                ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group_cycle',1)::text)
                ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_type',1)::text)
                ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_parent_prop',1)::text)
                ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','ref_sample',1)::text)
        from dnarun dr
        left join dnasample dns on dr.dnasample_id = dns.dnasample_id
        left join germplasm g on dns.germplasm_id = g.germplasm_id
        left join project p on dns.project_id = p.project_id
        left join contact c on c.contact_id = p.pi_contact
        left join experiment e on e.experiment_id = dr.experiment_id
        left join dataset ds on ds.dataset_id = datasetId
        left join cv on g.species_id = cv.cv_id
        left join cv cv2 on g.type_id = cv2.cv_id
        left join vendor_protocol vp on vp.vendor_protocol_id = e.vendor_protocol_id
        left join organization v on v.organization_id = vp.vendor_id
        left join protocol pr on pr.protocol_id = vp.protocol_id
        where dr.dataset_dnarun_idx ? datasetId::text
        order by (dr.dataset_dnarun_idx->>datasetId::text)::integer;
  END;
$$;

CREATE OR REPLACE FUNCTION getsampleqcmetadatabymarkerlist(markerlist text) RETURNS TABLE(dnarun_name text, germplasm_name text, germplasm_pedigree text, germplasm_type text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_external_code text, germplasm_species text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
        return query
        with dataset_list as (
                        select distinct jsonb_object_keys(dataset_marker_idx)::integer as ds_id
                        from unnest(markerList::integer[]) ml(m_id)
                        left join marker m on ml.m_id = m.marker_id
                        order by ds_id
                )
        select t.dnarun_name,t.germplasm_name,t.gped,t.type, t.dnarun_barcode, t.project_name, t.project_pi_contact, t.project_genotyping_purpose, t.project_date_sampled, t.project_division, t.project_study_name, t.experiment_name, t.vp_name, t.v_name, t.pr_name, t.dataset_name,  t.exc, t.species,  t.gid, t.gssd, t.gs, t.ghg, t.gp1,t.gpt1, t.gp2,t.gpt2, t.gp3,t.gpt3, t.gp4,t.gpt4, t.dnasample_name, t.plate, t.dnum, t.wr, t.wc, t.dtn, t.dsg, t.dsgc, t.dst, t.dsp, t.drs
        from (
                select distinct on (dl.ds_id, dr.dataset_dnarun_idx->>dl.ds_id::text)
                        dl.ds_id as did
                        ,(dr.dataset_dnarun_idx->>dl.ds_id::text)::integer as ds_idx
                        ,dr.name as dnarun_name
                        ,(dr.props->>getPropertyIdByNamesAndType('dnarun_prop','barcode',1)::text) as dnarun_barcode
                        ,p.name as project_name
                        ,c.firstname||' '||c.lastname as project_pi_contact
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','genotyping_purpose',1)::text) as project_genotyping_purpose
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','date_sampled',1)::text) as project_date_sampled
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','division',1)::text) as project_division
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','study_name',1)::text) as project_study_name
                        ,e.name as experiment_name
                        ,vp.name as vp_name
                        ,v.name as v_name
                        ,pr.name as pr_name
                        ,ds.name as dataset_name
                        ,g.name as germplasm_name
                        ,g.external_code as exc
                        ,cv.term as species
                        ,cv2.term as type
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_id',1)::text) as gid
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','seed_source_id',1)::text) as gssd
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_subsp',1)::text) as gs
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_heterotic_group',1)::text) as ghg
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1',1)::text) as gp1
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1_type',1)::text) as gpt1
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2',1)::text) as gp2
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2_type',1)::text) as gpt2
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3',1)::text) as gp3
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3_type',1)::text) as gpt3
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4',1)::text) as gp4
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4_type',1)::text) as gpt4
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','pedigree',1)::text) as gped
                        ,dns.name  as dnasample_name
                        ,dns.platename as plate
                        ,dns.num as dnum
                        ,dns.well_row as wr
                        ,dns.well_col as wc
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','trial_name',1)::text) as dtn
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group',1)::text) as dsg
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group_cycle',1)::text) as dsgc
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_type',1)::text) as dst
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_parent',1)::text) as dsp
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','ref_sample',1)::text) as drs
                from dataset_list dl
                left join dnarun dr on dr.dataset_dnarun_idx ? dl.ds_id::text
                left join dnasample dns on dr.dnasample_id = dns.dnasample_id
                left join germplasm g on dns.germplasm_id = g.germplasm_id
                left join project p on dns.project_id = p.project_id
                left join contact c on c.contact_id = p.pi_contact
                left join experiment e on e.experiment_id = dr.experiment_id
                left join dataset ds on ds.dataset_id = dl.ds_id
                left join cv on g.species_id = cv.cv_id
                left join cv cv2 on g.type_id = cv2.cv_id
                left join vendor_protocol vp on vp.vendor_protocol_id = e.vendor_protocol_id
                left join organization v on v.organization_id = vp.vendor_id
                left join protocol pr on pr.protocol_id = vp.protocol_id
                ) t
        order by (t.did, t.ds_idx);
  END;
$$;

CREATE OR REPLACE FUNCTION getsampleqcmetadatabymarkerlist(markerlist text, datasettypeid integer) RETURNS TABLE(dnarun_name text, germplasm_name text, germplasm_pedigree text, germplasm_type text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_external_code text, germplasm_species text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text)
    LANGUAGE plpgsql
    AS $$

BEGIN
        return query
        with dataset_list as (
                        select distinct jsonb_object_keys(dataset_marker_idx)::integer as ds_id
                        from unnest(markerList::integer[]) ml(m_id)
                        left join marker m on ml.m_id = m.marker_id
                        order by ds_id
                )
        select t.dnarun_name,t.germplasm_name,t.gped, t.type,  t.dnarun_barcode, t.project_name, t.project_pi_contact, t.project_genotyping_purpose, t.project_date_sampled, t.project_division, t.project_study_name, t.experiment_name, t.vp_name, t.v_name, t.pr_name, t.dataset_name,  t.exc, t.species, t.gid, t.gssd, t.gs, t.ghg, t.gp1,t.gpt1, t.gp2,t.gpt2, t.gp3,t.gpt3, t.gp4,t.gpt4, t.dnasample_name, t.plate, t.dnum, t.wr, t.wc, t.dtn, t.dsg, t.dsgc, t.dst, t.dsp, t.drs
        from (
                select distinct on (dl.ds_id, dr.dataset_dnarun_idx->>dl.ds_id::text)
                        dl.ds_id as did
                        ,(dr.dataset_dnarun_idx->>dl.ds_id::text)::integer as ds_idx
                        ,dr.name as dnarun_name
                        ,(dr.props->>getPropertyIdByNamesAndType('dnarun_prop','barcode',1)::text) as dnarun_barcode
                        ,p.name as project_name
                        ,c.firstname||' '||c.lastname as project_pi_contact
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','genotyping_purpose',1)::text) as project_genotyping_purpose
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','date_sampled',1)::text) as project_date_sampled
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','division',1)::text) as project_division
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','study_name',1)::text) as project_study_name
                        ,e.name as experiment_name
                        ,vp.name as vp_name
                        ,v.name as v_name
                        ,pr.name as pr_name
                        ,dl.name as dataset_name
                        ,g.name as germplasm_name
                        ,g.external_code as exc
                        ,cv.term as species
                        ,cv2.term as type
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_id',1)::text) as gid
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','seed_source_id',1)::text) as gssd
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_subsp',1)::text) as gs
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_heterotic_group',1)::text) as ghg
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1',1)::text) as gp1
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1_type',1)::text) as gpt1
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2',1)::text) as gp2
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2_type',1)::text) as gpt2
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3',1)::text) as gp3
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3_type',1)::text) as gpt3
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4',1)::text) as gp4
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4_type',1)::text) as gpt4
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','pedigree',1)::text) as gped
                        ,dns.name  as dnasample_name
                        ,dns.platename as plate
                        ,dns.num as dnum
                        ,dns.well_row as wr
                        ,dns.well_col as wc
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','trial_name',1)::text) as dtn
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group',1)::text) as dsg
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group_cycle',1)::text) as dsgc
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_type',1)::text) as dst
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_parent',1)::text) as dsp
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','ref_sample',1)::text) as drs
                from
                (select ddl.ds_id, d.name from dataset_list ddl inner join dataset d on ddl.ds_id = d.dataset_id where d.type_id=datasetTypeId) dl
                left join dnarun dr on dr.dataset_dnarun_idx ? dl.ds_id::text
                left join dnasample dns on dr.dnasample_id = dns.dnasample_id
                left join germplasm g on dns.germplasm_id = g.germplasm_id
                left join project p on dns.project_id = p.project_id
                left join contact c on c.contact_id = p.pi_contact
                left join experiment e on e.experiment_id = dr.experiment_id
                left join cv on g.species_id = cv.cv_id
                left join cv cv2 on g.type_id = cv2.cv_id
                left join vendor_protocol vp on vp.vendor_protocol_id = e.vendor_protocol_id
                left join organization v on v.organization_id = vp.vendor_id
                left join protocol pr on pr.protocol_id = vp.protocol_id
                ) t
        order by (t.did, t.ds_idx);
  END;
$$;

CREATE OR REPLACE FUNCTION getsampleqcmetadatabymarkerlistx(markerlist text) RETURNS TABLE(ds_id integer, idx integer, dnarun_name text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_name text, germplasm_external_code text, germplasm_species text, germplasm_type text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, germplasm_pedigree text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
        return query
        with dataset_list as (
                        select distinct jsonb_object_keys(dataset_marker_idx)::integer as ds_id
                        from unnest(markerList::integer[]) ml(m_id)
                        left join marker m on ml.m_id = m.marker_id
                        order by ds_id
                )
        select * from (
                select distinct on (dl.ds_id, dr.dataset_dnarun_idx->>dl.ds_id::text) dl.ds_id as did, (dr.dataset_dnarun_idx->>dl.ds_id::text)::integer as ds_idx
                        ,dr.name as dnarun_name
                        ,(dr.props->>getPropertyIdByNamesAndType('dnarun_prop','barcode',1)::text)
                        ,p.name as project_name
                        ,c.firstname||' '||c.lastname as pi_contact
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','genotyping_purpose',1)::text) as prj
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','date_sampled',1)::text)
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','division',1)::text)
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','study_name',1)::text)
                        ,e.name as experiment_name
                        ,vp.name as vp_name
                        ,v.name as v_name
                        ,pr.name as pr_name
                        ,ds.name as dataset_name
                        ,g.name as germplasm_name
                        ,g.external_code
                        ,cv.term as species
                        ,cv2.term as type
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_id',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','seed_source_id',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_subsp',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_heterotic_group',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','pedigree',1)::text)
                        ,dns.name  as dnasample_name
                        ,dns.platename
                        ,dns.num
                        ,dns.well_row
                        ,dns.well_col
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','trial_name',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group_cycle',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_type',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_parent',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','ref_sample',1)::text)
                from dataset_list dl
                left join dnarun dr on dr.dataset_dnarun_idx ? dl.ds_id::text
                left join dnasample dns on dr.dnasample_id = dns.dnasample_id
                left join germplasm g on dns.germplasm_id = g.germplasm_id
                left join project p on dns.project_id = p.project_id
                left join contact c on c.contact_id = p.pi_contact
                left join experiment e on e.experiment_id = dr.experiment_id
                left join dataset ds on ds.dataset_id = dl.ds_id
                left join cv on g.species_id = cv.cv_id
                left join cv cv2 on g.type_id = cv2.cv_id
                left join vendor_protocol vp on vp.vendor_protocol_id = e.vendor_protocol_id
                left join organization v on v.organization_id = vp.vendor_id
                left join protocol pr on pr.protocol_id = vp.protocol_id
                ) t
        order by (t.did, t.ds_idx);

  END;
$$;

CREATE OR REPLACE FUNCTION getsampleqcmetadatabymarkerlistx(markerlist text, datasettypeid integer) RETURNS TABLE(ds_id integer, idx integer, dnarun_name text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_name text, germplasm_external_code text, germplasm_species text, germplasm_type text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, germplasm_pedigree text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
        return query
        with dataset_list as (
                        select distinct jsonb_object_keys(dataset_marker_idx)::integer as ds_id
                        from unnest(markerList::integer[]) ml(m_id)
                        left join marker m on ml.m_id = m.marker_id
                        order by ds_id
                )
        select * from (
                select distinct on (dl.ds_id, dr.dataset_dnarun_idx->>dl.ds_id::text) dl.ds_id as did, (dr.dataset_dnarun_idx->>dl.ds_id::text)::integer as ds_idx
                        ,dr.name as dnarun_name
                        ,(dr.props->>getPropertyIdByNamesAndType('dnarun_prop','barcode',1)::text)
                        ,p.name as project_name
                        ,c.firstname||' '||c.lastname as pi_contact
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','genotyping_purpose',1)::text) as prj
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','date_sampled',1)::text)
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','division',1)::text)
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','study_name',1)::text)
                        ,e.name as experiment_name
                        ,vp.name as vp_name
                        ,v.name as v_name
                        ,pr.name as pr_name
                        ,ds.name as dataset_name
                        ,g.name as germplasm_name
                        ,g.external_code
                        ,cv.term as species
                        ,cv2.term as type
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_id',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','seed_source_id',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_subsp',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_heterotic_group',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4_type',1)::text)
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','pedigree',1)::text)
                        ,dns.name  as dnasample_name
                        ,dns.platename
                        ,dns.num
                        ,dns.well_row
                        ,dns.well_col
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','trial_name',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group_cycle',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_type',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_parent',1)::text)
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','ref_sample',1)::text)
                from
                (select ddl.ds_id from dataset_list ddl inner join dataset d on ddl.ds_id = d.dataset_id where d.type_id=datasetTypeId) dl
                left join dnarun dr on dr.dataset_dnarun_idx ? dl.ds_id::text
                left join dnasample dns on dr.dnasample_id = dns.dnasample_id
                left join germplasm g on dns.germplasm_id = g.germplasm_id
                left join project p on dns.project_id = p.project_id
                left join contact c on c.contact_id = p.pi_contact
                left join experiment e on e.experiment_id = dr.experiment_id
                left join dataset ds on ds.experiment_id = e.experiment_id
                left join cv on g.species_id = cv.cv_id
                left join cv cv2 on g.type_id = cv2.cv_id
                left join vendor_protocol vp on vp.vendor_protocol_id = e.vendor_protocol_id
                left join organization v on v.organization_id = vp.vendor_id
                left join protocol pr on pr.protocol_id = vp.protocol_id
                ) t
        order by (t.did, t.ds_idx);

  END;
$$;

CREATE OR REPLACE FUNCTION getsampleqcmetadatabysamplelist(samplelist text, datasettypeid integer) RETURNS TABLE(dnarun_name text, germplasm_name text, germplasm_pedigree text, germplasm_type text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_external_code text, germplasm_species text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text)
    LANGUAGE plpgsql
    AS $$

  BEGIN
        return query
        with dataset_list as (
                        select distinct jsonb_object_keys(dataset_dnarun_idx)::integer as ds_id
                        from unnest(sampleList::integer[]) sl(s_id)
                        left join dnarun d on sl.s_id = d.dnarun_id
                        order by ds_id
                )
        select t.dnarun_name,t.germplasm_name,t.gped,t.type  , t.dnarun_barcode, t.project_name, t.project_pi_contact, t.project_genotyping_purpose, t.project_date_sampled, t.project_division, t.project_study_name, t.experiment_name, t.vp_name, t.v_name, t.pr_name, t.dataset_name,  t.exc, t.species,  t.gid, t.gssd, t.gs, t.ghg, t.gp1,t.gpt1, t.gp2,t.gpt2, t.gp3,t.gpt3, t.gp4,t.gpt4,  t.dnasample_name, t.plate, t.dnum, t.wr, t.wc, t.dtn, t.dsg, t.dsgc, t.dst, t.dsp, t.drs
        from (
                select distinct on (dl.ds_id, dr.dataset_dnarun_idx->>dl.ds_id::text)
                        dl.ds_id as did
                        ,(dr.dataset_dnarun_idx->>dl.ds_id::text)::integer as ds_idx
                        ,dr.name as dnarun_name
                        ,(dr.props->>getPropertyIdByNamesAndType('dnarun_prop','barcode',1)::text) as dnarun_barcode
                        ,p.name as project_name
                        ,c.firstname||' '||c.lastname as project_pi_contact
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','genotyping_purpose',1)::text) as project_genotyping_purpose
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','date_sampled',1)::text) as project_date_sampled
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','division',1)::text) as project_division
                        ,(p.props->>getPropertyIdByNamesAndType('project_prop','study_name',1)::text) as project_study_name
                        ,e.name as experiment_name
                        ,vp.name as vp_name
                        ,v.name as v_name
                        ,pr.name as pr_name
                        ,dl.name as dataset_name
                        ,g.name as germplasm_name
                        ,g.external_code as exc
                        ,cv.term as species
                        ,cv2.term as type
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_id',1)::text) as gid
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','seed_source_id',1)::text) as gssd
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_subsp',1)::text) as gs
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','germplasm_heterotic_group',1)::text) as ghg
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1',1)::text) as gp1
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par1_type',1)::text) as gpt1
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2',1)::text) as gp2
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par2_type',1)::text) as gpt2
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3',1)::text) as gp3
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par3_type',1)::text) as gpt3
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4',1)::text) as gp4
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','par4_type',1)::text) as gpt4
                        ,(g.props->>getPropertyIdByNamesAndType('germplasm_prop','pedigree',1)::text) as gped
                        ,dns.name  as dnasample_name
                        ,dns.platename as plate
                        ,dns.num as dnum
                        ,dns.well_row as wr
                        ,dns.well_col as wc
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','trial_name',1)::text) as dtn
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group',1)::text) as dsg
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_group_cycle',1)::text) as dsgc
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_type',1)::text) as dst
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','sample_parent',1)::text) as dsp
                        ,(dns.props->>getPropertyIdByNamesAndType('dnasample_prop','ref_sample',1)::text) as drs
                from
                (select ddl.ds_id, d.name from dataset_list ddl inner join dataset d on ddl.ds_id = d.dataset_id where d.type_id=datasetTypeId) dl
                inner join dnarun dr on dr.dataset_dnarun_idx ? dl.ds_id::text
                inner join unnest(sampleList::integer[]) sl2(s_id) on sl2.s_id = dr.dnarun_id
                left join dnasample dns on dr.dnasample_id = dns.dnasample_id
                left join germplasm g on dns.germplasm_id = g.germplasm_id
                left join project p on dns.project_id = p.project_id
                left join contact c on c.contact_id = p.pi_contact
                left join experiment e on e.experiment_id = dr.experiment_id
                left join cv on g.species_id = cv.cv_id
                left join cv cv2 on g.type_id = cv2.cv_id
                left join vendor_protocol vp on vp.vendor_protocol_id = e.vendor_protocol_id
                left join organization v on v.organization_id = vp.vendor_id
                left join protocol pr on pr.protocol_id = vp.protocol_id
                ) t
        order by (t.did, t.ds_idx);
  END;
$$;

CREATE OR REPLACE FUNCTION gettotaldnarunsindataset(_dataset_id text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    total integer; 
  BEGIN
    select count(*) into total from dnarun where dataset_dnarun_idx ? _dataset_id;
    return total;
  END;
$$;

CREATE OR REPLACE FUNCTION gettotalmarkersindataset(_dataset_id text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    total integer; 
  BEGIN
    select count(*) into total from marker where dataset_marker_idx ? _dataset_id;
    return total;
  END;
$$;

CREATE OR REPLACE FUNCTION gettotalprojects() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    total integer; 
  BEGIN
    select count(*) into total from projects;
    return total;
  END;
$$;
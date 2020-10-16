--liquibase formatted sql

/*
* This function is a victim of circular references. A join to the dataset table via experiment introduced wrong datasets to the output.
*/

--changeset kpalis:fixGetSampleQCMetadataByMarkerListDS context:general splitStatements:false
--validCheckSum: 7:4b5cf8f5312e231368886a1ba7bf7dcc
DROP FUNCTION public.getsampleqcmetadatabymarkerlist(text, integer);
CREATE OR REPLACE FUNCTION public.getsampleqcmetadatabymarkerlist(
	markerlist text,
	datasettypeid integer)
    RETURNS TABLE(dnarun_name text, germplasm_name text, germplasm_pedigree text, germplasm_type text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_external_code text, germplasm_species text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text) 
    LANGUAGE 'plpgsql'
AS $BODY$

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
$BODY$;



--changeset kpalis:fixGetSampleQCMetadataBySampleListDS context:general splitStatements:false
--validCheckSum 7:7b68577ba4a39c3a458a4fc62687725b
DROP FUNCTION public.getsampleqcmetadatabysamplelist(text, integer);
CREATE OR REPLACE FUNCTION public.getsampleqcmetadatabysamplelist(
	samplelist text,
	datasettypeid integer)
    RETURNS TABLE(dnarun_name text, germplasm_name text, germplasm_pedigree text, germplasm_type text, dnarun_barcode text, project_name text, project_pi_contact text, project_genotyping_purpose text, project_date_sampled text, project_division text, project_study_name text, experiment_name text, vendor_protocol_name text, vendor_name text, protocol_name text, dataset_name text, germplasm_external_code text, germplasm_species text, germplasm_id text, germplasm_seed_source_id text, germplasm_subsp text, germplasm_heterotic_group text, germplasm_par1 text, germplasm_par1_type text, germplasm_par2 text, germplasm_par2_type text, germplasm_par3 text, germplasm_par3_type text, germplasm_par4 text, germplasm_par4_type text, dnasample_name text, dnasample_platename text, dnasample_num text, dnasample_well_row text, dnasample_well_col text, dnasample_trial_name text, dnasample_sample_group text, dnasample_sample_group_cycle text, dnasample_sample_type text, dnasample_sample_parent text, dnasample_ref_sample text) 
    LANGUAGE 'plpgsql'
AS $BODY$

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
$BODY$;




--liquibase formatted sql

--### APPEND FUNCTIONS -- mostly array manipulations###---

--changeset kpalis:append_functions context:general splitStatements:false runOnChange:true

CREATE OR REPLACE FUNCTION appendanalysistodataset(datasetid integer, analysisid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update dataset set analyses=array_append(analyses, analysisId)
     where dataset_id = datasetId;
    END;
$$;

CREATE OR REPLACE FUNCTION appendreadtabletorole(roleid integer, tableid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update role set read_tables=array_append(read_tables, tableId)
     where role_id = roleId;
    END;
$$;

CREATE OR REPLACE FUNCTION appendroletocontact(contactid integer, roleid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update contact set roles=array_append(roles, roleId)
     where contact_id = contactId;
    END;
$$;

CREATE OR REPLACE FUNCTION appendwritetabletorole(roleid integer, tableid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update role set write_tables=array_append(write_tables, tableId)
     where role_id = roleId;
    END;
$$;
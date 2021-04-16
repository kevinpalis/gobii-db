--liquibase formatted sql

--### REMOVE FUNCTIONS ###---
--## These are different from the delete functions in such a way that they only remove "part" of a column value. These columns are all of array type.

--changeset kpalis:remove_functions context:general splitStatements:false runOnChange:true
CREATE OR REPLACE FUNCTION removeanalysisfromdataset(datasetid integer, analysisid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update dataset set analyses=array_remove(analyses, analysisId)
     where dataset_id = datasetId;
    END;
$$;

CREATE OR REPLACE FUNCTION removereadtablefromrole(roleid integer, tableid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update role set read_tables=array_remove(read_tables, tableId)
     where role_id = roleId;
    END;
$$;

CREATE OR REPLACE FUNCTION removerolefromcontact(contactid integer, roleid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update contact set roles=array_remove(roles, roleId)
     where contact_id = contactId;
    END;
$$;

CREATE OR REPLACE FUNCTION removewritetablefromrole(roleid integer, tableid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    update role set write_tables=array_remove(write_tables, tableId)
     where role_id = roleId;
    END;
$$;

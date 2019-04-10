--liquibase formatted sql

--### FlexQuery FUNCTIONS ###---

--changeset kpalis:flexquery_functions context:general splitStatements:false runOnChange:true

--helper function
CREATE OR REPLACE FUNCTION getCvGroupId(_groupname text, _grouptype integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
      select cvgroup_id into id 
      from cvgroup
      where type=_grouptype
      and name=_groupname;
    END;
$$;

CREATE OR REPLACE FUNCTION getAllEntryVertices() RETURNS SETOF vertex
    LANGUAGE plpgsql
    AS $$
  BEGIN
    return query
    select v.* from vertex v where v.is_entry;
  END;
$$;

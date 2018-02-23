--liquibase formatted sql

--### GOBIIDB VERSION FUNCTION ###---
--## This sets the GOBII database version string. The goal is that the version string will always match the compatible version of the GOBII instance

--changeset kpalis:setdatawarehouseversion context:general splitStatements:false runOnChange:true
CREATE OR REPLACE FUNCTION setdatawarehouseversion(ver text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
     DECLARE
        i integer;
        propId integer;
     BEGIN
     select cv_id into propId from cv where term='version' and cvgroup_id=(select cvgroup_id from cvgroup where name='gobii_datawarehouse' and type=1 );
     update gobiiprop set value=ver
      where type_id=propId
      and rank=1;
     GET DIAGNOSTICS i = ROW_COUNT;
     return i;
     END;
 $$;



 --changeset kpalis:update_gobiidb_version_call context:general splitStatements:false runOnChange:true
select * from setdatawarehouseversion('1.3');
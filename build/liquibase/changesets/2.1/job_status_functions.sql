--liquibase formatted sql

--Job Status Functions


--changeset kpalis:create_OK_job context:general splitStatements:false runOnChange:true
DO
$$
  BEGIN
    IF exists (select 1 from job where name='Overriden Job')  THEN
        perform 1 from job where name='Overriden Job';
  ELSE
    perform 1 from createjob('Overriden Job'::text, 'load', 'matrix', 'completed', 'Function setDatasetJobStatusOK was called on this job..'::text, 1);
    END IF;
  END
$$;

--changeset kpalis:job_status_functions context:general splitStatements:false runOnChange:true
DROP FUNCTION IF EXISTS setDatasetJobStatusOK(integer);
CREATE OR REPLACE FUNCTION setDatasetJobStatusOK(datasetId integer) RETURNS integer
    LANGUAGE plpgsql
  AS $$
    DECLARE
        i integer;
  BEGIN
    update dataset 
    set job_id = new_job.job_id
    from (select job_id from job where name='Overriden Job') as new_job
    where dataset_id = datasetId;
    GET DIAGNOSTICS i  = ROW_COUNT;
    return i;
  END;
$$;



--usage:
--select * from setDatasetJobStatusOK(86);
--select * from setDatasetJobStatusOK(71);
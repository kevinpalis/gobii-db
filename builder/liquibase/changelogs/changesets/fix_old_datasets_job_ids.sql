--liquibase formatted sql

--### GP1-1440: Fix for getting pre-1.2 datasets to work well with post 1.2 GOBII. Old datasets without job_ids can be "updated" which effectively corrupts them. ###---

--changeset kpalis:fix_old_datasets-GP1-1440 context:general splitStatements:false

update dataset 
set job_id = old_job.id
from (select id from createjob('Pre-1.2 Job'::text, 'load', 'matrix', 'completed', 'Placeholder job record to give to datasets loaded pre-1.2.'::text, 1)) as old_job
where job_id is null 
and data_file is not null 
and data_file!='';


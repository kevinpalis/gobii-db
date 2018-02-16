--liquibase formatted sql

--### GP1-1440: Fix for getting pre-1.2 datasets to work well with post 1.2 GOBII. Old datasets without job_ids can be "updated" which effectively corrupts them. ###---

--changeset kpalis:fix_old_datasets-GP1-1440 context:general splitStatements:false

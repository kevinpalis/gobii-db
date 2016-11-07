--liquibase formatted sql

--changeset venice.juanillas:alterTableAnalysis context:general splitStatements:false
ALTER TABLE analysis ADD created_by integer;
ALTER TABLE analysis ADD created_date date default('now'::text)::date;
ALTER TABLE analysis ADD modified_by integer;
ALTER TABLE analysis ADD modified_date date default('now'::text)::date;

--changeset venice.juanillas:alterTableLinkageGroup context:general splitStatements:false
ALTER TABLE linkage_group ADD created_by integer;
ALTER TABLE linkage_group ADD created_date date default('now'::text)::date;
ALTER TABLE linkage_group ADD modified_by integer;
ALTER TABLE linkage_group ADD modified_date date default('now'::text)::date;



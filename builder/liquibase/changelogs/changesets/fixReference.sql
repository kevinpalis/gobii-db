--liquibase formatted sql

--changeset venice.juanillas:alterTableReference context:general splitStatements:false
ALTER TABLE reference ADD created_by integer;
ALTER TABLE reference ADD created_date date default('now'::text)::date;
ALTER TABLE reference ADD modified_by integer;
ALTER TABLE reference ADD modified_date date default('now'::text)::date;



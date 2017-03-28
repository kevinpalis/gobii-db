--liquibase formatted sql

/*
* GP1-888: This adds the citext extension and convert certain columns to citext for case-insensitive text comparisons.
*/

--changeset kpalis:converColsToCitext context:general splitStatements:false
--enable the extension first
CREATE EXTENSION IF NOT EXISTS citext;

--drop the offensive view
DROP VIEW IF EXISTS v_all_projects_full_details;
--convert the columns
ALTER TABLE germplasm ALTER COLUMN name TYPE citext;
ALTER TABLE dnasample ALTER COLUMN name TYPE citext;
ALTER TABLE dnarun ALTER COLUMN name TYPE citext;
ALTER TABLE marker ALTER COLUMN name TYPE citext;
ALTER TABLE cv ALTER COLUMN term TYPE citext;
ALTER TABLE platform ALTER COLUMN name TYPE citext;
ALTER TABLE contact ALTER COLUMN firstname TYPE citext;
ALTER TABLE contact ALTER COLUMN lastname TYPE citext;
ALTER TABLE protocol ALTER COLUMN name TYPE citext;
ALTER TABLE vendor_protocol ALTER COLUMN name TYPE citext;
ALTER TABLE project ALTER COLUMN name TYPE citext;
ALTER TABLE experiment ALTER COLUMN name TYPE citext;
ALTER TABLE dataset ALTER COLUMN name TYPE citext;
ALTER TABLE mpaset ALTER COLUMN name TYPE citext;
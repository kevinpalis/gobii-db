--liquibase formatted sql
/*
Issue #: GP1-686
Liquibase changeset: Add props column of jsonb datatype to main entity tables and drop corresponding *_prop tables
*/

--changeset venice.juanillas:fix_dnasample_addprops context:general splitStatements:false
ALTER TABLE dnasample ADD COLUMN props jsonb default '{}';
CREATE INDEX idx_dnasample_props ON dnasample USING gin(props);

--changeset venice.juanillas:fix_dnasampleprop_droptable context:general splitStatements:false
DROP TABLE dnasample_prop CASCADE;

--changeset venice.juanillas:fix_platform_addprops context:general splitStatements:false
ALTER TABLE platform ADD COLUMN props jsonb default '{}';
CREATE INDEX idx_platform_props ON platform USING gin (props);

--changeset venice.juanillas:fix_platform_droptable context:general splitStatements:false
DROP TABLE platform_prop CASCADE;

--changeset venice.juanillas:fix_project_addprops context:general splitStatements:false
ALTER TABLE project ADD COLUMN props jsonb default '{}';
CREATE INDEX idx_project_props ON project USING gin (props);

--changeset venice.juanillas:fix_projectprop_droptable context:general splitStatements:false
DROP TABLE project_prop CASCADE;

--changeset venice.juanillas:fix_germplasm_addprops context:general splitStatements:false
ALTER TABLE germplasm ADD COLUMN props jsonb default '{}';
CREATE INDEX idx_germplasm_props ON germplasm USING gin (props);

--changeset venice.juanillas:fix_germplasmprop_droptable context:general splitStatements:false
DROP TABLE germplasm_prop CASCADE;

--changeset venice.juanillas:fix_mapset_addprops context:general splitStatements:false
ALTER TABLE mapset ADD COLUMN props jsonb default '{}';
CREATE INDEX idx_mapset_props ON mapset USING gin (props);

--changeset venice.juanillas:fix_maprop_droptable context:general splitStatements:false
DROP TABLE map_prop CASCADE;

--changeset venice.juanillas:fix_marker_addprops context:general splitStatements:false
ALTER TABLE marker ADD COLUMN props jsonb default '{}';
CREATE INDEX idx_marker_props ON marker USING gin (props);

--changeset venice.juanillas:fix_markerprop_droptable context:general splitStatements:false
DROP TABLE marker_prop CASCADE;

--changeset venice.juanillas:fix_dnarun_addprops context:general splitStatements:false
ALTER TABLE dnarun ADD COLUMN props jsonb default '{}';
CREATE INDEX idx_dnarun_props ON dnarun USING gin (props);

--changeset venice.juanillas:fix_dnarunprop_droptable context:general splitStatements:false
DROP TABLE dnarun_prop CASCADE;


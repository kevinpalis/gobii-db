--liquibase formatted sql

--to support genetic maps
--changeset kpalis:alter_lg_start_stop context:general splitStatements:false runOnChange:false
--drop view to be able to change the column type
DROP VIEW IF EXISTS v_marker_linkage_physical;
--change the column types
ALTER TABLE linkage_group ALTER COLUMN start type NUMERIC(20,3) using start::numeric;
ALTER TABLE linkage_group ALTER COLUMN stop type NUMERIC(20,3) using stop::numeric;
--put the view back
CREATE OR REPLACE VIEW v_marker_linkage_physical as
	SELECT mlg.marker_id,
	lg.linkage_group_id,
	lg.name AS linkage_group_name,
	lg.start AS linkage_group_start,
	lg.stop AS linkage_group_stop,
	mlg.start,
	mlg.stop,
	ms.name AS mapset_name,
	lg.map_id
	FROM marker_linkage_group mlg,
	linkage_group lg,
	mapset ms
	WHERE mlg.linkage_group_id = lg.linkage_group_id AND lg.map_id = ms.mapset_id;
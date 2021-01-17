--liquibase formatted sql

--changeset rduldulao:init_mapset_stats_tables splitStatements:false runOnChange:false
-- initialize tables


-- reset counts
DELETE FROM mapset_stats;

INSERT INTO mapset_stats(mapset_id)
SELECT mapset_id FROM mapset;

-- init marker count
-- get count from linkage_group

WITH marker_count_as AS (
    SELECT linkage_group.map_id AS mapset_id, count(1) AS marker_count
    FROM linkage_group, marker_linkage_group
    WHERE marker_linkage_group.linkage_group_id = linkage_group.linkage_group_id
    GROUP BY linkage_group.map_id
)
UPDATE mapset_stats
SET marker_count = c.marker_count
FROM marker_count_as c
WHERE mapset_stats.mapset_id = c.mapset_id;

-- init linkage_group_count
WITH linkage_group_count_as AS (
    SELECT map_id, count(1) AS linkage_group_count
    FROM linkage_group
    GROUP BY map_id
)
UPDATE mapset_stats
SET linkage_group_count = c.linkage_group_count
FROM linkage_group_count_as c
WHERE mapset_stats.mapset_id = c.map_id;



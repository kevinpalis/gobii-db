--liquibase formatted sql

--changeset rduldulao:init_plat_stats_tables splitStatements:false runOnChange:false
-- initialize tables


-- reset counts

DELETE FROM platform_stats;

INSERT INTO platform_stats(platform_id) 
SELECT platform_id FROM platform;

-- initial protocol_count;

WITH protocol_count_as AS (
    SELECT platform_id, count(1) AS protocol_count
    FROM protocol 
    GROUP BY platform_id
    ORDER BY platform_id
)
UPDATE platform_stats
SET protocol_count  = c.protocol_count
FROM protocol_count_as c
WHERE platform_stats.platform_id = c.platform_id;

-- initial vendor_protocol_count
WITH vendor_protocol_count_as AS (
    SELECT platform.platform_id, count(1) AS vendor_protocol_count
    FROM platform , protocol p, vendor_protocol vp
    WHERE platform.platform_id = p.platform_id AND p.protocol_id = vp.protocol_id
    GROUP BY platform.platform_id
)
UPDATE platform_stats
SET vendor_protocol_count = c.vendor_protocol_count
FROM vendor_protocol_count_as c
WHERE platform_stats.platform_id = c.platform_id;

-- initial experiment_count

WITH experiment_count_as  AS (
    SELECT platform.platform_id, count(1) AS experiment_count
    FROM experiment, vendor_protocol, protocol, platform
    WHERE experiment.vendor_protocol_id = vendor_protocol.vendor_protocol_id
    AND vendor_protocol.protocol_id = protocol.protocol_id
    AND protocol.platform_id = platform.platform_id
    GROUP BY platform.platform_id
)
UPDATE platform_stats
SET experiment_count = c.experiment_count
FROM experiment_count_as c
WHERE platform_stats.platform_id = c.platform_id;

-- initial marker_count

WITH marker_count_as AS (
   SELECT platform_id, count(1) AS marker_count
   FROM marker
   GROUP BY platform_id
)
UPDATE platform_stats
SET marker_count = c.marker_count
FROM marker_count_as c
WHERE platform_stats.platform_id = c.platform_id;
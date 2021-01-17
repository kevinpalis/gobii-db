--liquibase formatted sql

--changeset rduldulao:mapset_stats_tables splitStatements:false runOnChange:false
-- initialize tables

DROP TABLE IF EXISTS mapset_stats;
CREATE TABLE mapset_stats(
    mapset_id INTEGER PRIMARY KEY REFERENCES mapset(mapset_id) ON DELETE CASCADE,
    marker_count BIGINT DEFAULT 0,
    linkage_group_count BIGINT DEFAULT 0
);
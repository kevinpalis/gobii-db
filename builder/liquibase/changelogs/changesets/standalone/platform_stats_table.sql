--liquibase formatted sql

--changeset rduldulao:plat_stats_tables splitStatements:false runOnChange:false
-- initialize tables

DROP TABLE IF EXISTS platform_stats;
CREATE TABLE platform_stats(
    platform_id INTEGER PRIMARY KEY REFERENCES platform(platform_id) ON DELETE CASCADE,
    protocol_count BIGINT DEFAULT 0,
    vendor_protocol_count BIGINT DEFAULT 0,
    experiment_count BIGINT DEFAULT 0,
    marker_count BIGINT DEFAULT 0
);



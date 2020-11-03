--liquibase formatted sql

--changeset rduldulao:create_stats_tables splitStatements:false runOnChange:false

-- create tables for counting

DROP TABLE IF EXISTS dataset_stats;

CREATE TABLE  dataset_stats(
    dataset_id INTEGER PRIMARY KEY REFERENCES dataset(dataset_id),
    marker_count BIGINT DEFAULT 0,
    dnarun_count BIGINT DEFAULT 0
);


DROP TABLE IF EXISTS experiment_stats;
CREATE TABLE IF NOT EXISTS experiment_stats(
    experiment_id INTEGER PRIMARY KEY REFERENCES experiment(experiment_id),
    dataset_count BIGINT DEFAULT 0,
    marker_count BIGINT DEFAULT 0,
    dnarun_count BIGINT DEFAULT 0
);


DROP TABLE IF EXISTS project_stats;
CREATE TABLE project_stats(
    project_id INTEGER PRIMARY KEY REFERENCES project(project_id),
    experiment_count BIGINT DEFAULT 0,
    dataset_count BIGINT DEFAULT 0,
    marker_count BIGINT DEFAULT 0,
    dnarun_count BIGINT DEFAULT 0,
    dnasample_count BIGINT DEFAULT 0
);



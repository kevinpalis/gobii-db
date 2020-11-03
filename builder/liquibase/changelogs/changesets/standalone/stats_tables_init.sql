--liquibase formatted sql

--changeset rduldulao:init_stats_tables splitStatements:false runOnChange:false
-- initialize tables

INSERT INTO dataset_stats(dataset_id)
SELECT dataset_id FROM dataset;


INSERT INTO experiment_stats(experiment_id)
SELECT experiment_id FROM experiment;


INSERT INTO project_stats(project_id)
SELECT project_id FROM project;


-- initialize project stats

WITH experiment_count_as AS (
    SELECT project_id, COUNT(1) AS experiment_count
    FROM experiment
    GROUP BY project_id
)
UPDATE project_stats
SET "experiment_count" = c.experiment_count
FROM experiment_count_as c
WHERE c.project_id = project_stats.project_id;


WITH dataset_count_as AS (
    SELECT a.project_id, COUNT(b.*) AS dataset_count
    FROM experiment a, dataset b
    WHERE a.experiment_id = b.experiment_id 
    GROUP BY a.project_id
)
UPDATE project_stats
SET "dataset_count" = c.dataset_count
FROM dataset_count_as c
WHERE c.project_id = project_stats.project_id;


-- initialize experiment stats
WITH dataset_count_as AS (
    SELECT experiment_id, count(1) AS dataset_count
    FROM dataset
    GROUP BY experiment_id
)

UPDATE experiment_stats
SET "dataset_count" = c.dataset_count
FROM dataset_count_as c
WHERE c.experiment_id = experiment_stats.experiment_id;


-- initialize marker/dnarun count stats in dataset_stats
WITH marker_count_as AS (
    WITH ids_table AS (
        SELECT k.dataset_ids
        FROM marker
        LEFT  JOIN LATERAL (SELECT ARRAY(SELECT * FROM jsonb_object_keys(marker.dataset_marker_idx)) AS dataset_ids)  k on true
    )
    SELECT a.dataset_id, count(1) as marker_count FROM  dataset a, ids_table b WHERE CAST (a.dataset_id AS TEXT) = ANY(b.dataset_ids)
    GROUP BY a.dataset_id
)

UPDATE dataset_stats
SET "marker_count" = c.marker_count
FROM marker_count_as c
WHERE c.dataset_id = dataset_stats.dataset_id;
WITH dnarun_count_as AS (
    WITH ids_table AS (
        SELECT k.dataset_ids
        FROM dnarun
        LEFT  JOIN LATERAL (SELECT ARRAY(SELECT * FROM jsonb_object_keys(dnarun.dataset_dnarun_idx)) AS dataset_ids)  k on true
    )
    SELECT a.dataset_id, count(1) as dnarun_count FROM  dataset a, ids_table b WHERE CAST (a.dataset_id AS TEXT) = ANY(b.dataset_ids)
    GROUP BY a.dataset_id
)
UPDATE dataset_stats
SET "dnarun_count" = c.dnarun_count
FROM dnarun_count_as c
WHERE c.dataset_id = dataset_stats.dataset_id;


--initialize marker/dnarun count stats in experiment_stats


WITH marker_count_as AS (
    SELECT a.experiment_id, SUM(b.marker_count) as marker_count
    FROM dataset a, dataset_stats b 
    WHERE a.dataset_id = b.dataset_id
    GROUP BY a.experiment_id
)

UPDATE experiment_stats
SET "marker_count" = c.marker_count
FROM marker_count_as c 
WHERE c.experiment_id = experiment_stats.experiment_id;
WITH dnarun_count_as AS (
    SELECT a.experiment_id, SUM(b.dnarun_count) as dnarun_count
    FROM dataset a, dataset_stats b 
    WHERE a.dataset_id = b.dataset_id
    GROUP BY a.experiment_id
)
UPDATE experiment_stats
SET "dnarun_count" = c.dnarun_count
FROM dnarun_count_as c 
WHERE c.experiment_id = experiment_stats.experiment_id;


-- initialize run marker/dnarun count  stats in project_stats


WITH marker_count_as AS (
    SELECT a.project_id, SUM(b.marker_count) as marker_count
    FROM experiment a, experiment_stats b 
    WHERE a.experiment_id = b.experiment_id
    GROUP BY a.project_id
)

UPDATE project_stats
SET "marker_count" = c.marker_count
FROM marker_count_as c 
WHERE c.project_id = project_stats.project_id;
WITH dnarun_count_as AS (
    SELECT a.project_id, SUM(b.dnarun_count) as dnarun_count
    FROM experiment a, experiment_stats b 
    WHERE a.experiment_id = b.experiment_id
    GROUP BY a.project_id
)

UPDATE project_stats
SET "dnarun_count" = c.dnarun_count
FROM dnarun_count_as c 
WHERE c.project_id = project_stats.project_id;


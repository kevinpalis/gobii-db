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
    dnarun_count BIGINT DEFAULT 0
);

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



-- create trigger functions for dataset table
CREATE OR REPLACE FUNCTION dataset_increment()
    RETURNS TRIGGER 
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE experiment_stats
    SET dataset_count = dataset_count + 1
    WHERE experiment_id = NEW.experiment_id;

    IF NOT FOUND THEN
        INSERT INTO experiment_stats(experiment_id, dataset_count)
        VALUES (NEW.experiment_id, 1);
    END IF;

    UPDATE project_stats
    SET dataset_count = dataset_count + 1 
    FROM experiment
    WHERE experiment.experiment_id = NEW.experiment_id
    AND project_stats.project_id = experiment.project_id;

    IF NOT FOUND THEN
        INSERT INTO project_stats(project_id, dataset_count)
        SELECT experiment.project_id, 1 FROM experiment WHERE experiment.experiment_id = NEW.experiment_id;
    END IF;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION dataset_decrement() 
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE experiment_stats SET dataset_count = dataset_count - 1 WHERE experiment_id = OLD.experiment_id;
    
    UPDATE project_stats
    SET dataset_count = dataset_count - 1
    FROM experiment
    WHERE project_stats.project_id = experiment.project_id
    AND experiment.experiment_id = OLD.experiment_id;
    
    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS dataset_count_inc_trig ON dataset;
DROP TRIGGER IF EXISTS dataset_count_dec_trig ON dataset;
CREATE TRIGGER dataset_count_inc_trig AFTER INSERT ON dataset FOR EACH ROW EXECUTE PROCEDURE dataset_increment();
CREATE TRIGGER dataset_count_dec_trig AFTER DELETE ON dataset FOR EACH ROW EXECUTE PROCEDURE dataset_decrement();


-- create trigger functions for experiment
CREATE OR REPLACE FUNCTION experiment_increment()
    RETURNS TRIGGER 
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE project_stats
    SET experiment_count = experiment_count + 1
    WHERE project_id = NEW.project_id;

    IF NOT FOUND THEN
        INSERT INTO project_stats(project_id, experiment_count)
        VALUES (NEW.project_id, 1);
    END IF;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION experiment_decrement() 
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE project_stats
    SET experiment_count = experiment_count - 1
    WHERE project_id = OLD.project_id;
    
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS experiment_count_inc_trig ON experiment;
DROP TRIGGER IF EXISTS experiment_count_dec_trig ON experiment;
CREATE TRIGGER experiment_count_inc_trig AFTER INSERT ON experiment FOR EACH ROW EXECUTE PROCEDURE experiment_increment();
CREATE TRIGGER experiment_count_dec_trig AFTER DELETE ON experiment FOR EACH ROW EXECUTE PROCEDURE experiment_decrement();


-- create functions for dataset
CREATE OR REPLACE FUNCTION marker_increment()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
DECLARE 
    d_id varchar;
BEGIN
    -- get the dataset ids of the marker
    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(NEW.dataset_marker_idx)) LOOP
        UPDATE dataset_stats SET marker_count = marker_count + 1
        WHERE dataset_id = d_id::INTEGER;

        IF NOT FOUND THEN
            INSERT INTO dataset_stats(dataset_id, marker_count)
            VALUES(d_id, 1);
        END IF;

        -- update experiment_stats
        UPDATE experiment_stats SET marker_count = marker_count + 1
        FROM dataset
        WHERE experiment_stats.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

        IF NOT FOUND THEN
            INSERT INTO experiment_stats(experiment_id, marker_count)
            SELECT experiment_id, 1 FROM dataset WHERE dataset_id = d_id;
        END IF;

        -- update project stats
        UPDATE project_stats SET marker_count = marker_count + 1
        FROM experiment, dataset
        WHERE project_stats.project_id = experiment.project_id
        AND experiment.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

        IF NOT FOUND THEN
            INSERT INTO project_stats(project_id, marker_count)
            SELECT project.project_id, 1 FROM project, experiment, dataset 
            WHERE project.project_id = experiment.project_id
            AND experiment.experiment_id = dataset.experiment_id
            AND dataset.dataset_id = d_id::INTEGER;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION marker_decrement()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
DECLARE
    d_id varchar;
BEGIN
    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(OLD.dataset_marker_idx)) LOOP
        UPDATE dataset_stats SET marker_count = marker_count - 1
        WHERE dataset_id = d_id::INTEGER;

        -- update experiment_stats
        UPDATE experiment_stats SET marker_count = marker_count - 1
        FROM dataset
        WHERE experiment_stats.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

         -- update project stats
        UPDATE project_stats SET marker_count = marker_count - 1
        FROM experiment, dataset
        WHERE project_stats.project_id = experiment.project_id
        AND experiment.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

    END LOOP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS marker_count_inc_trig ON marker;
DROP TRIGGER IF EXISTS marker_count_dec_trig ON marker;
CREATE TRIGGER marker_count_inc_trig AFTER INSERT ON marker FOR EACH ROW EXECUTE PROCEDURE marker_increment();
CREATE TRIGGER marker_count_dec_trig AFTER DELETE ON marker FOR EACH ROW EXECUTE PROCEDURE marker_decrement();

CREATE OR REPLACE FUNCTION dnarun_increment()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
DECLARE 
    d_id varchar;
BEGIN
    -- get the dataset ids of the marker
    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(NEW.dataset_dnarun_idx)) LOOP
        UPDATE dataset_stats SET dnarun_count = dnarun_count + 1
        WHERE dataset_id = d_id::INTEGER;

        IF NOT FOUND THEN
            INSERT INTO dataset_stats(dataset_id, dnarun_count)
            VALUES(d_id, 1);
        END IF;

        -- update experiment_stats
        UPDATE experiment_stats SET dnarun_count = dnarun_count + 1
        FROM dataset
        WHERE experiment_stats.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

        IF NOT FOUND THEN
            INSERT INTO experiment_stats(experiment_id, dnarun_count)
            SELECT experiment_id, 1 FROM dataset WHERE dataset_id = d_id;
        END IF;

        -- update project stats
        UPDATE project_stats SET dnarun_count = dnarun_count + 1
        FROM experiment, dataset
        WHERE project_stats.project_id = experiment.project_id
        AND experiment.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

        IF NOT FOUND THEN
            INSERT INTO project_stats(project_id, dnarun_count)
            SELECT project.project_id, 1 FROM project, experiment, dataset 
            WHERE project.project_id = experiment.project_id
            AND experiment.experiment_id = dataset.experiment_id
            AND dataset.dataset_id = d_id::INTEGER;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION dnarun_decrement()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
DECLARE
    d_id varchar;
BEGIN
    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(OLD.dataset_dnarun_idx)) LOOP
        UPDATE dataset_stats SET dnarun_count = dnarun_count - 1
        WHERE dataset_id = d_id::INTEGER;

        -- update experiment_stats
        UPDATE experiment_stats SET dnarun_count = dnarun_count - 1
        FROM dataset
        WHERE experiment_stats.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

         -- update project stats
        UPDATE project_stats SET dnarun_count = dnarun_count - 1
        FROM experiment, dataset
        WHERE project_stats.project_id = experiment.project_id
        AND experiment.experiment_id = dataset.experiment_id
        AND dataset.dataset_id = d_id::INTEGER;

    END LOOP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS dnarun_count_inc_trig ON dnarun;
DROP TRIGGER IF EXISTS dnarun_count_dec_trig ON dnarun;
CREATE TRIGGER dnarun_count_inc_trig AFTER INSERT ON dnarun FOR EACH ROW EXECUTE PROCEDURE dnarun_increment();
CREATE TRIGGER dnarun_count_dec_trig AFTER DELETE ON dnarun FOR EACH ROW EXECUTE PROCEDURE dnarun_decrement();

--liquibase formatted sql

--changeset rduldulao:stats_tables_triggers splitStatements:false runOnChange:false

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
DECLARE
    p_id int;
BEGIN
    UPDATE experiment_stats SET dataset_count = dataset_count - 1 WHERE experiment_id = OLD.experiment_id; 

    UPDATE project_stats
    SET dataset_count = dataset_count - 1
    FROM experiment
    WHERE project_stats.project_id = experiment.project_id
    AND experiment.experiment_id = OLD.experiment_id;
    
    -- also update the stats
    PERFORM upsert_experiment_stats(OLD.experiment_id, 'dnarun_count');
    PERFORM upsert_experiment_stats(OLD.experiment_id, 'marker_count');

    SELECT experiment.project_id INTO p_id FROM  experiment WHERE experiment.experiment_id = OLD.experiment_id;

    PERFORM upsert_project_stats(p_id, 'dnarun_count');
    PERFORM upsert_project_stats(p_id, 'marker_count');
 
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

    PERFORM upsert_project_stats(OLD.project_id, 'dnarun_count');
    PERFORM upsert_project_stats(OLD.project_id, 'marker_count');
    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS experiment_count_inc_trig ON experiment;
DROP TRIGGER IF EXISTS experiment_count_dec_trig ON experiment;
CREATE TRIGGER experiment_count_inc_trig AFTER INSERT ON experiment FOR EACH ROW EXECUTE PROCEDURE experiment_increment();
CREATE TRIGGER experiment_count_dec_trig AFTER DELETE ON experiment FOR EACH ROW EXECUTE PROCEDURE experiment_decrement();


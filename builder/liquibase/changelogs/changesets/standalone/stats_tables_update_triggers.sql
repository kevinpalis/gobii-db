--liquibase formatted sql

--changeset rduldulao:create_stats_tables_update_triggers splitStatements:false runOnChange:false

-- create update triggers for marker update

CREATE OR REPLACE FUNCTION marker_update()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
DECLARE
    d_id varchar;
BEGIN
    -- check if nothing changed
    IF NEW.dataset_marker_idx::text = OLD.dataset_marker_idx::text THEN
        RETURN NEW;
    END IF;

    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(OLD.dataset_marker_idx)) LOOP
        PERFORM update_marker_stats(d_id::integer, -1);
    END LOOP;

    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(NEW.dataset_marker_idx)) LOOP
        PERFORM update_marker_stats(d_id::integer, 1);
    END LOOP;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION dnarun_update()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
DECLARE
    d_id varchar;
BEGIN
    -- check if nothing changed
    IF NEW.dataset_dnarun_idx::text = OLD.dataset_dnarun_idx::text THEN
        RETURN NEW;
    END IF;

    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(OLD.dataset_dnarun_idx)) LOOP
        PERFORM update_dnarun_stats(d_id::integer, -1);
    END LOOP;

    FOREACH d_id IN ARRAY ARRAY(SELECT JSONB_OBJECT_KEYS(NEW.dataset_dnarun_idx)) LOOP
        PERFORM update_dnarun_stats(d_id::integer, 1);
    END LOOP;
    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS marker_count_update_trig ON marker;
CREATE TRIGGER marker_count_update_trig AFTER UPDATE ON marker FOR EACH ROW EXECUTE PROCEDURE marker_update();

DROP TRIGGER IF EXISTS dnarun_count_update_trig ON dnarun;
CREATE TRIGGER dnarun_count_update_trig AFTER UPDATE ON dnarun FOR EACH ROW EXECUTE PROCEDURE dnarun_update();

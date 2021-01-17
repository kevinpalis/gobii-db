--liquibase formatted sql

--changeset rduldulao:mapset_stats_triggers splitStatements:false runOnChange:false

-- create counting functions

CREATE OR REPLACE FUNCTION linkage_group_increment()
    RETURNS TRIGGER 
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE mapset_stats
    SET linkage_group_count = linkage_group_count + 1
    WHERE mapset_id = NEW.map_id;

    IF NOT FOUND THEN
        INSERT INTO mapset_stats(mapset_id, linkage_group_count)
        VALUES (NEW.map_id, 1);
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS linkage_group_count_inc_trig ON linkage_group;
CREATE TRIGGER linkage_group_count_inc_trig AFTER INSERT ON linkage_group FOR EACH ROW EXECUTE PROCEDURE linkage_group_increment();

CREATE OR REPLACE FUNCTION linkage_group_decrement()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE mapset_stats
    SET linkage_group_count = linkage_group_count - 1
    WHERE mapset_id = OLD.map_id;

    PERFORM upsertMapsetStatsMarkerCount(OLD.map_id);
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS linkage_group_count_dec_trig ON linkage_group;
CREATE TRIGGER linkage_group_count_dec_trig AFTER DELETE ON linkage_group FOR EACH ROW EXECUTE PROCEDURE linkage_group_decrement();


CREATE OR REPLACE FUNCTION linkage_group_mapid_update()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.map_id = NEW.map_id THEN
        RETURN NEW;
    END IF;

    PERFORM upsertMapsetStatsMarkerCount(OLD.map_id);
    PERFORM upsertMapsetStatsMarkerCount(NEW.map_id);
    RETURN NEW;

END;
$$;

DROP TRIGGER IF EXISTS linkage_group_update_trig ON linkage_group;
CREATE TRIGGER linkage_group_update_trig AFTER UPDATE ON linkage_group FOR EACH ROW EXECUTE PROCEDURE linkage_group_mapid_update();
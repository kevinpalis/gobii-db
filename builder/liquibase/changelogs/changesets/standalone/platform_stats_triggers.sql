--liquibase formatted sql

--changeset rduldulao:platform_stats_triggers splitStatements:false runOnChange:false

-- create counting functions

CREATE OR REPLACE FUNCTION count_platform_protocols(plat_id integer)
    RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE cnt integer;
BEGIN
    SELECT COUNT(1) INTO cnt FROM protocol WHERE platform_id = plat_id GROUP BY platform_id;
    IF cnt IS NULL THEN cnt := 0;
    END IF;

    RETURN cnt;
END;
$$;

CREATE OR REPLACE FUNCTION count_platform_vendor_protocols(plat_id integer)
    RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE cnt integer;
BEGIN
    SELECT COUNT(1) INTO cnt FROM vendor_protocol, protocol 
    WHERE vendor_protocol.protocol_id = protocol.protocol_id
    AND protocol.platform_id = plat_id
    GROUP BY protocol.platform_id;
    
    IF cnt IS NULL THEN cnt := 0;
    END IF;

    RETURN cnt;
END;
$$;

CREATE OR REPLACE FUNCTION count_platform_experiments(plat_id integer)
    RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE cnt integer;
BEGIN
    SELECT COUNT(1) INTO cnt 
    FROM experiment, vendor_protocol, protocol
    WHERE experiment.vendor_protocol_id = vendor_protocol.vendor_protocol_id
    AND vendor_protocol.protocol_id = protocol.protocol_id
    AND protocol.platform_id = plat_id
    GROUP BY protocol.platform_id;

    IF cnt IS NULL THEN cnt := 0;
    END IF;

    RETURN cnt;
END;
$$;

-- create trigger functions for  protocol table

CREATE OR REPLACE FUNCTION protocol_increment()
    RETURNS TRIGGER 
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE platform_stats
    SET protocol_count = protocol_count + 1
    WHERE platform_id = NEW.platform_id;

    IF NOT FOUND THEN
        IF NEW.platform_id IS NULL THEN
            -- do nothing
        ELSE
            INSERT INTO platform_stats(platform_id, protocol_count)
            VALUES (NEW.platform_id, 1);
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS protocol_count_inc_trig ON protocol;
CREATE TRIGGER protocol_count_inc_trig AFTER INSERT ON protocol FOR EACH ROW EXECUTE PROCEDURE protocol_increment();


CREATE OR REPLACE FUNCTION protocol_decrement()
    RETURNS TRIGGER 
    LANGUAGE plpgsql
    AS $$
    DECLARE p_cnt integer;
            vp_cnt integer;
BEGIN
    IF OLD.platform_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT count_platform_protocols(NEW.platform_id) INTO p_cnt;
    SELECT count_platform_vendor_protocols(NEW.platform_id) INTO vp_cnt;

    UPDATE platform_stats
    SET protocol_count = p_cnt, vendor_protocol_count = vp_cnt
    WHERE platform_id = OLD.platform_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protocol_count_dec_trig ON protocol;
CREATE TRIGGER protocol_count_dec_trig AFTER DELETE ON protocol FOR EACH ROW EXECUTE PROCEDURE protocol_decrement();

CREATE OR REPLACE FUNCTION protocol_update()
    RETURNS TRIGGER 
    LANGUAGE plpgsql
    AS $$
    DECLARE p_cnt integer;
            vp_cnt integer;
BEGIN
    IF OLD.platform_id = NEW.platform_id THEN
        RETURN NEW;
    END IF;

    IF OLD.platform_id IS NULL THEN
        -- do nothing
    ELSE
        UPDATE platform_stats
        SET protocol_count = count_platform_protocols(OLD.platform_id),
            vendor_protocol_count = count_platform_vendor_protocols(OLD.platform_id)
        WHERE platform_id = OLD.platform_id;
    END IF;

    IF NEW.platform_id IS  NULL THEN
        -- do nothing
    ELSE
        SELECT count_platform_protocols(NEW.platform_id) INTO p_cnt;
        SELECT count_platform_vendor_protocols(NEW.platform_id) INTO vp_cnt;

        UPDATE platform_stats
        SET protocol_count = p_cnt, vendor_protocol_count = vp_cnt
        WHERE platform_id = NEW.platform_id;

        IF NOT FOUND THEN
            INSERT INTO platform_stats(platform_id, protocol_count, vendor_protocol_count) 
            VALUES (NEW.platform_id, p_cnt, vp_cnt);
        END IF;
    END IF;
   
    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS protocol_count_update_trig ON protocol;
CREATE TRIGGER protocol_count_update_trig AFTER UPDATE ON protocol FOR EACH ROW EXECUTE PROCEDURE protocol_update();

-- triggers for vendor_protocol

CREATE OR REPLACE FUNCTION vendor_protocol_increment()
    RETURNS TRIGGER 
    LANGUAGE plpgsql
    AS $$
    DECLARE vp_cnt integer;
            plat_id integer;
BEGIN
    SELECT protocol.platform_id INTO plat_id FROM protocol, vendor_protocol
    WHERE vendor_protocol.vendor_protocol_id = NEW.vendor_protocol_id
    AND vendor_protocol.protocol_id = protocol.protocol_id;

    SELECT count_platform_vendor_protocols(plat_id) INTO vp_cnt;

    UPDATE platform_stats
    SET vendor_protocol_count = vp_cnt
    WHERE platform_id = plat_id;

    IF NOT FOUND  THEN
        INSERT INTO platform_stats(platform_id, vendor_protocol_count)
        VALUES (plat_id, vp_cnt);
    END IF;

    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS vendor_protocol_count_inc_trig ON vendor_protocol;
CREATE TRIGGER vendor_protocol_count_inc_trig AFTER INSERT ON vendor_protocol FOR EACH ROW EXECUTE PROCEDURE vendor_protocol_increment();

CREATE OR REPLACE FUNCTION vendor_protocol_decrement()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE vp_cnt integer;
            plat_id integer;
BEGIN
    SELECT protocol.platform_id INTO plat_id FROM protocol, vendor_protocol
    WHERE vendor_protocol.vendor_protocol_id = OLD.vendor_protocol_id
    AND vendor_protocol.protocol_id = protocol.protocol_id;

    UPDATE platform_stats
    SET vendor_protocol_count = vendor_protocol_count - 1
    WHERE platform_id = plat_id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS vendor_protocol_count_dec_trig ON vendor_protocol;
CREATE TRIGGER vendor_protocol_count_dec_trig AFTER DELETE ON vendor_protocol FOR EACH ROW EXECUTE PROCEDURE vendor_protocol_decrement();


CREATE OR REPLACE FUNCTION vendor_protocol_update()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE old_plat integer;
            new_plat integer;
            p_cnt integer;
            vp_cnt integer;
BEGIN
    SELECT protocol.platform_id INTO old_plat FROM protocol, vendor_protocol
    WHERE vendor_protocol.vendor_protocol_id = OLD.vendor_protocol_id
    AND vendor_protocol.protocol_id = protocol.protocol_id;

    SELECT protocol.platform_id INTO new_plat FROM protocol, vendor_protocol
    WHERE vendor_protocol.vendor_protocol_id = NEW.vendor_protocol_id
    AND vendor_protocol.protocol_id = protocol.protocol_id;

    IF old_plat = new_plat THEN
        RETURN NEW;
    END IF;

    IF old_plat IS NULL THEN
        -- do nothing
    ELSE
        -- decrement old plat
        SELECT count_platform_protocols(old_plat) INTO p_cnt;
        SELECT count_platform_vendor_protocols(old_plat) INTO vp_cnt;
        UPDATE platform_stats SET protocol_count = p_cnt, vendor_protocol_count = vp_cnt WHERE platform_id = old_plat;
        IF NOT FOUND THEN
            INSERT INTO platform_stats(platform_id, protocol_count, vendor_protocol_count) VALUES (old_plat, p_cnt, vp_cnt);
        END IF;
    END IF;

    IF new_plat IS NULL THEN
        -- do nothing
    ELSE
        -- increment new plat
        SELECT count_platform_protocols(new_plat) INTO p_cnt;
        SELECT count_platform_vendor_protocols(new_plat) INTO vp_cnt;
        UPDATE platform_stats SET protocol_count = p_cnt, vendor_protocol_count = vp_cnt WHERE platform_id = new_plat;
        IF NOT FOUND THEN
            INSERT INTO platform_stats(platform_id, protocol_count, vendor_protocol_count) VALUES (new_plat, p_cnt, vp_cnt);
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS vendor_protocol_update_trig ON vendor_protocol;
CREATE TRIGGER vendor_protocol_update_trig AFTER UPDATE ON vendor_protocol FOR EACH ROW EXECUTE PROCEDURE vendor_protocol_update();
-- experiment triggers

CREATE OR REPLACE FUNCTION experiment_platform_increment()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE plat_id integer;
BEGIN
    SELECT protocol.platform_id INTO plat_id FROM protocol, vendor_protocol
    WHERE vendor_protocol.vendor_protocol_id = NEW.vendor_protocol_id
    AND protocol.protocol_id = vendor_protocol.protocol_id;

    IF plat_id IS NULL THEN
        RETURN NEW;
    END IF;

    UPDATE platform_stats
    SET experiment_count = experiment_count + 1
    WHERE platform_id = plat_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS experiment_platform_inc_trig ON experiment;
CREATE TRIGGER experiment_platform_inc_trig AFTER INSERT ON experiment FOR EACH ROW EXECUTE PROCEDURE experiment_platform_increment();

CREATE OR REPLACE FUNCTION experiment_platform_decrement()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE plat_id integer;
BEGIN
    SELECT protocol.platform_id INTO plat_id FROM protocol, vendor_protocol
    WHERE vendor_protocol.vendor_protocol_id = OLD.vendor_protocol_id
    AND protocol.protocol_id = vendor_protocol.protocol_id;

    IF plat_id IS NULL THEN
        RETURN NEW;
    END IF;

    UPDATE platform_stats
    SET experiment_count = experiment_count - 1
    WHERE platform_id = plat_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS experiment_platform_dec_trig ON experiment;
CREATE TRIGGER experiment_platform_dec_trig AFTER DELETE ON experiment FOR EACH ROW EXECUTE PROCEDURE experiment_platform_decrement();

CREATE OR REPLACE FUNCTION experiment_platform_update()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE plat_id integer;
BEGIN
    IF OLD.vendor_protocol_id = NEW.vendor_protocol_id THEN 
        RETURN NEW;
    END IF;

    IF OLD.vendor_protocol_id IS NULL THEN
        -- do nothing
    ELSE
        SELECT protocol.platform_id INTO plat_id FROM protocol, vendor_protocol
        WHERE vendor_protocol.vendor_protocol_id = OLD.vendor_protocol_id
        AND protocol.protocol_id = vendor_protocol.protocol_id;

        UPDATE platform_stats
        SET experiment_count = experiment - 1
        WHERE platform_id = plat_id;
    END IF;

    IF NEW.vendor_protocol_id IS NULL THEN
        -- do nothing
    ELSE
        SELECT protocol.platform_id INTO plat_id FROM protocol, vendor_protocol
        WHERE vendor_protocol.vendor_protocol_id = NEW.vendor_protocol_id
        AND protocol.protocol_id = vendor_protocol.protocol_id;

        UPDATE platform_stats
        SET experiment_count = experiment + 1
        WHERE platform_id = plat_id;

    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS experiment_platform_update_trig ON experiment;
CREATE TRIGGER experiment_platform_update_trig AFTER UPDATE ON experiment FOR EACH ROW EXECUTE PROCEDURE experiment_platform_update();
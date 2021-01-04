--liquibase formatted sql

--changeset rduldulao:platform_stats_table_procs splitStatements:false runOnChange:false

CREATE OR REPLACE FUNCTION upsert_platform_marker_stats(foreignTable TEXT) 
    RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE rec record;
            rcount integer;
BEGIN

    FOR rec IN execute format('SELECT platform_id, count(1) as marker_count FROM %I GROUP BY platform_id', foreignTable)
    LOOP
        EXECUTE format('UPDATE platform_stats SET marker_count = marker_count + $1 WHERE platform_id = $2') USING rec.marker_count::integer, rec.platform_id::integer;
        GET DIAGNOSTICS rcount = ROW_COUNT;
        IF rcount = 0 THEN
            INSERT INTO platform_stats(platform_id, marker_count) VALUES (rec.platform_id, rec.marker_count);
        END IF;
    END LOOP;

END;
$$;
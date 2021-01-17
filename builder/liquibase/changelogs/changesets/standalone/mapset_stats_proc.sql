--liquibase formatted sql

--changeset rduldulao:mapset_stats_table_procs splitStatements:false runOnChange:false

CREATE OR REPLACE FUNCTION upsertMapsetTableStats(foreignTable TEXT) 
    RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE rec record;
            rcount integer;
BEGIN

    FOR rec IN EXECUTE format('SELECT linkage_group.map_id AS mapset_id, count(1) as marker_count FROM %I, linkage_group WHERE %I.linkage_group_id::integer = linkage_group.linkage_group_id GROUP BY linkage_group.map_id', foreignTable, foreignTable)
    LOOP
        EXECUTE format('UPDATE mapset_stats SET marker_count = marker_count + $1 WHERE mapset_id = $2') USING rec.marker_count::integer, rec.mapset_id::integer;
        GET DIAGNOSTICS rcount = ROW_COUNT;
        IF rcount = 0 THEN
            INSERT INTO mapset_stats(mapset_id, marker_count) VALUES (rec.mapset_id, rec.marker_count);
        END IF;
    END LOOP;

END;
$$;

CREATE OR REPLACE FUNCTION upsertMapsetStatsMarkerCount(ms_id integer)
    RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE mcount integer;
BEGIN

    SELECT  count(1) INTO mcount
    FROM linkage_group, marker_linkage_group
    WHERE linkage_group.map_id = ms_id
    AND marker_linkage_group.linkage_group_id = linkage_group.linkage_group_id
    GROUP BY linkage_group.map_id;

    UPDATE mapset_stats
    SET marker_count = mcount
    WHERE mapset_id = ms_id;

    IF NOT FOUND THEN
        INSERT INTO mapset_stats(mapset_id, marker_count) VALUES (ms_id, mcount);
    END IF;
END;
$$;
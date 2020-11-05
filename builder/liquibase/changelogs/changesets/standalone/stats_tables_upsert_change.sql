--liquibase formatted sql

--changeset rduldulao:stats_tables_upsert_change splitStatements:false runOnChange:false

DROP FUNCTION IF EXISTS upsertKVPFromForeignTable(foreignTable text, sourceKeyCol text, sourceValueCol text, targetTable text, targetIdCol text, targetJsonbCol text);
CREATE OR REPLACE FUNCTION upsertKVPFromForeignTable(foreignTable text, sourceKeyCol text, sourceValueCol text, targetTable text, targetIdCol text, targetJsonbCol text)
RETURNS integer 
LANGUAGE plpgsql
AS $$
declare
        rec distinct_source_keys;
        total integer;
        i integer;
BEGIN
    total = 0;
    i = 0;
    for rec in
        execute format ('select distinct %I from %I', sourceKeyCol, foreignTable)
    loop
        execute format ('
        update %I t set %I = %I || (''{"''||f.%I||''": "''||f.%I||''"}'')::jsonb
        from %I f
        where t.%I=f.%I::integer
        and f.%I=$1
        and f.%I is not null;
        ', targetTable, targetJsonbCol, targetJsonbCol, sourceKeyCol, sourceValueCol, foreignTable, targetIdCol, targetIdCol, sourceKeyCol, sourceValueCol)
        using rec.key;

        GET DIAGNOSTICS i = ROW_COUNT;
        total = total + i;
        IF i > 0 AND (targetTable = 'marker' OR targetTable = 'dnarun') THEN
            PERFORM update_dataset_stats(rec.key::int, format('%s_count', targetTable), i);
        END IF;
    end loop;
    return total;
END;
$$


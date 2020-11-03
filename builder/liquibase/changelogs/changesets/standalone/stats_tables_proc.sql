--liquibase formatted sql

--changeset rduldulao:stats_tables_procs splitStatements:false runOnChange:false


CREATE OR REPLACE FUNCTION update_dataset_stats( dataset_id int, stat_name text, delta int ) RETURNS void
    LANGUAGE plpgsql AS $$

BEGIN
    EXECUTE format('UPDATE dataset_stats SET %I = %I + %s WHERE dataset_id = %I',
        stat_name, stat_name, delta, dataset_id
    );

    IF NOT FOUND THEN
        EXECUTE format('INSERT INTO dataset_stats(dataset_id, %I) VALUES (%s, %s)',
            stat_name, dataset_id, delta
        );
    END IF;

    EXECUTE format('UPDATE experiment_stats a, dataset b  SET a.%I = a.%I + %s WHERE b.dataset_id = %I AND b.experiment_id = a.experiment_id',
        stat_name, stat_name, delta, dataset_id
    );

    IF NOT FOUND THEN
        EXECUTE format('INSERT INTO experiment_stats(experiment_id, %I) SELECT a.experiment_id, %s FROM experiment a, dataset b WHERE b.dataset_id = %I AND b.experiment_id = a.experiment_id',
            stat_name, delta, dataset_id
        );
    END IF;

    EXECUTE format('UPDATE project_stats a, experiment b, dataset c SET a.%I + %s WHERE c.dataset_id = %I AND c.experiment_id = b.experiment_id AND a.project_id = b.project_id',
        stat_name, stat_name, delta, dataset_id
    );

    IF NOT FOUND THEN
        EXECUTE format('INSERT INTO project_stats(project_id, %I) SELECT a.project_id, %s FROM project a, experiment b, dataset c WHERE c.dataset_id = %I AND c.experiment_id = b.experiment_id AND b.project_id = a.project_id',
            stat_name, delta, dataset_id
        );
    END IF;
END;
$$
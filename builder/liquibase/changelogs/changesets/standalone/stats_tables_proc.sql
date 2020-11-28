--liquibase formatted sql

--changeset rduldulao:stats_tables_procs splitStatements:false runOnChange:false

-- CREATE OR REPLACE FUNCTION update_dataset_stats( dataset_id int, stat_name text, delta int ) RETURNS void
--     LANGUAGE plpgsql AS $$
-- declare
-- 	rcount int;
-- BEGIN
--     EXECUTE format('UPDATE dataset_stats SET %I = %I + %s WHERE dataset_id = %s',
--         stat_name, stat_name, delta, dataset_id
--     );

--     GET DIAGNOSTICS rcount = ROW_COUNT;
	
--     IF rcount = 0 THEN
--         EXECUTE format('INSERT INTO dataset_stats(dataset_id, %I) VALUES (%s, %s)',
--             stat_name, dataset_id, delta
--         );
--     END IF;

--     EXECUTE format('UPDATE experiment_stats SET %I = %I + %s FROM dataset  WHERE dataset.dataset_id = %s AND dataset.experiment_id = experiment_stats.experiment_id',
--         stat_name, stat_name, delta, dataset_id
--     );
	
--     GET DIAGNOSTICS rcount = ROW_COUNT;

--     IF rcount = 0 THEN
--         EXECUTE format('INSERT INTO experiment_stats(experiment_id, %I) SELECT a.experiment_id, %s FROM experiment a, dataset b WHERE b.dataset_id = %s AND b.experiment_id = a.experiment_id',
--             stat_name, delta, dataset_id
--         );
--     END IF;

--     EXECUTE format('UPDATE project_stats  SET %I = %I + %s FROM experiment , dataset  WHERE dataset.dataset_id = %s AND dataset.experiment_id = experiment.experiment_id AND project_stats.project_id = experiment.project_id',
--         stat_name, stat_name, delta, dataset_id
--     );

--     GET DIAGNOSTICS rcount = ROW_COUNT;
--     IF rcount = 0 THEN
--         EXECUTE format('INSERT INTO project_stats(project_id, %I) SELECT a.project_id, %s FROM project a, experiment b, dataset c WHERE c.dataset_id = %s AND c.experiment_id = b.experiment_id AND b.project_id = a.project_id',
--             stat_name, delta, dataset_id
--         );
-- 	END IF;
-- EXCEPTION
--     WHEN OTHERS THEN
--         NULL;
-- END;
-- $$;

CREATE OR REPLACE FUNCTION upsert_experiment_stats(e_id int, stat_name text) RETURNS void
    LANGUAGE plpgsql AS $$
declare
    icount int;
    rcount int;
BEGIN

    EXECUTE format(
        'SELECT SUM(dataset_stats.%I) FROM dataset_stats, dataset, experiment
        WHERE dataset_stats.dataset_id = dataset.dataset_id
        AND dataset.experiment_id = experiment.experiment_id
        AND experiment.experiment_id = %s', stat_name, e_id
    ) INTO icount;
   

    EXECUTE format(
        'UPDATE experiment_stats SET %I = %s WHERE experiment_id = %s',
        stat_name, icount, e_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    IF rcount = 0 THEN
        EXECUTE format(
            'INSERT INTO experiment_stats(experiment_id, %I) VALUES (%s, %s)', stat_name, e_id, icount
        );
    END IF;
END;
$$;


CREATE OR REPLACE FUNCTION upsert_project_stats(p_id int, stat_name text) RETURNS void
    LANGUAGE plpgsql AS $$
declare
    icount int;
    rcount int;
BEGIN

    EXECUTE format(
        'SELECT SUM(experiment_stats.%I)  FROM experiment_stats, experiment, project
        WHERE experiment_stats.experiment_id = experiment.experiment_id
        AND experiment.project_id = project.project_id
        AND project.project_id = %s', stat_name, p_id
    ) INTO icount;
   
    EXECUTE format(
        'UPDATE project_stats SET %I = %s WHERE project_id = %s', stat_name, icount, p_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    IF rcount = 0 THEN
        EXECUTE format(
            'INSERT INTO project_stats(project_id, %I) VALUES (%s, %s)', p_id, icount
        );
    END IF;
END;
$$;


CREATE OR REPLACE FUNCTION upsert_dataset_stats(d_id int, targetTable text, targetJsonbCol text) RETURNS void
    LANGUAGE plpgsql AS $$
declare
    icount int;
    exp_id int;
    proj_id int;
    stat_name text;
    rcount int;
BEGIN

    EXECUTE format('SELECT count(%s->''%s'') FROM %s',targetJsonbCol, d_id, targetTable) INTO icount;
    
    stat_name := format('%s_count', targetTable);

    EXECUTE format('UPDATE dataset_stats SET %I = %s WHERE dataset_id = %s', stat_name, icount, d_id);
    GET DIAGNOSTICS rcount = ROW_COUNT;
    IF rcount = 0 THEN
        EXECUTE format('INSERT INTO dataset_stats(dataset_id, %I) VALUES (%s, %s)', stat_name, d_id, icount);
    END IF;

    -- update parent entities 
    SELECT experiment_id INTO exp_id FROM dataset WHERE dataset_id = d_id;
    SELECT project_id INTO proj_id FROM experiment WHERE experiment_id = exp_id;

    PERFORM upsert_experiment_stats(exp_id, stat_name);
    PERFORM upsert_project_stats(proj_id, stat_name);

    EXCEPTION
        WHEN OTHERS THEN NULL;
 
END;
$$;


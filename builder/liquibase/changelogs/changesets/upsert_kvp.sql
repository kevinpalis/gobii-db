--liquibase formatted sql

--changeset kpalis:migrate_dataset_marker_data context:general splitStatements:false
do $$
declare
    ds record;
begin
	for ds in
		select distinct dataset_id from dataset_marker
	loop
		update marker m set dataset_marker_idx = dataset_marker_idx || ('{"'||dm.dataset_id||'": '||dm.marker_idx||'}')::jsonb
		from dataset_marker dm
		where m.marker_id = dm.marker_id
		and dm.dataset_id=ds.dataset_id
		and dm.marker_idx is not null;
	end loop;
end;
$$;

update marker t set dataset_marker_idx = dataset_marker_idx || ({"||f.dataset_id||": ||f.marker_idx||})::jsonb
from ft_dataset_marker_t6oyhhww f
where t.marker_id = f.marker_id
and f.dataset_id=r.dataset_id
and f.marker_idx is not null;


--will see if rollback is needed here
--source_table, source_key_column, source_value_column, target_table, target_id_col, target_jsonb_col
DROP FUNCTION upsertKVPFromForeignTable(foreignTable text, sourceKeyCol text, sourceValueCol text, targetTable text, targetIdCol text, targetJsonbCol text);
CREATE OR REPLACE FUNCTION upsertKVPFromForeignTable(foreignTable text, sourceKeyCol text, sourceValueCol text, targetTable text, targetIdCol text, targetJsonbCol text)
RETURNS integer AS $$
	declare
		r record;
		total integer;
		i integer;
		distinctSourceKeyCol text;
	BEGIN
		total = 0;
		i = 0;
		for r in
			execute format ('select distinct %I from %I', sourceKeyCol, foreignTable)
		loop
			select sourceKeyCol into distinctSourceKeyCol from r;
			execute format ('
				update %I t set %I = %I || (''{"''||f.%I||''": ''||f.%I||''}'')::jsonb
				from %I f
				where t.%I=f.%I::integer
				and f.%I=%I
				and f.%I is not null;
				', targetTable, targetJsonbCol, targetJsonbCol, sourceKeyCol, sourceValueCol, foreignTable, targetIdCol, targetIdCol, sourceKeyCol, r, sourceValueCol);
			GET DIAGNOSTICS i = ROW_COUNT;
			total = total + i;
		end loop;
		return total;
	END;
$$ LANGUAGE plpgsql;

DROP FUNCTION upsertKVPFromForeignTable(foreignTable text, sourceKeyCol text, sourceValueCol text, targetTable text, targetIdCol text, targetJsonbCol text);
CREATE OR REPLACE FUNCTION upsertKVPFromForeignTable(foreignTable text, sourceKeyCol text, sourceValueCol text, targetTable text, targetIdCol text, targetJsonbCol text)
RETURNS integer AS $$
	declare
		r record;
		total integer;
		i integer;
	BEGIN
		total = 0;
		i = 0;
		for r in
			select distinct sourceKeyCol from foreignTable
		loop
			update targetTable t set targetJsonbCol = targetJsonbCol || ('{"'||f.sourceKeyCol||'": '||f.sourceValueCol||'}')::jsonb
			from foreignTable f
			where t.targetIdCol = f.targetIdCol
			and f.sourceKeyCol=r.sourceKeyCol
			and f.sourceValueCol is not null;
			GET DIAGNOSTICS i = ROW_COUNT;
			total = total + i;
		end loop;
		return total;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upsertDnaSamplePropertyByName(id integer, propertyName text, propertyValue text)
RETURNS integer AS $$
  DECLARE
    propertyId integer;
  BEGIN
    select cv_id into propertyId from cv where term=propertyName;
    update dnasample_prop set props = props || ('{"'||propertyId::text||'": "'||propertyValue||'"}')::jsonb
      where dnasample_id=id;
    return propertyId;
  END;
$$ LANGUAGE plpgsql;
--liquibase formatted sql

--Adding 'not null' constraint to 'vendor_protocol_id' field in experiment table


--changeset kpalis:add_constraint_vendor_protocol_id context:pfr splitStatements:false runOnChange:false

--create them dummy rows to link the existing experiment rows without vendor_protocol_id to
SELECT createPlatform('Undefined', 'UNDEF', 'Undefined platform created so a not-null constraint can be added to vendor_protocol_id in the experiment table.', (SELECT contact_id FROM contact LIMIT 1), CURRENT_DATE, (SELECT contact_id FROM contact LIMIT 1), CURRENT_DATE, (SELECT cvid FROM getCvId('new', 'status', 1)), (SELECT cvid FROM getCvId('GBS', 'platform_type', 1)));
SELECT createVendorProtocol('Undefined', (SELECT organization_id FROM organization WHERE name='Cornell University'), (SELECT protocol_id FROM protocol LIMIT 1), (SELECT cvid FROM getCvId('new', 'status', 1)));
--update the existing data so we can add a not null constraint
UPDATE experiment
  SET vendor_protocol_id = (SELECT vendor_protocol_id FROM vendor_protocol WHERE name = 'Undefined')
  WHERE vendor_protocol_id IS NULL;

--add the not null constraint
ALTER TABLE experiment ALTER COLUMN vendor_protocol_id SET NOT NULL;

--changeset kpalis:add_constraint_project_id_experiment_name context:pfr splitStatements:false runOnChange:false
--update the existing data so we can add the unique constraint
WITH cte AS (
  SELECT ctid, project_id, name,
  ROW_NUMBER() OVER(PARTITION BY project_id, name ORDER BY experiment_id ASC) AS rn
  FROM experiment
)
UPDATE experiment AS e
	SET name=e.name || '-' || cte.rn
	FROM cte
	WHERE cte.rn > 1
	AND cte.ctid=e.ctid;

--add the unique constraint
ALTER TABLE experiment ADD UNIQUE (project_id, name);
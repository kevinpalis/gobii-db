--liquibase formatted sql

--Adding 'not null' constraint to 'vendor_protocol_id' field in experiment table


--changeset kpalis:add_constraint_vendor_protocol_id context:pfr splitStatements:false runOnChange:false

--create them dummy rows to link the existing experiment rows without vendor_protocol_id to
select createPlatform('Undefined', 'UNDEF', 'Undefined platform created so a not-null constraint can be added to vendor_protocol_id in the experiment table.', (select contact_id from contact limit 1), current_date, (select contact_id from contact limit 1), current_date, (select cvid from getCvId('new', 'status', 1)), (select cvid from getCvId('GBS', 'platform_type', 1)));
select createVendorProtocol('Undefined', (select organization_id from organization where name='Cornell University'), (select protocol_id from protocol limit 1), (select cvid from getCvId('new', 'status', 1)));
--update the existing data so we can add a not null constraint
UPDATE experiment
  SET vendor_protocol_id = (select vendor_protocol_id from vendor_protocol where name = 'Undefined')
  WHERE vendor_protocol_id IS NULL;

--add the not null constraint
ALTER TABLE experiment ALTER COLUMN vendor_protocol_id SET NOT NULL;


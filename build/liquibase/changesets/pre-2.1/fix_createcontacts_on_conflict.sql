--liquibase formatted sql

--changeset kpalis:createcontact_onconflict context:general splitStatements:false

--update all usernames that are blank to be the same as their emails for the unique constraint to work
UPDATE contact set username = email where username = '';
--add a unique constraint on the username column
ALTER TABLE contact DROP CONSTRAINT IF EXISTS contact_username_key;
ALTER TABLE contact ADD CONSTRAINT contact_username_key UNIQUE (username);

--add an on conflict clause to the create contact function
CREATE OR REPLACE FUNCTION createcontact(lastname text, firstname text, contactcode text, contactemail text, contactroles integer[], createdby integer, createddate date, modifiedby integer, modifieddate date, organizationid integer, uname text, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
  BEGIN
    insert into contact (lastname, firstname, code, email, roles, created_by, created_date, modified_by, modified_date, organization_id, username)
      values (lastName, firstName, contactCode, contactEmail, contactRoles, createdBy, createdDate, modifiedBy, modifiedDate, organizationId, uname)
      on conflict (username) DO NOTHING;
    select lastval() into id;
  END;
$function$;
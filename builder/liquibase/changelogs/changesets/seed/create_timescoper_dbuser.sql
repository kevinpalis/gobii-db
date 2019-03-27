--liquibase formatted sql
--NOTE: Adding this user is already part of the rawbase, but unfortunately, for existing databases, it doesn't work.
--Hence the need to cover liquibase migration paths as well.

--changeset kpalis:create_timescoper_dbuser context:seed_general splitStatements:false
--doing it this way because for pg9.5, there is no create user IF NOT EXIST
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT                       -- SELECT list can stay empty for this
      FROM   pg_catalog.pg_roles
      WHERE  rolname = 'timescoper'
      ) THEN
      create user timescoper with superuser password 't1m3sc0p3dbusr' valid until 'infinity';
   END IF;
END
$do$;

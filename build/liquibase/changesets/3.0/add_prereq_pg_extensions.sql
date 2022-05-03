--liquibase formatted sql

--changeset kpalis:add_prereq_pg_extensions context:general splitStatements:false runOnChange:false

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

--changeset kpalis:add_prereq_pg_extensions context:on_prem splitStatements:false runOnChange:false
CREATE EXTENSION IF NOT EXISTS file_fdw WITH SCHEMA public;
COMMENT ON EXTENSION file_fdw IS 'foreign-data wrapper for flat file access';


SET search_path = public, pg_catalog;

CREATE SERVER idatafilesrvr FOREIGN DATA WRAPPER file_fdw;
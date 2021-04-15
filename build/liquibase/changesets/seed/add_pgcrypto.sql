--liquibase formatted sql

--changeset kpalis:add_pgcrypto_extension context:seed_general splitStatements:false
CREATE EXTENSION pgcrypto;
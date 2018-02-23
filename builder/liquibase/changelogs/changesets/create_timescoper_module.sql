--liquibase formatted sql

--### Administrator Module for the GOBII Data TimeScope Web Application ###---
-- Roles: 1=Super Admin, 2=Admin, 3=User (reserved for foreseen functionality requests)
--changeset kpalis:create_administrator_table context:general splitStatements:false

CREATE TABLE IF NOT EXISTS public.timescoper
(
    timescoper_id serial NOT NULL,
    firstname text NOT NULL,
    lastname text NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    email text,
    role integer default 3,
    CONSTRAINT pk_timescoper PRIMARY KEY (timescoper_id),
    CONSTRAINT username_key UNIQUE (username)
);

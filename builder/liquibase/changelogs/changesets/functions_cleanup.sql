--liquibase formatted sql

--### Functions cleanup. Deleting functions that are broken or redundant. ###---
--changeset kpalis:drop_broken_functions context:general splitStatements:false
DROP FUNCTION IF EXISTS addanalysistodataset(integer,integer);
DROP FUNCTION IF EXISTS createdatasetmarker(integer, integer, real, real, real, jsonb);
DROP FUNCTION IF EXISTS createmarkerlinkagegroup(integer, integer, integer, integer);

DROP FUNCTION IF EXISTS getsampleqcmetadatabymarkerlistx(text, text);

DROP FUNCTION IF EXISTS getcontactnamesbyrole(character varying);
DROP FUNCTION IF EXISTS getcontactsbyrole(character varying);

DROP FUNCTION IF EXISTS updatemarkerlinkagegroup(integer, integer, integer, integer, integer);

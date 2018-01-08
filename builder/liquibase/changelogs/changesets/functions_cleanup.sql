--liquibase formatted sql

--### Functions cleanup. Deleting functions that are broken -- which means they were never used. ###---
DROP FUNCTION IF EXISTS addanalysistodataset(integer,integer);
DROP FUNCTION IF EXISTS createdatasetmarker(integer, integer, real, real, real, jsonb);
DROP FUNCTION IF EXISTS createmarkerlinkagegroup(integer, integer, integer, integer);

DROP FUNCTION IF EXISTS getsampleqcmetadatabymarkerlistx(text, text);
--!! DROP getcontactnamesbyrole AND getcontactsbyrole IF THEY AREN'T USED. They use refcursors which is not the preferred way. This is probably a remnant of the old code.

--now at updateanalysis() -- halfway done!
--liquibase formatted sql

--### Functions cleanup. Deleting functions that are broken -- which means they were never used. ###---
DROP FUNCTION IF EXISTS addanalysistodataset(integer,integer);
DROP FUNCTION IF EXISTS createdatasetmarker(integer, integer, real, real, real, jsonb);
DROP FUNCTION IF EXISTS createmarkerlinkagegroup(integer, integer, integer, integer);

--@deleteanalysis
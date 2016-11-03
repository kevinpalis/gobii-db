--liquibase formatted sql

--changeset venice.juanillas:alterTableAnalysis context:general splitStatements:false
DO $$ 
    BEGIN
        BEGIN
            ALTER TABLE analysis ADD COLUMN created_date date default('now'::text)::date ;
        EXCEPTION
            WHEN duplicate_column THEN RAISE NOTICE 'column created_date already exists in analysis.';
        END;
    END;
$$

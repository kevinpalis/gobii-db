--liquibase formatted sql
--changeset kpalis:test_1 context:dummy

alter table variant rename column code to variant_code;

--rollback alter table variant rename
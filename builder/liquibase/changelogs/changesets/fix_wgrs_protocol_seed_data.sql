--liquibase formatted sql

--changeset raza:fix_wgrs_porotocol_seed_data context:seed_general splitStatements:false

UPDATE PROTOCOL SET PLATFORM_ID = (select platform_id from platform where name ='Sequencing' ) WHERE NAME = 'WGRS';


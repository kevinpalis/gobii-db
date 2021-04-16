--liquibase formatted sql

--changeset kpalis:add_gadm_to_contacts context:seed_general splitStatements:false
select * from createcontact('Superuser','GADM','contact_code_gadm','gadm.gobii@gmail.com',( select array_agg(role_id) from role where role_name in ('Admin', 'PI', 'Curator','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'gadm');
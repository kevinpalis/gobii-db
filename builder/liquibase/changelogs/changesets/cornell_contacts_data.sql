--liquibase formatted sql

--changeset raza:cornell_contact context:seed_cornell splitStatements:false

select * from createContact('Alkhalifah','Naser','contact_1','nalkhal@iastate.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'USER_READER');
select * from createContact('Mueller','Lukas','contact_2','lam87@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'USER_READER');
select * from createContact('Johnson','Lynn','contact_3','lcj34@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'USER_READER');
select * from createContact('Romay','Cinta','contact_4','mcr72@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'USER_READER');
select * from createContact('Shi','Yuxin','contact_5','ys357@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'USER_READER');
select * from createContact('Agosto-Perez','Francisco','contact_6','fja32@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'USER_READER');
select * from createContact('Saied','Clare','contact_7','crs298@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team' ),'USER_READER');

select * from createContact('Jones','Liz','contact_8','ej245@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') ,'USER_READER');
select * from createContact('Nti-Addae','Yaw','contact_9','yn259@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'USER_READER' );
select * from createContact('Gao','Star','contact_10','yg28@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'USER_READER' );
select * from createContact('Robbins','Kelly','contact_11','krr73@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'USER_READER' );

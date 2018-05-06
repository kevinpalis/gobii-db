--liquibase formatted sql

--changeset raza:cbsu_gobii_contact context:seed_cbsu splitStatements:false


select * from createContact('Jones','Liz','contact_1','ej245@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') ,'ej245');
select * from createContact('Nti-Addae','Yaw','contact_2','yn259@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'yn259' );
select * from createContact('Gao','Star','contact_3','yg28@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'yg28' );
select * from createContact('Robbins','Kelly','contact_4','krr73@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'krr73' );

select * from createContact('Lamos-Sweeney','Josh','contact_5','jdl232@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') ,'jdl232');
select * from createContact('Glaser','Philip ','contact_6','pdg66@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'pdg66' );
select * from createContact('Palis','Kevin','contact_7','kdp44@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'kpalis' );
select * from createContact('Villahoz-Baleta','Angel','contact_8','av484@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'av484' );
select * from createContact('Ulat','Victor','contact_9','v.ulat@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'vulat' );
select * from createContact('Juanillas','Venice','contact_10','v.juanillas@irri.org',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'vjuanillas' );
select * from createContact('Raquel','Angel','contact_11','a.raquel@irri.org',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'araquel' );
select * from createContact('Calaminos','Viana','contact_12','v.calaminos@irri.org',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'vcalaminos' );
select * from createContact('Selvanayagam','Sivasubramani','contact_13','s.sivasubramani@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') ,'ssivasubramani' );
select * from createContact('Sarma','Chaitanya','contact_14','c.sarma@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') ,'mcs397' );
select * from createContact('Syed','Raza','contact_15','smr337@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') ,'smr337' );


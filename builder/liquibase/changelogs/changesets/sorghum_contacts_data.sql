--liquibase formatted sql

--changeset raza:sorghum_contact_uat context:seed_sorghum_uat splitStatements:false

select * from createContact('Bajaj','Prasad','contact_3','pb539@cornell.edu',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)'),'pb539'  );
select * from createContact('Das','Roma','contact_4','rrd47@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'rrd47' );
select * from createContact('Despande','Santosh','contact_5','s.deshpande@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)'),''  );
select * from createContact('Gaur','Pooran','contact_6','p.gaur@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'' );
select * from createContact('Grando','Stefania','contact_7','s.grando@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'' );
select * from createContact('Kudapa','Himabindu','contact_8','hbk39@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'hbk39' );
select * from createContact('Kumar','Are Ashok','contact_9','a.ashokkumar@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'' );
select * from createContact('Rathore','Abhishek','contact_10','ar2263@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'ar2263' );
select * from createContact('Roorkiwal','Manish','contact_11','mr983@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'mr983' );
select * from createContact('Selvanayagam','Sivasubramani','contact_12','ss3764@cornell.edu',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'ss3764' );
select * from createContact('Varshney','Rajeev','contact_13','r.k.varshney@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'' );
select * from createContact('Vemula','Anilkumar','contact_14','av375@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') ,'av375' );


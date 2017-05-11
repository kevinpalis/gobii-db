--liquibase formatted sql

--changeset raza:sorghum_contact_rel context:seed_sorghum splitStatements:false

Select * from createcontact('Bajaj','Prasad','contact_code_Bajaj','p.bajaj@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'pbajaj');
 Select * from createcontact('Das','Roma','contact_code_Das','r.das@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'rdas');
 Select * from createcontact('Deshpande','Santosh','contact_code_Deshpande','s.deshpande@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'sdeshpande');
 Select * from createcontact('Kudapa','Himabindu','contact_code_Kudapa','k.himabindu@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'khimabindu');
 Select * from createcontact('Kumar','Are Ashok','contact_code_Kumar','a.ashokkumar@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'aashokkumar');
 Select * from createcontact('Rathore','Abhishek','contact_code_Rathore','a.rathore@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','Curator','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'arathore');
 Select * from createcontact('Roorkiwal','Manish','contact_code_Roorkiwal','m.roorkiwal@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'mroorkiwal');
 Select * from createcontact('Selvanayagam','Sivasubramani','contact_code_Selvanayagam','s.sivasubramani@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'ssivasubramani');
 Select * from createcontact('Varshney','Rajeev','contact_code_Varshney','r.k.varshney@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'rkvarshney');
 Select * from createcontact('Sarma','Chaitanya','contact_code_Sarma','C.Sarma@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)' ),'csharma');


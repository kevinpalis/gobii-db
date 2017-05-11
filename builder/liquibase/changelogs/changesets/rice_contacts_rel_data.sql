--liquibase formatted sql

--changeset raza:rice_contact_rel context:seed_rice splitStatements:false

 Select * from createcontact('Kretzschmar','Tobias','contact_code_Kretzschmar','t.kretzschmar@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'tkretzschmar');
 Select * from createcontact('Cobb','Joshua Nathaniel','contact_code_Cobb','j.cobb@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'jcobb');
 Select * from createcontact('Dixit','Shalabh','contact_code_Dixit','s.dixit@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'sdixit');
 Select * from createcontact('Kumar','Arvind','contact_code_Kumar','a.kumar@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'akumar');
 Select * from createcontact('Reinke','Russel','contact_code_Reinke','r.reinke@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'rreinke');
 Select * from createcontact('Ignacio','John Carlos','contact_code_Ignacio','j.ignacio@irri.org',( select array_agg(role_id) from role where role_name in ('Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'jignacio');
 Select * from createcontact('Arbelaez-Velez','Juan David','contact_code_Arbelaez-Velez','j.arbelaezvelez@irri.org',( select array_agg(role_id) from role where role_name in ('Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'jvelez');
 Select * from createcontact('Loedin','Inez Slamet','contact_code_Loedin','i.slamet-loedin@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'iloedin');
 Select * from createcontact('Mauleon','Ramil','contact_code_Mauleon','r.mauleon@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'rmauleon');
 Select * from createcontact('Platten','John Damien','contact_code_Platten','j.platten@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'jplatten');
 Select * from createcontact('Venkatanagappa','Shoba','contact_code_Venkatanagappa','s.venkatanagappa@irri.org',( select array_agg(role_id) from role where role_name in ('PI', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'svenkatanagappa');
 Select * from createcontact('Rutkoski','Jessica','contact_code_Rutkoski','j.rutkoski@irri.org',( select array_agg(role_id) from role where role_name in ('Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'jrutkoski');
 Select * from createcontact('Abriol','Juan Miguel Carlos','contact_code_Abriol','m.abriol@irri.org',( select array_agg(role_id) from role where role_name in ('Admin', 'Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'jabriol');
 Select * from createcontact('Juanillas','Venice Margarette','contact_code_Juanillas','v.juanillas@irri.org',( select array_agg(role_id) from role where role_name in ('Admin', 'Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'vjuanillas');
 Select * from createcontact('Raquel','Angel Manica ','contact_code_Raquel','a.raquel@irri.org',( select array_agg(role_id) from role where role_name in ('Admin', 'Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'araquel');
 Select * from createcontact('Calaminos','Viana Carla','contact_code_Calaminos','v.calaminos@irri.org',( select array_agg(role_id) from role where role_name in ('Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'vcalaminos');
 Select * from createcontact('Detras','Jeffrey','contact_code_Detras','j.detras@irri.org',( select array_agg(role_id) from role where role_name in ('Admin', 'Curator', 'User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ),'jdetras');
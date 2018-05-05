
select * from createOrganization('International Rice Research Institute','Pili Drive UPLB Los Baños 4031 Laguna','http://irri.org/',1,NULL,NULL,NULL,1);

select * from createContact('Kretzschmar','Tobias','contact_3','t.kretzschmar@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Cobb','Joshua Nathaniel','contact_4','j.cobb@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Dixit','Shalabh','contact_5','s.dixit@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Kumar','Arvind','contact_6','a.kumar@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Reinke','Russel','contact_7','r.reinke@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Ignacio','John Carlos','contact_8','j.ignacio@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Arbelaez-Velez','Juan David','contact_9','j.arbelaezvelez@irri.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Loedin','Inez Slamet','contact_10','i.slamet-loedin@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Mauleon','Ramil','contact_11','r.mauleon@irri.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Abriol','Juan Miguel Carlos','contact_12','m.abriol@irri.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Juanillas','Venice Margarette','contact_13','v.juanillas@irri.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Raquel','Angel Manica ','contact_14','a.raquel@irri.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Calaminos','Viana Carla','contact_15','v.calaminos@irri.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );
select * from createContact('Detras','Jeffrey','contact_16','j.detras@irri.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Rice Research Institute' ) );

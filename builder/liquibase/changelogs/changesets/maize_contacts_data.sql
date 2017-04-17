--liquibase formatted sql

--changeset raza:maize_contact context:seed_maize splitStatements:false runOnChange:true
select * from createContact('Ulat','Victor','contact_3','vmu4@cornell.edu',( select array_agg(role_id) from role where role_name in ('Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Zhang','Xuecai','contact_4','xz428@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Hearne','Sarah','contact_5','s.hearne@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Nair','Sudha','contact_6','sudha.nair@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Semagn','Kassa','contact_7','CIMMYT-DMU@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Raman','Babu','contact_8','CIMMYT-DMU2@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Gowda','Manje','contact_9','m.gowda@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Huestis','Gordon','contact_10','g.huestis@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Magorokosho','Cosmos','contact_11','C.Magorokosho@CGIAR.ORG',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Beyene','Yoseph','contact_12','Y.Beyene@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') ,'USER_READER');
select * from createContact('Chen','Jiafa','contact_13','JF.chen@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Molnar','Terence','contact_14','t.molnar@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Jumbo','Bright','contact_15','b.jumbo@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Briones','Ernesto','contact_16','e.briones@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Dhliwayo','Thanda','contact_17','D.Thanda@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Dhugga','Kanwarpal','contact_18','k.dhugga@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Makumbi','Dan','contact_19','d.makumbi@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('San Vicente','Felix','contact_20','f.sanvicente@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Puebla','Luis','contact_21','l.puebla@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') ,'USER_READER');
select * from createContact('Riis','Jens','contact_22','j.riis@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Pixley','Kevin','contact_23','k.pixley@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Zaidi','P.H.','contact_24','phzaidi@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Vivek','Bindiganavile','contact_25','b.vivek@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') ,'USER_READER');
select * from createContact('Boddupalli','Prasanna','contact_26','b.m.prasanna@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Banziger','Marianne','contact_27','m.banziger@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Campos','Jaime','contact_28','J.A.Campos@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Ayala','Claudio','contact_29','cca46@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Shrestha','Rosemary','contact_30','R.Shrestha2@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Crossa','Jose','contact_31','j.crossa@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Burgueno','Juan','contact_32','j.burgueno@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Olsen','Michael','contact_33','m.olsen@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Ng''ang''a','Maureen','contact_34','M.Ng''ang''a@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );
select * from createContact('Dreher','Kate','contact_35','kad275@cornell.edu',( select array_agg(role_id) from role where role_name in ('Admin','Curator','PI','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'CIMMYT'),'USER_READER' );

select * from createContact('Robbins','Kelly','contact_36','krr73@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'USER_READER' );
select * from createContact('Gao','Star','contact_37','yg28@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'USER_READER' );
select * from createContact('Jones','Liz','contact_38','ej245@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') ,'USER_READER');

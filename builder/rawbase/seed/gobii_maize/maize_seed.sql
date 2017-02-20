
select * from createOrganization('CIMMYT','','http://www.cimmyt.org',1,NULL,NULL,NULL,1);
select * from createOrganization('Diversity Arrays Technology','','',1,NULL,NULL,NULL,1);
select * from createOrganization('SAGA','','http://www.cimmyt.org',1,NULL,NULL,NULL,1);
select * from createOrganization('Genomic Diversity Facility','Cornell University; Ithaca; NY; USA','',1,NULL,NULL,NULL,1);
select * from createOrganization('Cornell University','','www.cornell.edu',1,NULL,NULL,NULL,1);
select * from createOrganization('LGC Genomics Ltd','Cornell University; Ithaca; NY; USA','',1,NULL,NULL,NULL,1);
select * from createOrganization('CIMMYT Maize Molecular Breeding Laboratory','','http://www.cimmyt.org',1,NULL,NULL,NULL,1);
select * from createOrganization('KBiosciences','','',1,NULL,NULL,NULL,1);
select * from createOrganization('Illumina Inc.','','',1,NULL,NULL,NULL,1);
select * from createOrganization('Intertek','','http://www.intertek.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('GOBII Cornell Team','Cornell University; Ithaca; NY; USA','http://cbsugobii05.tc.cornell.edu/wordpress/',1,NULL,NULL,NULL,1);
select * from createOrganization('Monsanto','','',1,NULL,NULL,NULL,1);
select * from createOrganization('Pioneer','','',1,NULL,NULL,NULL,1);
select * from createOrganization('Syngenta','','',1,NULL,NULL,NULL,1);


select * from createContact('Ulat','Victor','contact_3','v.ulat@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Zhang','Xuecai','contact_4','XC.Zhang@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Hearne','Sarah','contact_5','s.hearne@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Nair','Sudha','contact_6','sudha.nair@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Semagn','Kassa','contact_7','CIMMYT-DMU@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Raman','Babu','contact_8','CIMMYT-DMU2@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Gowda','Manje','contact_9','m.gowda@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Huestis','Gordon','contact_10','g.huestis@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Magorokosho','Cosmos','contact_11','C.Magorokosho@CGIAR.ORG',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Beyene','Yoseph','contact_12','Y.Beyene@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Chen','Jiafa','contact_13','JF.chen@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Molnar','Terence','contact_14','t.molnar@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Jumbo','Bright','contact_15','b.jumbo@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Briones','Ernesto','contact_16','e.briones@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Dhliwayo','Thanda','contact_17','D.Thanda@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Dhugga','Kanwarpal','contact_18','k.dhugga@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Makumbi','Dan','contact_19','d.makumbi@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('San Vicente','Felix','contact_20','f.sanvicente@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Puebla','Luis','contact_21','l.puebla@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Riis','Jens','contact_22','j.riis@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Pixley','Kevin','contact_23','k.pixley@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Zaidi','P.H.','contact_24','phzaidi@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Vivek','Bindiganavile','contact_25','b.vivek@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Boddupalli','Prasanna','contact_26','b.m.prasanna@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Banziger','Marianne','contact_27','m.banziger@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Campos','Jaime','contact_28','J.A.Campos@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Ayala','Claudio','contact_29','c.ayala@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Shrestha','Rosemary','contact_30','R.Shrestha2@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Crossa','Jose','contact_31','j.crossa@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Burgueno','Juan','contact_32','j.burgueno@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Olsen','Michael','contact_33','m.olsen@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Ng''ang''a','Maureen','contact_34','M.Ng''ang''a@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Dreher','Kate','contact_35','k.dreher@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','Curator','PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );

select * from createContact('Robbins','Kelly','contact_36','krr73@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') );
select * from createContact('Gao','Star','contact_37','yg28@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') );
select * from createContact('Jones','Liz','contact_38','ej245@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') );



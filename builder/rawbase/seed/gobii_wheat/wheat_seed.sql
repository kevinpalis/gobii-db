
select * from createOrganization('CIMMYT','','http://www.cimmyt.org',1,NULL,NULL,NULL,1);
select * from createOrganization('ICARDA','','www.icarda.org',1,NULL,NULL,NULL,1);
select * from createOrganization('DArT','Canberra; Australia','http://www.diversityarrays.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('SAGA','Servicio de Analisis Genetico para la Agricultura','http://www.cimmyt.org',1,NULL,NULL,NULL,1);
select * from createOrganization('Genomic Diversity Facility','Cornell University; Ithaca; NY; USA','',1,NULL,NULL,NULL,1);
select * from createOrganization('Institute for Genomic Diversity','Cornell University; Ithaca; NY; USA','',1,NULL,NULL,NULL,1);
select * from createOrganization('LGC Genomics Ltd','','',1,NULL,NULL,NULL,1);
select * from createOrganization('Illumina Inc.','','',1,NULL,NULL,NULL,1);
select * from createOrganization('KSU','Gatersleben; Germany','http://www.traitgenetics.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('TraitGenetics','Kansas State University; Manhattan; KS; US','',1,NULL,NULL,NULL,1);
select * from createOrganization('University of Bristol','','',1,NULL,NULL,NULL,1);
select * from createOrganization('Intertek','','http://www.intertek.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('CIMMYT Wheat Molecular Breeding Laboratory','','',1,NULL,NULL,NULL,1);
select * from createOrganization('GOBII Cornell Team','Cornell University; Ithaca; NY; USA','http://cbsugobii05.tc.cornell.edu/wordpress/',1,NULL,NULL,NULL,1);



select * from createContact('Shrestha','Rosemary','contact_1','R.Shrestha2@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','PI','User','Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Ulat','Victor','contact_2','v.ulat@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Rutkoski','Jessica','contact_3','j.rutkoski@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Dreisigacker','Susanne','contact_4','s.dreisigacker@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Rosyara','Umesh','contact_5','u.rosyara@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Sansaloni','Carolina','contact_6','c.sansaloni@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Singh','Sukhwinder','contact_7','suk.singh@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Singh','Ravi','contact_8','r.singh@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Ammar','Karim','contact_9','k.ammar@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Sukumaran','Siva','contact_10','s.sukumaran@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Mondal','Suchismita','contact_11','s.mondal@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Bhavani','Sridhar','contact_12','s.bhavani@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Kumar','Uttam','contact_13','Uttam-Kumar@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Braun','Hans','contact_14','h.j.braun@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Lan','Caixia','contact_15','C.Lan@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Baum','Michael','contact_16','m.baum@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Reynolds','Matthew','contact_17','M.REYNOLDS@CGIAR.ORG',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Molero','Gemma','contact_18','g.molero@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Sehgal','Deepmala','contact_19','D.Sehgal@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Kishii','Masahiro','contact_20','m.kishii@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Randhawa','Mandeep','contact_21','M.RANDHAWA@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Vikram','Prashant','contact_22','p.vikram@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Campos','Jaime','contact_23','J.A.Campos@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Banziger','Marianne','contact_24','m.banziger@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Govindan','Velu','contact_25','velu@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Singh','Pawan','contact_26','p.singh@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('He','Xinyao','contact_27','X.He@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Crespo','Leonardo','contact_28','l.crespo@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Basnet','Bhoja','contact_29','B.R.Basnet@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Crossa','Jose','contact_31','j.crossa@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Burgueno','Juan','contact_32','j.burgueno@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Olsen','Michael','contact_33','m.olsen@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Puebla','Luis','contact_34','l.puebla@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Riis','Jens','contact_35','j.riis@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Pixley','Kevin','contact_36','k.pixley@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );
select * from createContact('Dreher','Kate','contact_37','k.dreher@cgiar.org',( select array_agg(role_id) from role where role_name in ('Admin','Curator','PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'CIMMYT') );

select * from createContact('Robbins','Kelly','contact_38','krr73@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') );
select * from createContact('Gao','Star','contact_39','yg28@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') );
select * from createContact('Jones','Liz','contact_40','ej245@cornell.edu',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team') );




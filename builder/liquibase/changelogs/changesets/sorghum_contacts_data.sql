--liquibase formatted sql

--changeset raza:sorghum_contact_uat context:seed_sorghum_uat splitStatements:false
--this change, unfortunately, will (gently) break migration path for this particular context, but I got no choice as people don't want publicly accessible email addresses be deep in a database source code.
--and I cannot just delete this file because then the migration path will not just gently break, it will go crashing down for existing instances.
select * from createContact('Palis','Kevin','contact_7','kdp44@cornell.edu',( select array_agg(role_id) from role where role_name in ('PI','Curator','Admin')),1,current_date,NULL,NULL,(select organization_id from organization where name = 'GOBII Cornell Team'),'kpalis' );
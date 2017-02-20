select * from createOrganization('Affymetrix, Inc., USA','Thermo Fisher Scientific, 3420 Central Expressway, Santa Clara, CA 95051','http://www.affymetrix.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('BGI Shenzhen, China','Main Building, Beishan Industrial Zone, Yantian District, Shenzhen 518083, China','http://www.genomics.cn/',1,NULL,NULL,NULL,1);
select * from createOrganization('Genomic Diversity Facility, Cornell University, USA','Cornell University, Institute of Biotechnology, Ithaca, USA','http://www.biotech.cornell.edu/brc/genomic-diversity-facility',1,NULL,NULL,NULL,1);
select * from createOrganization('Diversity Arrays Technology','Building 3, Level D, Monana St, University of Canberra, Bruce ACT 2617, Australia','http://www.diversityarrays.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('Genotypic Technology, India','2/13 Balaji Complex 80 Feet Road, RMV 2nd Stage, Bengaluru, Karnataka 560094','http://genotypic.co.in/',1,NULL,NULL,NULL,1);
select * from createOrganization('International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)','Patancheru 502324, Telangana State, India','http://www.icrisat.org/',1,NULL,NULL,NULL,1);
select * from createOrganization('Intertek Group plc, India','D-53, IDA, Phase-I, Jeedimetla, Hyderabad- 500 055','http://www.intertek.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('Intertek Group plc, Sweden','Intertek ScanBi Diagnostics AB, Elevenborgsvägen 2, Box 166, SE-230 53 Alnarp, Sweden','http://www.intertek.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('LGC Genomics Ltd, UK','Unit 1-2 Trident Industrial Estate, Pindar Road, Hoddesdon, Herts, EN11 0WZ, UK','http://www.lgcgroup.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('Macrogen Korea, Rep. of Korea','254, Beotkkot-ro, Geumcheon-gu, Seoul  (world Meridian Venture Center 10F), 153-781, Republic of Korea.','http://www.macrogen.com/eng/',1,NULL,NULL,NULL,1);
select * from createOrganization('SciGenom, India','G3 & C15, BTIC, Alexandria Knowledge Park, Genome Valley, Shameerpet, Hyderabad, India','http://www.scigenom.com/',1,NULL,NULL,NULL,1);
select * from createOrganization('Sequencing and Informatics Services, ICRISAT, India','Patancheru 502324, Telangana State, India','http://ceg.icrisat.org/',1,NULL,NULL,NULL,1);

select * from createContact('Bajaj','Prasad','contact_3','p.bajaj@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Das','Roma','contact_4','r.das@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Despande','Santosh','contact_5','s.deshpande@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Gaur','Pooran','contact_6','p.gaur@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Grando','Stefania','contact_7','s.grando@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Kudapa','Himabindu','contact_8','k.himabindu@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Kumar','Are Ashok','contact_9','a.ashokkumar@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Rathore','Abhishek','contact_10','a.rathore@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Roorkiwal','Manish','contact_11','m.roorkiwal@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Selvanayagam','Sivasubramani','contact_12','s.sivasubramani@cgiar.org',( select array_agg(role_id) from role where role_name in ('User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Varshney','Rajeev','contact_13','r.k.varshney@cgiar.org',( select array_agg(role_id) from role where role_name in ('PI','User')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );
select * from createContact('Vemula','Anilkumar','contact_14','anil.kumar@cgiar.org',( select array_agg(role_id) from role where role_name in ('Curator')),1,NULL,NULL,NULL,(select organization_id from organization where name = 'International Crops Research Institute for the Semi-Arid Tropics (ICRISAT)') );


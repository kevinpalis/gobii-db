--liquibase formatted sql

--changeset raza:org_seed context:seed_general splitStatements:false
Select * from createorganization('Affymetrix, Inc., USA','Thermo Fisher Scientific, 3420 Central Expressway, Santa Clara, CA 95051' ,'http://www.affymetrix.com/',1,current_date,NULL,NULL,1);
Select * from createorganization('BGI Shenzhen, China','Main Building, Beishan Industrial Zone, Yantian District, Shenzhen 518083, China' ,'http://www.genomics.cn/',1,current_date,NULL,NULL,1);
Select * from createorganization('DArT','Building 3, Level D, Monana St, University of Canberra, Bruce ACT 2617, Australia' ,'http://www.diversityarrays.com/',1,current_date,NULL,NULL,1);
Select * from createorganization('GDF, Cornell University','Cornell University, Institute of Biotechnology, Ithaca, USA' ,'http://www.biotech.cornell.edu/brc/genomic-diversity-facility',1,current_date,NULL,NULL,1);
Select * from createorganization('Genotypic Technology, India','2/13 Balaji Complex 80 Feet Road, RMV 2nd Stage, Bengaluru, Karnataka 560094' ,'http://genotypic.co.in/',1,current_date,NULL,NULL,1);
Select * from createorganization('International Crops Research Institute for the Semi-Arid Tropics (ICRISAT), India','Patancheru 502324, Telangana State, India' ,'http://www.icrisat.org/',1,current_date,NULL,NULL,1);
Select * from createorganization('Intertek Group plc, India','D-53, IDA, Phase-I, Jeedimetla, Hyderabad- 500 055' ,'http://www.intertek.com/',1,current_date,NULL,NULL,1);
Select * from createorganization('Intertek Group plc, Sweden','Intertek ScanBi Diagnostics AB, Elevenborgsvägen 2, Box 166, SE-230 53 Alnarp, Sweden' ,'http://www.intertek.com/',1,current_date,NULL,NULL,1);
Select * from createorganization('LGC','Unit 1-2 Trident Industrial Estate, Pindar Road, Hoddesdon, Herts, EN11 0WZ, UK' ,'http://www.lgcgroup.com/',1,current_date,NULL,NULL,1);
Select * from createorganization('Macrogen Korea, Rep. of Korea','254, Beotkkot-ro, Geumcheon-gu, Seoul  (world Meridian Venture Center 10F), 153-781, Republic of Korea.' ,'http://www.macrogen.com/eng/',1,current_date,NULL,NULL,1);
Select * from createorganization('SciGenom, India','G3 & C15, BTIC, Alexandria Knowledge Park, Genome Valley, Shameerpet, Hyderabad, India' ,'http://www.scigenom.com/',1,current_date,NULL,NULL,1);
Select * from createorganization('Sequencing and Informatics Services, ICRISAT, India','Patancheru 502324, Telangana State, India' ,'http://ceg.icrisat.org/',1,current_date,NULL,NULL,1);
Select * from createorganization('CIMMYT','' ,'http://www.cimmyt.org',1,current_date,NULL,NULL,1);
Select * from createorganization('CIMMYT Maize Molecular Breeding Laboratory','' ,'http://www.cimmyt.org',1,current_date,NULL,NULL,1);
Select * from createorganization('CIMMYT Wheat Molecular Breeding Laboratories','' ,'http://www.cimmyt.org',1,current_date,NULL,NULL,1);
Select * from createorganization('Cornell University','Ithaca, NY' ,'www.cornell.edu',1,current_date,NULL,NULL,1);
Select * from createorganization('GOBII Cornell Team','' ,'http://cbsugobii05.tc.cornell.edu/wordpress/',1,current_date,NULL,NULL,1);
Select * from createorganization('ICARDA','' ,'www.icarda.org',1,current_date,NULL,NULL,1);
Select * from createorganization('Illumina Inc.','' ,'',1,current_date,NULL,NULL,1);
Select * from createorganization('Kbiosciences','' ,'',1,current_date,NULL,NULL,1);
Select * from createorganization('KSU','' ,'',1,current_date,NULL,NULL,1);
Select * from createorganization('Monsanto','' ,'',1,current_date,NULL,NULL,1);
Select * from createorganization('Pioneer','' ,'',1,current_date,NULL,NULL,1);
Select * from createorganization('SAGA','' ,'http://www.cimmyt.org',1,current_date,NULL,NULL,1);
Select * from createorganization('Syngenta','' ,'',1,current_date,NULL,NULL,1);
Select * from createorganization('TraitGenetics   ','Gatersleben, Germany' ,'http://www.traitgenetics.com/',1,current_date,NULL,NULL,1);
Select * from createorganization('University of Bristol','' ,'',1,current_date,NULL,NULL,1);
Select * from createorganization('International Rice Research Institute','Pili Dr, College, Los Banos, Laguna 4031, Philippines' ,'http://www.irri.org',1,current_date,NULL,NULL,1);
Select * from createorganization('IRRI Genotyping Services Laboratory','Klaus J. Lampe Bldg, Pili Dr, College, Los Banos, Laguna 4031, Philippines' ,'http://gsl.irri.org',1,current_date,NULL,NULL,1);
Select * from createorganization(' Iowa State University','' ,'',1,current_date,NULL,NULL,1);




























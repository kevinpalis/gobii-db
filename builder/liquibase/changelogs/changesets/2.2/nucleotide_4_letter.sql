--liquibase formatted sql

--changeset kpalis:add_nucleotide_4_letter_cv context:seed_general splitStatements:false runOnChange:false

select * from createCVinGroup('dataset_type',1,'nucleotide_4_letter','eg AAAA CCCC CTTT for SNPs, + - for indels and NNNN for missing. Any allele phasing will be maintained',6,null,null, getPropertyIdByNamesAndType('status','new',1));

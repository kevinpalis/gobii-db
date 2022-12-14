--liquibase formatted sql

--changeset kpalis:on_conflict_createcvingroup context:seed_general splitStatements:false
CREATE OR REPLACE FUNCTION createcvingroup(pgroupname text, pgrouptype integer, pcvterm text, pcvdefinition text, pcvrank integer, pabbreviation text, pdbxrefid integer, pstatus integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   DECLARE
    groupId integer;
   BEGIN
     select cvgroup_id into groupId from cvgroup where name=pgroupname and type=pgrouptype;
     insert into cv (cvgroup_id, term, definition, rank, abbreviation, dbxref_id, status)
       values (groupId, pcvterm, pcvdefinition, pcvrank, pabbreviation, pdbxrefid, pstatus)
       on conflict (term, cvgroup_id) DO NOTHING;
     select lastval() into id;
   END;
 $$;

--changeset raza:cv_seed_data context:seed_general splitStatements:false
Select * from createCVinGroup('platform_type',1,'GBS','Genotyping by Sequencing',0,NUll,NULL,1);
Select * from createCVinGroup('project_prop',1,'genotyping_purpose','The purpose of genotyping such as MABC, MARS, Diversity etc',1,NUll,NULL,1);
Select * from createCVinGroup('project_prop',1,'date_sampled','Date tissue sampled and approx date of field trial',2,NUll,NULL,1);
Select * from createCVinGroup('project_prop',1,'division','Department or division where the project was made',3,NUll,NULL,1);
Select * from createCVinGroup('project_prop',1,'study_name','The name of the research study',4,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Illumina_Infinium','Illumina Infinium',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Illumina_Goldengate_bxp','Illumina GoldenGate',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'KASP','KASP',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Sequencing','Sequence-based Technologies',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Affymetrix_Axiom','Affymetrix Axiom',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Dartseq_SNPs','DArTSeq SNP',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Dart_silico','Silico DArT',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Dart_clone','DArT Clone',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Fluidigm','Fluidigm',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'SSR','Simple Sequence Repeats',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'Indel','insertion-deletion variant',0,NUll,NULL,1);
Select * from createCVinGroup('platform_type',1,'SSR_STS_CAPS','Fragment-size polymorphism technologies including Simple Sequence Repeats, Sequence-Tagged-Sites, and Cleaved Amplified Polymorphic Sequences',0,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'Inbred_line','Inbred line',1,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'Population','Population',2,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'F1_hybrid','F1_hybrid, the first filial generation or??hybrid??offspring??in a genetic cross-fertilization, such as bi-parental, 3-way, 4-way breeding crosses or hybrid test cross. For GOBII, it represent mostly bi-parental F1 breeding cross.',3,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'3_way_hybrid','3-way_F1_Cross, breeding cross involving 3 different parents',4,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'4_way_hybrid','4-way_F1_Cross, breeding cross involving 4 different parents',5,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'F2','F2, the second filial generation, offspring resulting from one cycle of selfing (S1) or interbreeding of the F1??breeding cross',6,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'F3','F3, the third filial generation, offspring resulting from two cycles of selfing (S2) or interbreeding of the F1??breeding cross',7,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'F4','F4, the fourth filial generation, offspring resulting from three cycles of selfing (S3) or interbreeding??of the F1??breeding cross',8,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'F5','F5, the fifth filial generation, offspring resulting from four cycles of selfing (S4) or interbreeding of the F1??breeding cross',9,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'F6','F6, the sixth filial generation, offspring resulting from five cycles of selfing (S5) or interbreeding??of the F1??breeding cross',10,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC1F1','BC1F1, the first generation of F1 backcrossed to the recurrent parent with 75% recurrent parent recovery',11,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC2F1','BC2F1, the second generation of F1 backcrossed to the recurrent parent with 87.5% recurrent parent recovery',12,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC3F1','BC3F1, the third generation of F1 backcrossed to the recurrent parent with 93.75% recurrent parent recovery',13,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC4F1','BC4F1, the fourth generation of F1 backcrossed to the recurrent parent with 96.875% recurrent parent recovery',14,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC5F1','backcross 5; F1 generation',15,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC1F2','backcross 1; F2 generation',16,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC2F2','backcross 2; F2 generation',17,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC3F2','backcross 3; F2 generation',18,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC4F2','backcross 4; F2 generation',19,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'BC5F2','backcross 5; F2 generation',20,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'Landrace','A locally adapted regional ecotype that may also be called a traditional variety',21,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'Synthetic','A variety generated by crossing in all combinations a series of lines',22,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'RIL','RIL: Recombinant Inbred Population',23,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'OPV','OPV: Open-pollinated variety',24,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'NIL','NIL: Near Isogenic Lines',25,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'DH','DH: Doubled Haploid',26,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'NAM','NAM: Nested Association Mapping',27,NUll,NULL,1);
Select * from createCVinGroup('germplasm_type',1,'MAGIC','MAGIC: Multi Parent Advanced Generation Intercrossed Population',28,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'germplasm_id','This will be a higher level GID eg MGID describing a group of similar lines/genotypes',1,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'seed_source_id','Seed source ID',2,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'germplasm_subsp','Germplasm sub-species eg indica, japonica, for rice; Dent, Flint for maize',3,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'germplasm_heterotic_group','Heterotic groups??within species eg NSS, SSS, A, B for maize',4,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'par1','Parent 1 of the germplasm name',5,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'par2','Parent??2 of the germplasm name',6,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'par3','Parent??3 of the germplasm',7,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'par4','Parent??4 of the germplasm name??',8,NUll,NULL,1);
Select * from createCVinGroup('germplasm_prop',1,'pedigree','',9,NUll,NULL,1);
Select * from createCVinGroup('status',1,'new','new row',1,NUll,NULL,1);
Select * from createCVinGroup('status',1,'modified','modified row',2,NUll,NULL,1);
Select * from createCVinGroup('status',1,'deleted','deleted row',3,NUll,NULL,1);
Select * from createCVinGroup('mapset_type',1,'physical','Physical map',1,NUll,NULL,1);
Select * from createCVinGroup('mapset_type',1,'genetic','Genetic map',2,NUll,NULL,1);
Select * from createCVinGroup('marker_strand',1,'TOP','Marker design on the ''top'' strand as defined by Illumina',1,NUll,NULL,1);
Select * from createCVinGroup('marker_strand',1,'BOT','Marker design on the ''bottom'' strand as defined by Illumina',2,NUll,NULL,1);
Select * from createCVinGroup('marker_strand',1,'Forward','Marker designed on the Forward Strand - used by most technologies apart from Illumina and Affymetrix',3,NUll,NULL,1);
Select * from createCVinGroup('marker_strand',1,'+','Marker designed on the positive or + strand eg used by?? Affymetrix',4,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'primer_forw1','First forward primer',1,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'primer_forw2','Second forward primer',2,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'primer_rev1','First reverse primer',3,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'primer_rev2','Second reverse primer',4,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'probe1','First probe',5,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'probe2','Second probe',6,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'polymorphism_type','This describes the type of polymorphism??that the marker interrogates eg SSR;SNP;Indel.',7,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'synonym','Another name for the marker',8,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'source','The source of the marker eg a publication reference or sequence assembly',9,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'gene_id','The gene the marker was designed to',10,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'gene_annotation','Type of gene eg transcription factor',11,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'polymorphism_annotation','eg Synonymous etc',12,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'marker_dom','Describes if the marker behaves in a dominant fashion ie?? presence/ absence with allele dosage (ie heterozygous or homozygous presence) for presence being unknown',13,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'clone_id','The clone ID - used for Dart technologies = the MarkerName for Silico Dart',14,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'clone_id_pos','The SNP position on the sequence for the clone ID - used for Dart technologies',15,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'genome_build','The genome build??that the marker was made with',16,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'typeofrefallele_alleleorder','How a??reference allele is called eg TOP/BOTT, F/R, +/-, first found, minor/major etc',17,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'strand_data_read','Strand that the allele data is read on ie the probe is designed to',18,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'allele2','second alternative allele',19,NUll,NULL,1);
Select * from createCVinGroup('marker_prop',1,'allele3','third alternative allele',20,NUll,NULL,1);
Select * from createCVinGroup('dnasample_prop',1,'trial_name','Trial name for field experiment that the sample is coming from, or fieldbook',1,NUll,NULL,1);
Select * from createCVinGroup('dnasample_prop',1,'sample_group','Sample Group eg MABCTHC_cycle1',2,NUll,NULL,1);
Select * from createCVinGroup('dnasample_prop',1,'sample_group_cycle','Cycle eg backcrossing cycle for??a sample group',3,NUll,NULL,1);
Select * from createCVinGroup('dnasample_prop',1,'sample_type','Type of tissue sampled eg leaf, seed, bulk seed, bulk plant',4,NUll,NULL,1);
Select * from createCVinGroup('dnasample_prop',1,'sample_parent_prop','Type of parent for a population eg donor, recurrent etc',5,NUll,NULL,1);
Select * from createCVinGroup('dnasample_prop',1,'ref_sample','Standard sample against which all other germplasm is compared to for this GID/MGID. Gold standard or Reference line.',6,NUll,NULL,1);
Select * from createCVinGroup('dnarun_prop',1,'barcode','Sample DNA barcode used to identify a sample using sequence-based technologies eg ACAATGGA',1,NUll,NULL,1);
Select * from createCVinGroup('analysis_type',1,'calling','Sequence alignment and variant calling pipelines',1,NUll,NULL,1);
Select * from createCVinGroup('analysis_type',1,'cleaning','Data cleaning methods used to remove poor quality data',2,NUll,NULL,1);
Select * from createCVinGroup('analysis_type',1,'imputation','Imputation??methods',3,NUll,NULL,1);
Select * from createCVinGroup('analysis_type',1,'allele_sorting','Method for sorting alleles eg due to phasing',4,NUll,NULL,1);
Select * from createCVinGroup('dataset_type',1,'nucleotide_2_letter','eg AA CC CT for SNPs, + - for indels and NN for missing. Any allele phasing will be maintained',1,NUll,NULL,1);
Select * from createCVinGroup('dataset_type',1,'iupac','IUPAC eg SNPs = ACGRY, indels = + 0 - , missing = N',2,NUll,NULL,1);
Select * from createCVinGroup('dataset_type',1,'dominant_non_nucleotide','0, 1 , N: 0 can be absence and 1 can be presence. N = missing',3,NUll,NULL,1);
Select * from createCVinGroup('dataset_type',1,'co_dominant_non_nucleotide','0, 1, 2, N: 0 can be absence, 1 is the heterozygote and 2 can be presence. N = missing',4,NUll,NULL,1);
Select * from createCVinGroup('dataset_type',1,'ssr_allele_size','Used for SSR allele sizes - converted to 8 numbers eg 123/125 becomes 01230125. Missing = 00000000',5,NUll,NULL,1);


--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.1
-- Dumped by pg_dump version 9.5.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

--
-- Data for Name: cv; Type: TABLE DATA; Schema: public; Owner: -
--

COPY cv (cv_id, "group", term, definition, rank) FROM stdin;
1	project_prop	genotyping_purpose	The purpose of genotyping such as MABC, MARS, Diversity etc	1
2	project_prop	date_sampled	Date tissue sampled and approx date of field trial	2
3	project_prop	division	Department or division where the project was made	3
4	project_prop	study_name	The name of the research study	4
5	platform_type	gbs	Genotyping by Sequencing	0
6	platform_type	illumina_infinium	Illumina Infinium	0
7	platform_type	illumina_goldengate	Illumina GoldenGate	0
8	platform_type	kasp	KASP	0
9	platform_type	sequencing	Sequence-based Technologies	0
10	platform_type	affymetrix_axiom	Affymetrix Axiom	0
11	platform_type	dartseq_snps	DArTSeq SNP	0
12	platform_type	dart silico	Silico DArT	0
13	platform_type	dart_clone	DArT Clone	0
14	platform_type	fluidigm	Fluidigm	0
15	platform_type	ssr	Simple Sequence Repeats	0
16	germplasm_type	inbred_line	Inbred line	1
17	germplasm_type	population	Population	2
18	germplasm_type	f1_hybrid	F1 hybrid	3
19	germplasm_type	3_way_hybrid	3-way hybrid	4
20	germplasm_type	4_way_hybrid	4-way hybrid	5
21	germplasm_type	f2	F2	6
22	germplasm_type	f3	F3	7
23	germplasm_type	f4	F4	8
24	germplasm_type	f5	F5	9
25	germplasm_type	f6	F6	10
26	germplasm_type	bc1f1	BC1F1	11
27	germplasm_type	bc2f1	BC2F1 	12
28	germplasm_type	bc3f1	BC3F1	13
29	germplasm_type	bc4f1	BC4F1 	14
30	germplasm_type	ril	RIL:Recombinant Inbred Population	15
31	germplasm_type	nil	NIL:Near Isogenic Lines	16
32	germplasm_type	dh	DH:Doubled Haploid	17
33	germplasm_type	nam	NAM:Nested Association Mapping	18
34	germplasm_type	magic	MAGIC:Multi Parent Advanced Generation Intercrossed Population	19
35	germplasm_prop	germplasm_id	This will be a higher level GID eg MGID describing a group of similar lines/genotypes	1
36	germplasm_prop	seed_source_id	Seed source ID	2
37	germplasm_prop	germplasm_subsp	Germplasm sub-species eg indica, japonica, for rice; Dent, Flint for maize	3
38	germplasm_prop	germplasm_heterotic_group	Heterotic groups within species eg NSS, SSS, A, B for maize	4
39	germplasm_prop	par1	Parent 1 of the germplasm name	5
40	germplasm_prop	par2	Parent 2 of the germplasm name	6
41	germplasm_prop	par3	Parent 3 of the germplasm	7
42	germplasm_prop	par4	Parent 4 of the germplasm name 	8
43	status	new	new row	1
44	status	modified	modified row	2
45	status	deleted	deleted row	3
48	marker_strand	top	Marker design on the "top" strand as defined by Illumina	1
49	marker_strand	bott	Marker design on the "bottom" strand as defined by Illumina	2
50	marker_strand	forward	Marker designed on the Forward Strand - used by most technologies apart from Illumina and Affymetrix	3
51	marker_strand	+	Marker designed on the positive or + strand eg used by  Affymetrix	4
52	marker_prop	primerF1	First forward primer	1
53	marker_prop	primerF2	Second forward primer	2
54	marker_prop	primerR1	First reverse primer	3
55	marker_prop	primerR2	Second reverse primer	4
56	marker_prop	probe1	First probe	5
57	marker_prop	probe2	Second probe	6
58	marker_prop	polymorphism_type	This describes the type of polymorphism that the marker interrogates eg SSR;SNP;Indel.	7
59	marker_prop	synonym	Another name for the marker	8
60	marker_prop	source	The source of the marker eg a publication reference or sequence assembly	9
61	marker_prop	gene_id	The gene the marker was designed to	10
62	marker_prop	gene_annotation	Type of gene eg transcription factor	11
63	marker_prop	polymorphism_annotation	eg Synonymous etc	12
64	marker_prop	marker_dom	Describes if the marker behaves in a dominant fashion ie  presence/ absence with allele dosage (ie heterozygous or homozygous presence) for presence being unknown	13
65	marker_prop	clone_id	The clone ID - used for Dart technologies = the MarkerName for Silico Dart	14
66	marker_prop	clone_id_pos	The SNP position on the sequence for the clone ID - used for Dart technologies	15
67	marker_prop	genome_build	The genome build that the marker was made with	16
68	marker_prop	typeofrefallele_alleleorder	How a reference allele is called eg TOP/BOTT, F/R, +/-, first found, minor/major etc	17
69	marker_prop	strand data_read	Strand that the allele data is read on ie the probe is designed to	18
70	dnasample_prop	trial_name	Trial name for field experiment that the sample is coming from, or fieldbook	1
71	dnasample_prop	sample_group	Sample Group eg MABCTHC_cycle1	2
72	dnasample_prop	sample_group_cycle	Cycle eg backcrossing cycle for a sample group	3
73	dnasample_prop	sample_type	Type of tissue sampled eg leaf, seed, bulk seed, bulk plant	4
74	dnasample_prop	sample_parent_prop	Type of parent for a population eg donor, recurrent etc	5
75	dnasample_prop	ref_sample	Standard sample against which all other germplasm is compared to for this GID/MGID. Gold standard or Reference line.	6
76	dnarun_prop	barcode	Sample DNA barcode used to identify a sample using sequence-based technologies eg ACAATGGA	1
79	germplasm_species	triticum_turgidum_subsp_durum  	Triticum turgidum subsp durum 	4
80	germplasm_species	triticosecale_spp 	Triticosecale spp	5
81	germplasm_species	oryza_sativa	Oryza sativa	6
82	germplasm_species	oryza_australiensis	Oryza australiensis	7
46	mapset_type	physical	Physical map	1
47	mapset_type	genetic	Genetic map	2
91	germplasm_species	sorghum_bicolor	Sorghum bicolor	1
92	analysis_type	variant_calling	Sequence alignment and variant calling pipelines	1
93	analysis_type	cleaning	Data cleaning methods used to remove poor quality data	2
94	analysis_type	imputation	Imputation methods	3
95	analysis_type	allele_sorting	Method for sorting alleles eg due to phasing	4
97	dataset_type	iupac	IUPAC eg ACGRY + 0 - N	2
98	dataset_type	dominant_non_nucleotide	0, 1 , N: 0 can be absence and 1 can be presence. N = missing	3
100	dataset_type	ssr_allele_size	Used for SSR allele sizes - converted to 8 numbers eg 123/125 becomes 01230125. Missing = 00000000	5
77	germplasm_species	zea_mays	 Zea mays	2
78	germplasm_species	triticum_aestivum_subsp_aestivum	Triticum aestivum subsp aestivum	3
83	germplasm_species	oryza_barthii	Oryza barthii	8
84	germplasm_species	oryza_glaberrima	Oryza glaberrima	9
85	germplasm_species	oryza_longistaminata	Oryza longistaminata	10
86	germplasm_species	oryza_punctata	Oryza punctata	11
87	germplasm_species	oryza_rufipogon	Oryza rufipogon	12
88	germplasm_species	cicer_arietinum	Cicer arietinum	13
89	germplasm_species	cicer_reticulatum	Cicer reticulatum	14
90	germplasm_species	cicer_echinospermum	Cicer echinospermum	15
96	dataset_type	nucleotide_2_letter	eg AA CC CT for SNPs, + - for indels and NN for missing. Any allele phasing will be maintained	1
99	dataset_type	co_dominant_non_nucleotide	0, 1, 2, N: 0 can be absence, 1 is the heterozygote and 2 can be presence. N = missing	4
\.


--
-- Name: cv_cv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('cv_cv_id_seq', 100, true);


--
-- PostgreSQL database dump complete
--


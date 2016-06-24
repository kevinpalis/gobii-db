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
1	status	new	new row	0
2	status	modified	modified row	0
3	status	deleted	deleted row	0
21	strand	top	Illumina's TOP strand	0
4	project_prop	division	Department or division where the project was made	0
5	project_prop	study_name	The name of the study	0
6	project_prop	genotyping_purpose	The purpose of genotyping	0
19	mapset_type	physical	Physical Map	0
20	mapset_type	genetic	Genetic Map	0
22	strand	bott	Illumina's BOTTOM strand	0
23	marker_prop	genome_build	The marker's genome build	0
24	marker_prop	species	Species	0
25	marker_prop	source	The source of this marker.	0
26	marker_prop	beadset_id	The beadset_id of this marker.	0
27	species	oryza_sativa_japonica	rice	0
52	germplasm_type	f2	F2: the actual definition	7
29	germplasm_prop	generation	Generation	0
30	dnasample_prop	sentrix_barcode_a	sentrixBarcodeA	0
31	dnasample_prop	sentrix_position_a	sentrixPositionA	0
32	dnasample_prop	sample_group	sample group	0
46	mapset_prop	subtype	Map Type: further properties of the map beyond genetic or physical	0
57	germplasm_prop	group_cycle	cycle of population improvement	0
36	project_prop	date_sampled	Date tissue sampled and approx date of field trial	0
33	analysis_type	calling	Calling	0
34	analysis_type	imputation	Imputation	0
35	platform_type	illumina_infinium	Illumina Infinium	0
37	platform_type	gbs	GBS Platform	0
28	germplasm_type	inbred_line	Inbred Line	2
38	platform_type	kasp	KASP Platform	0
39	platform_type	dartseq_snps	DaRTSeq SNPs Platform	0
40	platform_type	silicodarts	 SilicoDarts Platform	0
41	platform_type	dart_clone	 DartClone Platform	0
42	platform_type	fluidigm	 	0
43	platform_type	affymetrix_axiom	 	0
44	platform_type	illumina_goldengate_bxp	 	0
45	platform_type	ssr	 SSR	0
47	germplasm_type	accession	Type of material for GID/Germplasm name - describes level of outbreeding/heterozygosity we would expect	1
48	germplasm_type	population		3
49	germplasm_type	f1_hybrid		4
50	germplasm_type	3_way_hybrid		5
51	germplasm_type	4_way_hybrid		6
53	germplasm_type	f3		8
54	germplasm_type	f4		9
55	germplasm_type	f5		10
58	germplasm_prop	germplasm_id	this will be a higher level GID eg MGID describing a group of similar lines/genotypes	0
59	germplasm_prop	seed_source_id	is GID for BMS and B4R	0
62	strand	forward	Used by most technologies apart from Illumina and Affymetrix	0
63	strand	+	Positive strand used by Affymetrix	0
64	marker_prop	gene_id	The gene the marker was designed to	0
65	marker_prop	clone_id	used for Dart only  = the MarkerName for Dart-silico and Dart-seq/SNP (at least the first row for each marker allele dataset)	0
66	marker_prop	clone_id_pos	used for Dart only - SNP position in the sequence	0
67	marker_prop	synonym	Another name for the marker	0
68	marker_prop	polymorphism_type	SSR;SNP;Indel. This describes the underlying polymorphism, not the marker assay used to interrogate the polymorphism	0
56	germplasm_prop	group	Group of samples that can be grouped into a population for analysis. Can include parents for grouping and analysis purposes.	0
60	germplasm_prop	subspecies	Sub-set of species	0
61	germplasm_prop	heterotic_group	groups within species	0
69	marker_prop	marker_dom	Is the marker dominant ie does it only detect presence/absence?	0
70	marker_prop	gene_annotation	Type of gene	0
71	marker_prop	polymorphism_annotation	synonymous etc	0
72	marker_prop	typeofrefallele_alleleorder	There are multiple ways a reference allele can be called eg Is ref allele called on ToP/BOTT, F/R, +/-, first found, minor/major etc	0
73	dnasample_prop	sample_group_cycle	can group multiple groups together eg across backcross cycles	0
74	dnasample_prop	sample_type	type of tissue sampled	0
75	dnasample_prop	par1	parent/progeny relationships	0
76	dnasample_prop	par2	parent/progeny relationships	0
77	dnasample_prop	donor_parent	parent/progeny relationships	0
78	dnasample_prop	recurrent_parent	parent/progeny relationships	0
79	dnasample_prop	ref_sample	standard sample against which all other germplasm is compared for this GID/MGID. Gold standard or Reference line.	0
80	dnasample_prop	plant_id	could be from sample tracker	0
81	dnasample_prop	trial_name	Trial name for field experiment that the sample is coming from, or fieldbook 	0
82	dnarun_prop	barcode	eg ACAATGGA - how we find the sample sequence, for GbS technologies	0
84	species	triticum_aestivum_subsp_aestivum	 Triticum Aestivum subsp. Aestivum (Wheat)	0
85	species	triticum_turgidum_subsp_durum  	 Triticum Turgidum subsp. Durum (Wheat)	0
86	species	triticosecale_spp 	 Triticosecale spp. (Wheat)	0
87	species	oryza_sativa_indica	 Oryza Sativa Indica (Rice)	0
88	species	oryza_sativa_aus	 Oryza Sativa Aus (Rice)	0
89	species	cicer_arietinum	 Cicer Arietinum (Chickpea)	0
90	species	sorghum_bicolor	 Sorghum Bicolor (Sorghum)	0
91	analysis_type	cleaning	Cleaning	0
92	analysis_type	allele_sorting	Allele Sorting	0
94	dataset_type	iupac	IUPAC	2
97	dataset_type	ssr_allele_size	SSR Allele Size	5
98	platform_prop	subtype	placeholder property	0
83	species	zea_mays	 Zea Mays (Maize)	0
93	dataset_type	nucleotide_2_letter	Type of allele data. / and : will be removed	1
95	dataset_type	dominant_non_nucleotide	Dominant Non-nucleotide	3
96	dataset_type	codominant_non_nucleotide	Codominant non-nucleotide (1 is het)	4
\.


--
-- Name: cv_cv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('cv_cv_id_seq', 99, true);


--
-- PostgreSQL database dump complete
--


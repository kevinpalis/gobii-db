--liquibase formatted sql

--changeset kpalis:add_undefined_analysis context:seed_general splitStatements:false runOnChange:false

select createanalysis('undefined','undefined analysis',1,null,null,null,null,null,null,null,null,null,1,null,CAST(now() AS date),null,null);

--changeset kpalis:add_interteklgc_template1 context:meta_seed splitStatements:false runOnChange:false

COPY public.template (id, name, crop_id, description, creation_date, aspect) FROM stdin;
2       grid    1       \N      2022-03-17 05:08:19.849723+00   {"aspects": {"dnarun": {"name": ["COLUMN", {"row": 1, "column": 0}], "project_id": ["CONSTANT", "1"], "experiment_id": ["CONSTANT", "1"], "dnasample_name": ["COLUMN", {"row": 1, "column": 0}]}, "matrix": {"matrix": ["MATRIX", {"row": 1, "column": 5, "datasetType": "NUCLEOTIDE_2_LETTER"}]}, "dnasample": {"num": ["COLUMN", {"row": 1, "column": 0}], "name": ["COLUMN", {"row": 1, "column": 0}], "uuid": ["COLUMN", {"row": 1, "column": 0}], "status": ["CONSTANT", "57"], "well_col": ["COLUMN", {"row": 1, "column": 4}], "well_row": ["COLUMN", {"row": 1, "column": 3}], "plate_name": ["COLUMN", {"row": 1, "column": 1}], "project_id": ["CONSTANT", "1000"], "external_code": ["COLUMN", {"row": 1, "column": 0}]}, "germplasm": {"name": ["COLUMN", {"row": 1, "column": 0}], "status": ["CONSTANT", "57"], "external_code": ["COLUMN", {"row": 1, "column": 0}]}, "dataset_dnarun": {"dataset_id": ["CONSTANT", "1"], "dnarun_idx": ["RANGE", "0"], "dnarun_name": ["COLUMN", {"row": 1, "column": 0}], "platform_id": ["CONSTANT", "1"], "experiment_id": ["CONSTANT", "1"]}, "dataset_marker": {"dataset_id": ["CONSTANT", "1"], "marker_idx": ["RANGE", "0"], "marker_name": ["ROW", {"row": 0, "column": 5}], "platform_id": ["CONSTANT", "1"]}}}
1       markers 1       \N      2022-03-17 05:07:34.817322+00   {"aspects": {"marker": {"ref": ["COLUMN", {"row": 1, "column": 2}], "alts": ["TRANSFORM", "ARRAYIFY", ["COLUMN", {"row": 1, "column": 3}]], "name": ["COLUMN", {"row": 1, "column": 5}], "status": ["CONSTANT", "57"], "sequence": ["COLUMN", {"row": 1, "column": 4}], "platform_id": ["CONSTANT", "1"]}}}
\.

SELECT pg_catalog.setval('public.template_id_seq', 2, true);
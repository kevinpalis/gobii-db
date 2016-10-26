--liquibase formatted sql

--changeset venice.juanillas:alterFK_fk_project_contact context:general splitStatements:false
ALTER TABLE project RENAME CONSTRAINT fk_project_contact TO project_pi_contact_fkey;

--changeset venice.juanillas:alterFK_project_prop_fk1 context:general splitStatements:false
ALTER TABLE project_prop RENAME CONSTRAINT project_prop_fk1 TO project_prop_project_id_fkey;

--changeset venice.juanillas:alterFK_dataset_dnaruni_fk1 context:general splitStatements:false
ALTER TABLE dataset_dnarun RENAME CONSTRAINT  dataset_dnarun_fk1 TO dataset_dnarun_dataset_id_fkey;

--changeset venice.juanillas:alterFK_dataset_dnarun_fk2 context:general splitStatements:false
ALTER TABLE  dataset_dnarun RENAME CONSTRAINT  dataset_dnarun_fk2 TO  dataset_dnarun_dnarun_id_fkey;

--changeset venice.juanillas:alterFK_dataset_fk1 context:general splitStatements:false
ALTER TABLE  dataset RENAME CONSTRAINT  dataset_fk1 TO  dataset_experiment_id_fkey;

--changeset venice.juanillas:alterFK_dataset_fk2 context:general splitStatements:false
ALTER TABLE  dataset RENAME CONSTRAINT  dataset_fk2 TO  dataset_callinganalysis_id_fkey;

--changeset venice.juanillas:alterFK_dnarun_fk1 context:general splitStatements:false
ALTER TABLE  dnarun RENAME CONSTRAINT  dnarun_fk1 TO  dnarun_experiment_id_fkey;

--changeset venice.juanillas:alterFK_dnarun_fk2 context:general splitStatements:false
ALTER TABLE  dnarun RENAME CONSTRAINT  dnarun_fk2 TO  dnarun_dnasample_id_fkey;

--changeset venice.juanillas:alterFK_dnasample_fk1 context:general splitStatements:false
ALTER TABLE  dnasample RENAME CONSTRAINT  dnasample_fk1 TO  dnasample_project_id_fkey;

--changeset venice.juanillas:alterFK_dnasample_fk2 context:general splitStatements:false
ALTER TABLE  dnasample RENAME CONSTRAINT  dnasample_fk2 TO  dnasample_germplasm_id_fkey;

--changeset venice.juanillas:alterFK_dnasample_prop_fk1 context:general splitStatements:false
ALTER TABLE  dnasample_prop RENAME CONSTRAINT  dnasample_prop_fk1 TO  dnasample_prop_dnasample_id_fkey;

--changeset venice.juanillas:alterFK_experiment_fk1 context:general splitStatements:false
ALTER TABLE  experiment RENAME CONSTRAINT  experiment_fk1 TO  experiment_project_id_fkey;

--changeset venice.juanillas:alterFK_experiment_fk2 context:general splitStatements:false
ALTER TABLE  experiment RENAME CONSTRAINT  experiment_fk2 TO  experiment_platform_id_fkey;

--changeset venice.juanillas:alterFK_experiment_fk3 context:general splitStatements:false
ALTER TABLE  experiment RENAME CONSTRAINT  experiment_fk3 TO  experiment_manifest_id_fkey;

--changeset venice.juanillas:alterFK_fk_germplasm_species_id_cv context:general splitStatements:false
ALTER TABLE  germplasm RENAME CONSTRAINT  fk_germplasm_species_id_cv TO  germplasm_species_id_fkey;

--changeset venice.juanillas:alterFK_fk_linkage_group_map context:general splitStatements:false
ALTER TABLE  linkage_group RENAME CONSTRAINT  fk_linkage_group_map TO  linkage_group_map_id_fkey;

--changeset venice.juanillas:alterFK_fk_marker_cv context:general splitStatements:false
ALTER TABLE  marker RENAME CONSTRAINT  fk_marker_cv TO  marker_strand_id_fkey;

--changeset venice.juanillas:alterFK_fk_marker_linkage_group context:general splitStatements:false
ALTER TABLE  marker_linkage_group RENAME CONSTRAINT  fk_marker_linkage_group TO  marker_linkage_group_linkage_group_id_fkey;

--changeset venice.juanillas:alterFK_fk_marker_reference context:general splitStatements:false
ALTER TABLE  marker RENAME CONSTRAINT  fk_marker_reference TO  marker_reference_id_fkey;

--changeset venice.juanillas:alterFK_fk_organization_contact context:general splitStatements:false
ALTER TABLE  contact RENAME CONSTRAINT  fk_organization_contact TO  contact_organization_id_fkey;

--changeset venice.juanillas:alterFK_fk_platform_contact context:general splitStatements:false
ALTER TABLE  platform RENAME CONSTRAINT  fk_platform_contact TO  platform_vendor_id_fkey;

--changeset venice.juanillas:alterFK_fk_platform_cv context:general splitStatements:false
ALTER TABLE  platform RENAME CONSTRAINT  fk_platform_cv TO  platform_type_id_fkey;

--changeset venice.juanillas:alterFK_marker_fk2 context:general splitStatements:false
ALTER TABLE  marker RENAME CONSTRAINT  marker_fk2 TO  marker_variant_id_fkey;

--changeset venice.juanillas:alterFK_marker_fk1 context:general splitStatements:false
ALTER TABLE  marker RENAME CONSTRAINT  marker_fk1 TO  marker_platform_id_fkey;

--changeset venice.juanillas:alterFK_germplasm_prop_fk1 context:general splitStatements:false
ALTER TABLE  germplasm_prop RENAME CONSTRAINT  germplasm_prop_fk1 TO  germplasm_prop_germplasm_id_fkey;




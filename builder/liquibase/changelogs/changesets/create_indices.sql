--liquibase formatted sql

-- Indices on columns based from -map/-nmap for IFLs
--changeset raza:create_dnarun-name_index context:general
CREATE INDEX IF NOT EXISTS idx_dnarun_name on dnarun (name);

--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_marker_name on marker (name);

--changeset raza:create_experiment-name_index context:general
CREATE INDEX IF NOT EXISTS idx_experiment_name on experiment (name);

--changeset raza:create_dnasample-name_index context:general
CREATE INDEX IF NOT EXISTS idx_dnasample_name on dnasample (name);

--changeset raza:create_dnasample-platename_index context:general
CREATE INDEX IF NOT EXISTS idx_dnasample_platename on dnasample (platename);

--changeset raza:create_dnasample-num_index context:general
CREATE INDEX IF NOT EXISTS idx_dnasample_num on dnasample (num);

-- dnasample-well_row & dnasample-well_col
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_dnasample_rowcol on dnasample (well_row, well_col);

--germplasm-name
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_germplasm_name on germplasm (name);

--germplasm-external_code
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_germplasm_external_code on germplasm (external_code);

--germplasm-type_id
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_germplasm_type_id on germplasm (type_id);

--project-name
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_project_name on project (name);

--marker_linkage_group-marker_id
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_marker_linkage_group_mrk_id on marker_linkage_group (marker_id);

--marker_linkage_group-start
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_marker_linkage_group_start on marker_linkage_group (start);

--marker_linkage_group-stop
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_marker_linkage_group_stop on marker_linkage_group (stop);

--linkage_group-name
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_inkage_group_name on linkage_group (name);
--linkage_group-map_id
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_inkage_group_mapid on linkage_group (map_id);

-- following table-column names are used in dto in UI's  java code
-- analysis-type_id
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_analysis_type on analysis (type_id);

--role-role_name
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_role_name on role (role_name);

-- experiment-project_id
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_experiment_proj_id on experiment (project_id);

--dataset-experiment_id
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_dataset_experiment_id on dataset (experiment_id);

--display-lower(table_name)
--changeset raza:create_marker-name_index context:general
CREATE INDEX IF NOT EXISTS idx_display_table_name on display (lower(table_name));

--
-- Name: idx_germplasm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_germplasm ON germplasm (status);


--
-- Name: idx_germplasm_0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_germplasm_0 ON germplasm (species_id);


--
-- Name: idx_linkage_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_linkage_group ON linkage_group (map_id);


--
-- Name: idx_marker; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_marker ON marker (strand_id);


--
-- Name: idx_marker_0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_marker_0 ON marker (reference_id);


--
-- Name: idx_marker_map; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_marker_map ON marker_linkage_group (linkage_group_id);


--
-- Name: idx_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_platform ON platform (vendor_id);


--
-- Name: idx_platform_0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_platform_0 ON platform (type_id);


--
-- Name: idx_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_project ON project (pi_contact);
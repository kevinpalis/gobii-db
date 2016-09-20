-- Indices on columns based from .map/.nmap for IFLs
-- dnarun.name
CREATE INDEX IF NOT EXISTS idx_dnarun_name on dnarun using btree (name);

--marker.name
CREATE INDEX IF NOT EXISTS idx_marker_name on marker using btree (name);

--experiment.name
CREATE INDEX IF NOT EXISTS idx_experiment_name on experiment using btree (name);

--dnasample.name
CREATE INDEX IF NOT EXISTS idx_dnasample_name on dnasample using btree (name);

--dnasample.platename
CREATE INDEX IF NOT EXISTS idx_dnasample_platename on dnasample using btree (platename);

--dnasample.num
CREATE INDEX IF NOT EXISTS idx_dnasample_num on dnasample using btree (num);

-- dnasample.well_row & dnasample.well_col
CREATE INDEX IF NOT EXISTS idx_dnasample_rowcol on dnasample using btree (well_row, well_col);

--germplasm.name
CREATE INDEX IF NOT EXISTS idx_germplasm_name on germplasm using btree (name);

--germplasm.external_code
CREATE INDEX IF NOT EXISTS idx_germplasm_external_code on germplasm using btree (external_code);

--germplasm.type_id
CREATE INDEX IF NOT EXISTS idx_germplasm_type_id on germplasm using btree (type_id);

--project.name
CREATE INDEX IF NOT EXISTS idx_project_name on project using btree (name);

--marker_linkage_group.marker_id
CREATE INDEX IF NOT EXISTS idx_marker_linkage_group_mrk_id on marker_linkage_group using btree (marker_id);

--marker_linkage_group.start
CREATE INDEX IF NOT EXISTS idx_marker_linkage_group_start on marker_linkage_group using btree (start);

--marker_linkage_group.stop
CREATE INDEX IF NOT EXISTS idx_marker_linkage_group_stop on marker_linkage_group using btree (stop);

--linkage_group.name
CREATE INDEX IF NOT EXISTS idx_inkage_group_name on linkage_group using btree (name);
--linkage_group.map_id
CREATE INDEX IF NOT EXISTS idx_inkage_group_mapid on linkage_group using btree (map_id);

-- following table.column names are used in dto in UI's  java code
-- analysis.type_id
CREATE INDEX IF NOT EXISTS idx_analysis_type on analysis using btree (type_id);

--role.role_name
CREATE INDEX IF NOT EXISTS idx_role_name on role using btree (role_name);

-- experiment.project_id
CREATE INDEX IF NOT EXISTS idx_experiment_proj_id on experiment using btree (project_id);

--dataset.experiment_id
CREATE INDEX IF NOT EXISTS idx_dataset_experiment_id on dataset using btree (experiment_id);

--display.lower(table_name)
CREATE INDEX IF NOT EXISTS idx_display_table_name on display using btree (lower(table_name));

--
-- Name: idx_germplasm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_germplasm ON germplasm USING btree (status);


--
-- Name: idx_germplasm_0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_germplasm_0 ON germplasm USING btree (species_id);


--
-- Name: idx_linkage_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_linkage_group ON linkage_group USING btree (map_id);


--
-- Name: idx_marker; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marker ON marker USING btree (strand_id);


--
-- Name: idx_marker_0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marker_0 ON marker USING btree (reference_id);


--
-- Name: idx_marker_map; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marker_map ON marker_linkage_group USING btree (linkage_group_id);


--
-- Name: idx_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_platform ON platform USING btree (vendor_id);


--
-- Name: idx_platform_0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_platform_0 ON platform USING btree (type_id);


--
-- Name: idx_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_project ON project USING btree (pi_contact);
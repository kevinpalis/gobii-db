#!/usr/bin/env python
from __future__ import print_function
import psycopg2

class ConnectionManager:
	conn = None
	cur = None
	db_user = "loaderusr"
	db_pass = "loaderusr"
	db_host = "localhost"
	db_name = "gobii_rice2"
	db_port = "5432"

	def __init__(self):
		print("Database Manager Initialized.")

	def connectToDatabase(self):
		self.conn = psycopg2.connect(database=self.db_name, user=self.db_user, password=self.db_pass, host=self.db_host, port=self.db_port)
		self.cur = self.conn.cursor()
		return self.conn

	def getCvIdOfTerm(self, term):
		self.cur.execute("select cv_id from cv where lower(term)=%s", (term.lower(),))
		cv_id = self.cur.fetchone()
		if cv_id is not None:
			return cv_id[0]
		else:
			return cv_id

	def getLinkageGroupID(self, name):
		self.cur.execute("select linkage_group_id from linkage_group where lower(name)=%s", (name.lower(),))
		linkage_group_id = self.cur.fetchone()
		if linkage_group_id is not None:
			return linkage_group_id[0]
		else:
			return linkage_group_id

	def getAllelesFromSNPMap(self, markerName):
		self.cur.execute("select ref_allele, alt_allele from snp_map where lower(name)=%s", (markerName.lower(),))
		return self.cur.fetchone()

	def createMarker(self, platform_id, variant_id, marker_name, code, ref, alts, sequence, reference_id, primers, probsets, strand_id, status):
		self.cur.execute("insert into marker (platform_id, variant_id, name, code, ref, alts, sequence, reference_id, primers, probsets, strand_id, status) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", (platform_id, variant_id, marker_name, code, ref, alts, sequence, reference_id, primers, probsets, strand_id, status))
		self.cur.execute("select currval('marker_marker_id_seq')")
		marker_id = self.cur.fetchone()
		if marker_id is not None:
			return marker_id[0]
		else:
			return marker_id

	def getMarkerId(self, markerName):
		self.cur.execute("select marker_id from marker where name=%s", (markerName,))
		marker_id = self.cur.fetchone()
		if marker_id is not None:
			return marker_id[0]
		else:
			return marker_id

	def createMarkerMap(self, marker_id, start, stop, linkage_group_id):
		#self.cur.execute("insert into marker_map (marker_id, map_id, position, start, stop, linkage_group_id) VALUES (%s, %s, %s, %s, %s, %s)", (marker_id, map_id, position, start, stop, linkage_group_id))
		self.cur.execute("insert into marker_linkage_group (marker_id, start, stop, linkage_group_id) VALUES (%s, %s, %s, %s)", (marker_id, start, stop, linkage_group_id))

	def getCvIdOfGroupAndTerm(self, group, term):
		self.cur.execute("select cv_id from cv where lower(\"group\")=%s and lower(term)=%s", (group.lower(), term.lower()))
		cv_id = self.cur.fetchone()
		if cv_id is not None:
			return cv_id[0]
		else:
			return cv_id

	def createMarkerProperty(self, markerId, jsonProp):
		self.cur.execute("insert into marker_prop (marker_id, props) VALUES (%s, %s)", (markerId, jsonProp))

	def createGermplasm(self, germplasmName, germplasmCode, speciesId, germplasmType, createdBy, modifiedBy, status):
		self.cur.execute("insert into germplasm (name, code, species_id, type_id, created_by, modified_by, status) VALUES (%s, %s, %s, %s, %s, %s, %s)", (germplasmName, germplasmCode, speciesId, germplasmType, createdBy, modifiedBy, status))
		self.cur.execute("select currval('germplasm_germplasm_id_seq')")
		germplasmId = self.cur.fetchone()
		if germplasmId is not None:
			return germplasmId[0]
		else:
			return germplasmId

	def createDnaSample(self, dnaSampleName, code, plateName, dnaSampleNum, wellRow, wellCol, projectId, germplasmId, createdBy, modifiedBy, status):
		self.cur.execute("insert into dnasample (name, code, platename, num, well_row, well_col, project_id, germplasm_id, created_by, modified_by, status) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", (dnaSampleName, code, plateName, dnaSampleNum, wellRow, wellCol, projectId, germplasmId, createdBy, modifiedBy, status))
		self.cur.execute("select currval('dnasample_dnasample_id_seq')")
		dnaSampleId = self.cur.fetchone()
		if dnaSampleId is not None:
			return dnaSampleId[0]
		else:
			return dnaSampleId

	def createGermplasmProperty(self, germplasmId, jsonGermplasmProp):
		self.cur.execute("insert into germplasm_prop (germplasm_id, props) VALUES (%s, %s)", (germplasmId, jsonGermplasmProp))

	def createDnaSampleProperty(self, dnaSampleId, jsonDnaSampleProp):
		self.cur.execute("insert into dnasample_prop (dnasample_id, props) VALUES (%s, %s)", (dnaSampleId, jsonDnaSampleProp))

	def getGermplasmIdByCode(self, code):
		self.cur.execute("select germplasm_id from germplasm where code=%s", (code))
		germplasmId = self.cur.fetchone()
		if germplasmId is not None:
			return germplasmId[0]
		else:
			return germplasmId

	def getRowIdByCode(self, tableName, code):
		#print self.cur.mogrify("select "+tableName+"_id from "+tableName+" where code=%s", (code,))
		self.cur.execute("select "+tableName+"_id from "+tableName+" where code=%s", (code,))
		rowId = self.cur.fetchone()
		if rowId is not None:
			return rowId[0]
		else:
			return rowId

	def getRowIdByName(self, tableName, name):
		#print self.cur.mogrify("select "+tableName+"_id from "+tableName+" where name=%s", (name,))
		self.cur.execute("select "+tableName+"_id from "+tableName+" where name=%s", (name,))
		rowId = self.cur.fetchone()
		if rowId is not None:
			return rowId[0]
		else:
			return rowId

	def getContactIdByNameIgnoreCase(self, fname, lname):
		self.cur.execute("select contact_id from contact where lower(firstname)=%s and lower(lastname)=%s", (fname, lname))
		contact_id = self.cur.fetchone()
		if contact_id is not None:
			return contact_id[0]
		else:
			return contact_id

	def createContact(self, lastName, firstName, code, email, createdBy):
		self.cur.execute("insert into contact (lastname, firstname, code, email, created_by) VALUES (%s, %s, %s, %s, %s)", (lastName, firstName, code, email, createdBy))
		self.cur.execute("select currval('contact_contact_id_seq')")
		contact_id = self.cur.fetchone()
		if contact_id is not None:
			return contact_id[0]
		else:
			return contact_id

	def createProject(self, name, code, description, piContact, createdBy, modifiedBy, status):
		self.cur.execute("insert into project (name, code, description, pi_contact, created_by, modified_by, status) values (%s, %s, %s, %s, %s, %s, %s)", (name, code, description, piContact, createdBy, modifiedBy, status))
		self.cur.execute("select currval('project_project_id_seq')")
		project_id = self.cur.fetchone()
		if project_id is not None:
			return project_id[0]
		else:
			return project_id

	# Modified by: Venice Juanillas
	# Date: 2016-04-13:15:46
	def createExperiment(self, name, code, project_id, platform_id, manifest_id, data_file, status, created_by, modified_by):
		self.cur.execute("insert into experiment (name,code,project_id,platform_id,manifest_id,data_file,status,created_by,modified_by) values (%s, %s, %s, %s, %s, %s, %s, %s, %s)", (name, code, project_id, platform_id, manifest_id, data_file, status, created_by, modified_by))
		self.cur.execute("select currval('experiment_id')")
		experiment_id = self.cur.fetchone()
		if experiment_id is not None:
			return experiment_id[0]
		else:
			return experiment_id

	def createDataset(self, experiment_id, callinganalysis_id, data_table, data_file, created_by, modified_by, status):
		self.cur.execute("insert into dataset (experiment_id,callinganalysis_id,data_table,data_file,created_by, modified_by,status) values (%s, %s, %s, %s, %s, %s, %s)", (experiment_id, callinganalysis_id, data_table, data_file, created_by, modified_by, status))
		self.cur.execute("select currval('dataset_id')")
		dataset_id = self.cur.fetchone()
		if dataset_id is not None:
			return dataset_id[0]
		else:
			return dataset_id
	
	def createManifest(self,manifest_name,code, file_path,created_by, modified_by):
		self.cur.execute("insert into manifest(name,code,file_path,created_by,modified_by) values (%s, %s, %s, %s, %s)", (manifest_name,code, file_path,created_by, modified_by))
		self.cur.execute("select currval('manifest_id')");
		manifest_id = self.cur.fetchone()
		if manifest_id is not none:
			return manifest_id[0]
		else:
			return manifest_id
		
	
	#Note that this method will only work if there's no existing property row for this entity
	def createProperty(self, tableName, idColumnName, rowId, jsonProp):
		self.cur.execute("insert into "+tableName+" ("+idColumnName+", props) VALUES (%s, %s)", (rowId, jsonProp))

	def createDnaRun(self, experimentId, dnasampleId, name, code):
		self.cur.execute("insert into dnarun (experiment_id, dnasample_id, name, code) VALUES (%s, %s, %s, %s)", (experimentId, dnasampleId, name, code))
		self.cur.execute("select currval('dnarun_dnarun_id_seq')")
		dnaRunId = self.cur.fetchone()
		if dnaRunId is not None:
			return dnaRunId[0]
		else:
			return dnaRunId

	def createDatasetDnaRun(self, datasetId, dnaRunId):
		self.cur.execute("insert into dataset_dnarun (dataset_id, dnarun_id) VALUES (%s, %s)", (datasetId, dnaRunId))
		self.cur.execute("select currval('dataset_dnarun_dataset_dnarun_id_seq')")
		datasetDnaRunId = self.cur.fetchone()
		if datasetDnaRunId is not None:
			return datasetDnaRunId[0]
		else:
			return datasetDnaRunId

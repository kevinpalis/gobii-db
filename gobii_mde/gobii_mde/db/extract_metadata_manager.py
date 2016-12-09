#!/usr/bin/env python
from __future__ import print_function

from connection_manager import ConnectionManager
from foreign_data_manager import ForeignDataManager

class ExtractMetadataManager:

	def __init__(self, connectionStr):
		self.connMgr = ConnectionManager()
		self.conn = self.connMgr.connectToDatabase(connectionStr)
		self.cur = self.conn.cursor()
		self.fdm = ForeignDataManager()

	def dropForeignTable(self, fdwTableName):
		self.cur.execute("drop foreign table if exists "+fdwTableName)

	def createForeignTable(self, iFile, fTableName):
		header, fdwScript = self.fdm.generateFDWScript(iFile, fTableName)
		self.cur.execute(fdwScript)
		return header

	def createFileWithoutDuplicates(self, outputFilePath, noDupsSql):
		copyStmt = "copy ("+noDupsSql+") to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(copyStmt, outputFile, 20480)
		outputFile.close()

	def createAllMarkerMetadataFile(self, outputFilePath, datasetId, mapId):
		sql = ""
		if mapId == -1:
			sql = "copy (select * from getAllMarkerMetadataByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		else:
			sql = "copy (select * from getAllMarkerMetadataByDatasetAndMap("+datasetId+","+mapId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		print (sql)
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createMarkerNamesFile(self, outputFilePath, datasetId, mapId):
		sql = ""
		if mapId == -1:
			sql = "copy (select * from getMarkerNamesByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		else:
			sql = "copy (select * from getMarkerNamesByDatasetAndMap("+datasetId+","+mapId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createMinimalMarkerMetadataFile(self, outputFilePath, datasetId, mapId):
		sql = ""
		if mapId == -1:
			sql = "copy (select * from getMinimalMarkerMetadataByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		else:
			sql = "copy (select * from getMinimalMarkerMetadataByDatasetAndMap("+datasetId+","+mapId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createQCMarkerMetadataFile(self, outputFilePath, datasetId, mapId):
		sql = ""
		if mapId == -1:
			sql = "copy (select * from getMarkerQCMetadataByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		else:
			#TODO: in case we offer the feature to filter by mapId, we'll need to create a version of getMarkerQCMetadataByDataset that filters by mapId as well.
			sql = "copy (select * from getMinimalMarkerMetadataByDatasetAndMap("+datasetId+","+mapId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createChrLenFile(self, outputFilePath, datasetId, mapId):
		sql = ""
		outputFilePath = outputFilePath+".chr"
		if mapId == -1:
			sql = "copy (select * from getAllChrLenByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		else:
			sql = "copy (select * from getAllChrLenByDatasetAndMap("+datasetId+","+mapId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createAllSampleMetadataFile(self, outputFilePath, datasetId):
		sql = "copy (select * from getAllSampleMetadataByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createDnarunNamesFile(self, outputFilePath, datasetId):
		sql = "copy (select * from getDnarunNamesByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createMinimalSampleMetadataFile(self, outputFilePath, datasetId):
		sql = "copy (select * from getMinimalSampleMetadataByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createAllProjectMetadataFile(self, outputFilePath, datasetId):
		sql = "copy (select * from getAllProjectMetadataByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def getMarkerMapsetInfoByDataset(self, outputFilePath, datasetId, mapId):
		#rename this function
		'''
			For the given datasetId & mapId this funtion would output all markers in dataset and  only the given mapset info.
		'''
		outputFilePath = outputFilePath+".mapset"
		sql = "copy (select * from getMarkerMapsetInfoByDataset("+datasetId+","+mapId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def createSampleQCMetadataFile(self, outputFilePath, datasetId):
		sql = "copy (select * from getSampleQCMetadataByDataset("+datasetId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def getMarkerAllMapsetInfoByDataset(self, outputFilePath, datasetId, mapId):
		'''
			For the given datasetId & mapId this funtion would output all markers in dataset and mapsets associated with them.Markers with multiple mapsets will be repeated.
		'''
		outputFilePath = outputFilePath+".mapset"
		sql = "copy (select * from getMarkerAllMapsetInfoByDataset("+datasetId+","+mapId+")) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

	def commitTransaction(self):
		self.conn.commit()

	def rollbackTransaction(self):
		self.conn.rollback()

	def closeConnection(self):
		self.connMgr.disconnectFromDatabase()

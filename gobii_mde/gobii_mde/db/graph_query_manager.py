#!/usr/bin/env python
from __future__ import print_function
import psycopg2.extras
from connection_manager import ConnectionManager
# from foreign_data_manager import ForeignDataManager

class GraphQueryManager:

	def __init__(self, connectionStr):
		self.connMgr = ConnectionManager()
		self.conn = self.connMgr.connectToDatabase(connectionStr)
		self.cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
		# self.fdm = ForeignDataManager()

	def getMarkerIdsInGroups(self, markerGroupList, platformList):
			if not platformList:
				platformList = None
			else:
				platformList = "{"+(','.join(platformList))+"}"
			self.cur.execute("select distinct marker_id from getAllMarkersInMarkerGroups(%s, %s)", ("{"+(','.join(markerGroupList))+"}", platformList))
			res = self.cur.fetchall()
			return res

	def commitTransaction(self):
		self.conn.commit()

	def rollbackTransaction(self):
		self.conn.rollback()

	def closeConnection(self):
		try:
			self.connMgr.disconnectFromDatabase()
		except Exception as e:
			print ("Failed to close database session. Database connection may not have been established.\n Exception: %s" % e.message)

	def getVertex(self, vertexName):
			self.cur.execute("select * from vertex where name=%s", (vertexName,))
			res = self.cur.fetchone()
			return res

	def getCvId(self, term, groupName):
			self.cur.execute("select cvid from getcvid(%s, %s, %s)", (term, groupName, 1))
			res = self.cur.fetchone()
			return res

	def createQCMarkerMetadataByMarkerList(self, outputFilePath, markerList):
		sql = "copy (select * from getMarkerQCMetadataByMarkerList('{"+(','.join(markerList))+"}')) to STDOUT with delimiter E'\\t'"+" csv header;"
		with open(outputFilePath, 'w') as outputFile:
			self.cur.copy_expert(sql, outputFile, 20480)
		outputFile.close()

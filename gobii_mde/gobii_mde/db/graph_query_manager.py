#!/usr/bin/env python
from __future__ import print_function

from connection_manager import ConnectionManager
# from foreign_data_manager import ForeignDataManager

class GraphQueryManager:

	def __init__(self, connectionStr):
		self.connMgr = ConnectionManager()
		self.conn = self.connMgr.connectToDatabase(connectionStr)
		self.cur = self.conn.cursor()
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

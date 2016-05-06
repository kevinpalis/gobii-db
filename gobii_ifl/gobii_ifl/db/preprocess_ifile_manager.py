#!/usr/bin/env python
from __future__ import print_function

from connection_manager import ConnectionManager
from foreign_data_manager import ForeignDataManager

class PreprocessIfileManager:

	def __init__(self, connectionStr):
		self.connMgr = ConnectionManager()
		self.conn = self.connMgr.connectToDatabase(connectionStr)
		self.cur = self.conn.cursor()
		self.fdm = ForeignDataManager()
		#print("Preprocess IFile Manager Initialized.")

	def getCvIdOfTerm(self, term):
		self.cur.execute("select cv_id from cv where lower(term)=%s", (term.lower(),))
		cv_id = self.cur.fetchone()
		if cv_id is not None:
			return cv_id[0]
		else:
			return cv_id

	def getCvIdOfGroupAndTerm(self, group, term):
		self.cur.execute("select cv_id from cv where lower(\"group\")=%s and lower(term)=%s", (group.lower(), term.lower()))
		cv_id = self.cur.fetchone()
		if cv_id is not None:
			return cv_id[0]
		else:
			return cv_id

	def dropForeignTable(self, fdwTableName):
		self.cur.execute("drop foreign table if exists "+fdwTableName)

	def createForeignTable(self, iFile, fTableName):
		header, fdwScript = self.fdm.generateFDWScript(iFile, fTableName)
		self.cur.execute(fdwScript)
		return header

	def createFileWithDerivedIds(self, outputFilePath, derivedIdSql):
		copyStmt = "copy ("+derivedIdSql+") to '"+outputFilePath+"' with delimiter E'\\t'"+" csv header;"
		#print("copyStmt = "+copyStmt)
		self.cur.execute(copyStmt)

	def commitTransaction(self):
		self.conn.commit()

	def rollbackTransaction(self):
		self.conn.rollback()

	def closeConnection(self):
		self.connMgr.disconnectFromDatabase()
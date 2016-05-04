#!/usr/bin/env python
from __future__ import print_function

from connection_manager import ConnectionManager

class MarkerModuleManager:

	def __init__(self):
		self.connMgr = ConnectionManager()
		self.conn = self.connMgr.connectToDatabase()
		self.cur = self.conn.cursor()
		print("Marker Module Manager Initialized.")

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

	def closeConnection(self):
		self.connMgr.disconnectFromDatabase()

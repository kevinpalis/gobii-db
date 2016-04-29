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

	def disconnectFromDatabase(self):
		self.conn.close()

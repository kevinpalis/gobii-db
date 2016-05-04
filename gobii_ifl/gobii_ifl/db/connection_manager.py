#!/usr/bin/env python
from __future__ import print_function
import psycopg2

class ConnectionManager:
	"""
	This class manages the database connection and initializes connection and cursor objects.
	You'll have to manually change the connection credentials here.
	"""
	db_user = "loaderusr"
	db_pass = "loaderusr"
	db_host = "localhost"
	db_name = "gobii_rice2"
	db_port = "5432"

	def __init__(self):
		print("Database Manager Initialized.")

	def connectToDatabase(self):
		"""
		Start a database connection using the credentials set in the class variables.
		:returns: A connection object - This class also stores it as an instance variable for your convenience.
		"""
		self.conn = psycopg2.connect(database=self.db_name, user=self.db_user, password=self.db_pass, host=self.db_host, port=self.db_port)
		return self.conn

	def disconnectFromDatabase(self):
		"""
		End a database connection.
		"""
		self.conn.close()

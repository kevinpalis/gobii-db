#!/usr/bin/env python
from __future__ import print_function
import csv

class ForeignDataManager:
	"""
	This class handles the FDW and creation of SQL commands for external data
	"""
	def __init__(self):
		self.delim = "\t"
		self.fdwServer = "idatafilesrvr"

	def generateFDWScript(self, inputFile, fdwTableName):
		"""
		for the given fileName:
			- generate the fdw table script
			- generate the bulk insert script
		"""
		header = self.getHeader(inputFile)
		print("header: ", header)
		columnSpec = ', '.join(c + ' text' for c in header)
		fdwScript = ' '.join('CREATE TABLE', fdwTableName, '(', columnSpec, ')')
		print("fdwScript: ", fdwScript)
		return header, fdwScript

	def getHeader(self, inputFile):
		'''
		for the given data fileName:
		- get the header ( column names)
		'''
		dataFile = open(inputFile, 'r')
		reader = csv.reader(dataFile, delimiter=self.delim)
		header = reader.next()
		dataFile.close()
		return header

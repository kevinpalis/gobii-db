#!/usr/bin/env python
from __future__ import print_function
import string
import random
import sys
import subprocess
import os
import csv
from pprint import pprint

class MDEUtility:
	"""
	This class provides general and common methods for all IFL classes or scripts.
	"""
	@staticmethod
	def generateRandomString(length):
		"""
		This function generates a random alphanumeric string given of a given length.
		:args: length - the length of the random string to generate
		:returns: A connection object - This class also stores it as an instance variable for your convenience.
		"""
		chars = string.ascii_uppercase + string.digits
		return ''.join(random.choice(chars) for _ in range(length))

	@staticmethod
	def printError(*args, **kwargs):
		print(*args, file=sys.stderr, **kwargs)

	@staticmethod
	def getFileLineCount(fname):
		p = subprocess.Popen(['wc', '-l', fname], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		result, err = p.communicate()
		if p.returncode != 0:
			raise IOError(err)
		return int(result.strip().split()[0])

	@staticmethod
	def expandKeyValuePairColumn(colIdx, inFile, outFile, isVerbose):
		"""
		Expands the user properties column (key:value) to individual columns
		:args: tbd
		:returns: tbd
		"""
		##START: expanding the user properties column (key:value) to individual columns
		with open(inFile, 'r') as metaFile:
			if isVerbose:
				print("\tStarting expansion of user properties column(s)...")
			metaReader = csv.reader(metaFile, delimiter='\t')
			userPropsRows = []
			propNames = set()
			headerRow = next(metaReader)
			for row in metaReader:
				userProps = {}
				#properties are comma-delimited
				for prop in row[colIdx].split(','):
					#prop is empty
					if not prop:
						continue
					#key-value-pairs are colon-delimited
					key, value = prop.split(':')
					#store properties to a dictionary
					userProps[key.strip()] = value.strip()
					#keep a unique list of property names
					propNames.add(key.strip())
				#keep all rows in a list to maintain order
				userPropsRows.append(userProps)
				#pprint(userProps)
			if isVerbose:
				pprint(userPropsRows)
				pprint(propNames)
			metaFile.seek(0)  # reset the read position of the file object
			#sort the set alphabetically and convert to list for ease of concatenation
			propNamesSorted = sorted(propNames)
			#create a file with the expanded user properties
			with open(outFile, 'w') as metaFileOut:
				outWriter = csv.writer(metaFileOut, delimiter='\t')
				######YOU ARE HERE######
				headerRow = next(metaReader)[0:-1] + propNamesSorted
				outWriter.writerow(headerRow)
				if isVerbose:
					print("Created %s.tmp file for writing extended user props." % outputFile)
				for row, userProps in zip(metaReader, userPropsRows):
					#print("\tSecond read - Last column: %s" % row[-1])
					expandedProps = []
					for propName in propNamesSorted:
						expandedProps.append(userProps.get(propName, ""))
					newRow = row[0:-1] + expandedProps
					outWriter.writerow(newRow)
		# Although the rename function overwrites destination file silently on UNIX if the user has sufficient permission, it raises an OSError on Windows. So just to get maximum portability, I'm removing the old file before renaming the new one.
		try:
			os.remove(outputFile)
		except OSError as e:  # if for any reason, the old file cannot be deleted, stop MDE execution
			MDEUtility.printError('Failed to delete non-expanded marker metadata file. Error: %s - %s.' % (e.filename, e.strerror))
			sys.exit(16)
		os.rename(outputFile+'.tmp', outputFile)

		##END: expanding user properties
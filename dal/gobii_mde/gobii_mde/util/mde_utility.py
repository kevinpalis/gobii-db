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
		:param length: the length of the random string to generate
		:return random_string: a random alphanumeric string
		"""
		chars = string.ascii_uppercase + string.digits
		return ''.join(random.choice(chars) for _ in range(length))

	@staticmethod
	def printError(*param, **kwparam):
		"""
		Print message to stderr
		"""
		print(*param, file=sys.stderr, **kwparam)

	@staticmethod
	def getFileLineCount(fname):
		"""
		Gets the total number of lines for a given file using Linux wc utility
		:param fname: the file to check the line count of.
		:return line_count: an integer indicating the number of lines of file fname
		"""
		p = subprocess.Popen(['wc', '-l', fname], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		result, err = p.communicate()
		if p.returncode != 0:
			raise IOError(err)
		return int(result.strip().split()[0])

	@staticmethod
	def expandKeyValuePairColumn(colIdx, inFile, outFile, isVerbose):
		"""
		Expands the user properties column (key:value) of inFile to individual columns and write the results as outFile.
		:param colIdx: The index of the column to expand. This supports python's slicing indices.
		:param inFile: The input file path.
		:param outFile: The output file path.
		:param isVerbose: (boolean) Sets the verbosity.
		"""
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
			if isVerbose:
				pprint(propNames)
			metaFile.seek(0)  # reset the read position of the file object
			#sort the set alphabetically and convert to list for ease of concatenation
			propNamesSorted = sorted(propNames)
			#create a file with the expanded user properties
			with open(outFile, 'w') as metaFileOut:
				outWriter = csv.writer(metaFileOut, delimiter='\t')
				oldHeader = next(metaReader)
				totalCols = len(oldHeader)
				# this is needed to cover the case when slicing index start is -1, otherwise we can get rid of the entire if-else block
				# as oldHeader[colIdx+1:] will simply return None if out of range, but -1+1 is not out of range.
				if (colIdx == -1) or (colIdx == totalCols-1):
					headerRow = oldHeader[:colIdx] + propNamesSorted
				else:
					headerRow = oldHeader[:colIdx] + propNamesSorted + oldHeader[colIdx+1:]
				if isVerbose:
					print ("\n\tHeader row =")
					pprint(headerRow)
					print("Total number of columns = %s" % totalCols)
				outWriter.writerow(headerRow)
				if isVerbose:
					print("Created %s file for writing expanded user props." % outFile)
				for row, userProps in zip(metaReader, userPropsRows):
					expandedProps = []
					for propName in propNamesSorted:
						expandedProps.append(userProps.get(propName, ""))
					if (colIdx == -1) or (colIdx == totalCols-1):
						newRow = row[:colIdx] + expandedProps
					else:
						newRow = row[:colIdx] + expandedProps + row[colIdx+1:]
					outWriter.writerow(newRow)

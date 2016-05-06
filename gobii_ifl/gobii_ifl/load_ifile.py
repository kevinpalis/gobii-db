#!/usr/bin/env python
'''
	This script loads an intermediate file (Digester output) directly to its corresponding table in the GOBII schema.
	But before doing the actual bulk load, this will create a foreign table via the Foreign Data Wrapper and run a
	duplicates check, effectively removing the duplicates. The 'unique' rows are then piped to a file for the bulk loader
	to work on. Determining duplicates is done with the help of a mapping file (ex. marker.dupmap) which
	details the condition for a particular row to be a duplicate. For example, if marker.dupmap has:

	FILE_COLUMN_NAME 		TABLE_COLUMN_NAME
	-------------------------------------------------------------------
	name 								name
	ref_allele					ref

	This tells the script to use the following criteria for duplicates:
	If name column in file is equal to the value of marker.name AND ref_allele column in file is equal to the value of marker.ref
	column, then that row is a duplicate. The script will then NOT include that in the file for bulk loading. The .dupmap file
	can have an arbitrary number of criteria, just note that the comparison will always be an exact match.

	TODO:
	-Find a way to handle non-string comparisons as the FDW table columns are all text.
	@author kdp44 Kevin Palis
'''
from __future__ import print_function
import sys
import csv
import traceback
from os.path import basename
from os.path import splitext
from db.load_ifile_manager import LoadIfileManager
from pkg_resources import resource_string, resource_listdir, resource_stream
from util.ifl_utility import IFLUtility

IS_VERBOSE = True
SUFFIX_LEN = 8

if len(sys.argv) < 3:
	print("Please supply the parameters. \nUsage: load_ifile <intermediate_file> <output_file_path>")
	sys.exit()

if IS_VERBOSE:
	print("arguments: %s" % str(sys.argv))

iFile = str(sys.argv[1])
#dupMappingFile = str(sys.argv[2])
outputFile = str(sys.argv[2])
#print("splitext: ", splitext(basename(iFile)))
tableName = splitext(basename(iFile))[1][1:]
randomStr = IFLUtility.generateRandomString(SUFFIX_LEN)
fTableName = "ft_" + tableName + "_" + randomStr
if IS_VERBOSE:
	print("tableName:", tableName)

dupMappingFile = resource_stream('res.map', tableName+'.dupmap')
#instantiating this initializes a database connection
loadMgr = LoadIfileManager()

loadMgr.dropForeignTable(fTableName)
header = loadMgr.createForeignTable(iFile, fTableName)
loadMgr.commitTransaction()
if IS_VERBOSE:
	print("Foreign table %s created and populated." % fTableName)
selectStr = ""
joinStr = ""
fromStr = fTableName
conditionStr = ""
for fColumn in header:
	if selectStr == "":
		selectStr += fTableName+"."+fColumn
	else:
		selectStr += ", "+fTableName+"."+fColumn

try:
	reader = csv.reader(dupMappingFile, delimiter='\t')
	for file_column_name, table_column_name in reader:
		if IS_VERBOSE:
			print("Processing column: %s" % file_column_name)
		if(joinStr == ""):
			joinStr += fTableName+"."+file_column_name+"="+tableName+"."+table_column_name
		else:
			joinStr += " and "+fTableName+"."+file_column_name+"="+tableName+"."+table_column_name
		if(conditionStr == ""):
			conditionStr += tableName+"."+table_column_name+" is null"
		else:
			conditionStr += " and "+tableName+"."+table_column_name+" is null"
	dupMappingFile.close
	joinSql = "select "+selectStr+" from "+fromStr+" left join "+tableName+" on "+joinStr+" where "+conditionStr
	if IS_VERBOSE:
		print ("joinSql: "+joinSql)
	#ppMgr.createFileWithDerivedIds(outputFile, deriveIdSql)
	loadMgr.createFileWithoutDuplicates(outputFile, joinSql)
	print("Removed duplicates successfully.")
	#primary key column assumed to be tablename_id --> needs to be configurable(?) (would've been better if everything's just 'id' as usual!)
	loadMgr.loadData(tableName, header, outputFile, tableName+"_id")
	loadMgr.dropForeignTable(fTableName)
	loadMgr.commitTransaction()
	loadMgr.closeConnection()
	print("Loaded data successfully.")
except Exception as e:
	print('Failed to load data. Error: %s' % str(e))
	loadMgr.rollbackTransaction()
	traceback.print_exc()

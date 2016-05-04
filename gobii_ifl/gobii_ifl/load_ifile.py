#!/usr/bin/env python
'''
	This script loads the marker intermediate file (Digester output) directly to the marker table in the GOBII schema.

	Prerequisites:

	Note(s):

	TODO:
		Append session_id or anything to uniquely identify a single run of this script -- to the Foreign Table name,
		without it we'll have issues when two users run this script on the same DB at the same time!
	@author kdp44 Kevin Palis
'''
from __future__ import print_function
import sys
import csv
import traceback
from os.path import basename
from os.path import splitext
from db.load_ifile_manager import LoadIfileManager

IS_VERBOSE = True

if len(sys.argv) < 4:
	print("Please supply the parameters. \nUsage: load_ifile <intermediate_file> <duplicate_mapping_file> <output_file_path>")
	sys.exit()

if IS_VERBOSE:
	print("arguments: %s" % str(sys.argv))

iFile = str(sys.argv[1])
dupMappingFile = str(sys.argv[2])
outputFile = str(sys.argv[3])
#print("splitext: ", splitext(basename(iFile)))
tableName = splitext(basename(iFile))[1][1:]
fTableName = "ft_" + tableName
print("tableName:", tableName)

#instantiating this initializes a database connection
loadMgr = LoadIfileManager()

loadMgr.dropForeignTable(fTableName)
header = loadMgr.createForeignTable(iFile, fTableName)
loadMgr.commitTransaction()
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
	with open(dupMappingFile, 'r') as f1:
		reader = csv.reader(f1, delimiter='\t')
		for file_column_name, table_column_name in reader:
			print("Processing column: %s" % file_column_name)
			if(joinStr == ""):
				joinStr += fTableName+"."+file_column_name+"="+tableName+"."+table_column_name
			else:
				joinStr += " and "+fTableName+"."+file_column_name+"="+tableName+"."+table_column_name
			if(conditionStr == ""):
				conditionStr += tableName+"."+table_column_name+" is null"
			else:
				conditionStr += " and "+tableName+"."+table_column_name+" is null"
	f1.close
	joinSql = "select "+selectStr+" from "+fromStr+" left join "+tableName+" on "+joinStr+" where "+conditionStr
	print ("joinSql: "+joinSql)
	#ppMgr.createFileWithDerivedIds(outputFile, deriveIdSql)
	loadMgr.createFileWithoutDuplicates(outputFile, joinSql)
	print("Removed duplicates successfully.")
	#primary key column assumed to be tablename_id --> needs to be configurable(?) (would've been better if everything's just 'id' as usual!)
	loadMgr.loadData(tableName, header, outputFile, tableName+"_id")
	loadMgr.dropForeignTable(fTableName)
	loadMgr.commitTransaction()
	loadMgr.closeConnection()
except Exception as e:
	print('Failed to preprocess file: %s' % str(e))
	loadMgr.rollbackTransaction()
	traceback.print_exc()

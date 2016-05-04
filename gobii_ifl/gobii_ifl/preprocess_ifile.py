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
from db.preprocess_ifile_manager import PreprocessIfileManager

IS_VERBOSE = True

if len(sys.argv) < 4:
	print("Please supply the parameters. \nUsage: preprocess_ifile <intermediate_file> <name_mapping_file> <output_file_path>")
	sys.exit()

if IS_VERBOSE:
	print("arguments: %s" % str(sys.argv))

iFile = str(sys.argv[1])
nameMappingFile = str(sys.argv[2])
outputFile = str(sys.argv[3])
#print("splitext: ", splitext(basename(iFile)))
tableName = splitext(basename(iFile))[1][1:]
fTableName = "f_" + tableName
print("tableName:", tableName)


#instantiating this initializes a database connection
ppMgr = PreprocessIfileManager()

ppMgr.dropForeignTable(fTableName)
header = ppMgr.createForeignTable(iFile, fTableName)
ppMgr.commitTransaction()
print("Foreign table %s created and populated." % fTableName)
selectStr = ""
conditionStr = ""
fromStr = fTableName
for fColumn in header:
	if selectStr == "":
		selectStr += fTableName+"."+fColumn
	else:
		selectStr += ", "+fTableName+"."+fColumn
try:
	with open(nameMappingFile, 'r') as f1:
		reader = csv.reader(f1, delimiter='\t')
		for file_column_name, column_alias, table_name, name_column, id_column in reader:
			print("Processing column: %s" % file_column_name)
			fromStr += ", "+table_name
			if(conditionStr == ""):
				conditionStr += table_name+"."+name_column+"="+fTableName+"."+file_column_name
			else:
				conditionStr += " and "+table_name+"."+name_column+"="+fTableName+"."+file_column_name
			selectStr = selectStr.replace(fTableName+"."+file_column_name, table_name+"."+id_column+" as "+column_alias)
		#if(conditionStr != ""):
		#	conditionStr += ";"
	f1.close
	deriveIdSql = "select "+selectStr+" from "+fromStr+" where "+conditionStr
	print ("deriveIdSql: "+deriveIdSql)
	ppMgr.createFileWithDerivedIds(outputFile, deriveIdSql)
	ppMgr.dropForeignTable(fTableName)
	ppMgr.commitTransaction()
	ppMgr.closeConnection()
	print("Preprocessed file successfully.")
except Exception as e:
	print('Failed to preprocess file: %s' % str(e))
	ppMgr.rollbackTransaction()
	traceback.print_exc()

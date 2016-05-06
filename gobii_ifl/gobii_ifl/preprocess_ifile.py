#!/usr/bin/env python
'''
	This script preprocesses intermediate file (Digester output) to convert names/text columns to their
	corresponding database table IDs. This is done with the help of a mapping file (ex. marker.nmap) which
	details the name mapping. For example:

	FILE_COL_NAME 	COL_ALIAS 		TABLE_NAME 		NAME_COLUMN 	ID_COLUMN
	-------------------------------------------------------------------
	reference_name	reference_id	reference			name					reference_id
	strand_name			strand_id			cv						term					cv_id

	Row 2 basically says, for the 'strand_name' column in the file, find its ID in the database table 'cv'
	using the criteria: strand_name = cv.term column. Then in the result file, change the column name to the col_alias
	which is 'strand_id' for it to map directly to the strand_id column of the marker table.

	Prerequisites:

	@author kdp44 Kevin Palis
'''
from __future__ import print_function
import sys
import csv
import traceback
from os.path import basename
from os.path import splitext
from pkg_resources import resource_string, resource_listdir, resource_stream
from db.preprocess_ifile_manager import PreprocessIfileManager
from util.ifl_utility import IFLUtility


IS_VERBOSE = True
SUFFIX_LEN = 8
if len(sys.argv) < 4:
	print("Please supply the parameters. \nUsage: preprocess_ifile <db_connection_string> <intermediate_file> <output_file_path>")
	sys.exit()

if IS_VERBOSE:
	print("arguments: %s" % str(sys.argv))

connectionStr = str(sys.argv[1])
iFile = str(sys.argv[2])
#nameMappingFile = str(sys.argv[2])
outputFile = str(sys.argv[3])

#print("splitext: ", splitext(basename(iFile)))
tableName = splitext(basename(iFile))[1][1:]
randomStr = IFLUtility.generateRandomString(SUFFIX_LEN)
fTableName = "f_" + tableName + "_" + randomStr
if IS_VERBOSE:
	print("Foreign Table Name:", tableName)
	print("Getting information from mapping file: ", tableName+'.nmap')
	print(resource_listdir('res.map', ''))
	print(resource_string('res.map', tableName+'.nmap'))

nameMappingFile = resource_stream('res.map', tableName+'.nmap')
#sys.exit()
#instantiating this initializes a database connection
ppMgr = PreprocessIfileManager(connectionStr)

ppMgr.dropForeignTable(fTableName)
header = ppMgr.createForeignTable(iFile, fTableName)
ppMgr.commitTransaction()
if IS_VERBOSE:
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
	reader = csv.reader(nameMappingFile, delimiter='\t')
	for file_column_name, column_alias, table_name, name_column, id_column in reader:
		if IS_VERBOSE:
			print("Processing column: %s" % file_column_name)
		fromStr += ", "+table_name
		if(conditionStr == ""):
			conditionStr += table_name+"."+name_column+"="+fTableName+"."+file_column_name
		else:
			conditionStr += " and "+table_name+"."+name_column+"="+fTableName+"."+file_column_name
		selectStr = selectStr.replace(fTableName+"."+file_column_name, table_name+"."+id_column+" as "+column_alias)
	#if(conditionStr != ""):
	#	conditionStr += ";"
	nameMappingFile.close
	deriveIdSql = "select "+selectStr+" from "+fromStr+" where "+conditionStr
	#print ("deriveIdSql: "+deriveIdSql)
	ppMgr.createFileWithDerivedIds(outputFile, deriveIdSql)
	ppMgr.dropForeignTable(fTableName)
	ppMgr.commitTransaction()
	ppMgr.closeConnection()
	print("Preprocessed file successfully.")
except Exception as e:
	print('Failed to preprocess file: %s' % str(e))
	ppMgr.rollbackTransaction()
	traceback.print_exc()

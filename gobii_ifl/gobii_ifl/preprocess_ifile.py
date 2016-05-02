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

if len(sys.argv) < 3:
	print("Please supply the parameters. \nUsage: preprocess_ifile <intermediate_file> <name_mapping_file>")
	sys.exit()

if IS_VERBOSE:
	print("arguments: %s" % str(sys.argv))

iFile = str(sys.argv[1])
nameMappingFile = str(sys.argv[2])
#print("splitext: ", splitext(basename(iFile)))
tableName = splitext(basename(iFile))[1][1:]
fTableName = "f_" + tableName
print("tableName:", tableName)


#instantiating this initializes a database connection
ppMgr = PreprocessIfileManager()

ppMgr.dropForeignTable(fTableName)
ppMgr.createForeignTable(iFile, fTableName)
ppMgr.commitTransaction()
print("Foreign table %s created and populated." % fTableName)

try:
	with open(iFile, 'r') as f1:
		reader = csv.reader(f1, delimiter='\t')
		#for platform_id, variant_id, name, code, ref, alts, sequence, reference_name, primers, probsets, strand_name, status in reader:
			#print("Processing marker: %s" % name)
	f1.close
	print("Preprocessed file successfully.")
except Exception as e:
	print('Failed to preprocess file: %s' % str(e))
	traceback.print_exc()

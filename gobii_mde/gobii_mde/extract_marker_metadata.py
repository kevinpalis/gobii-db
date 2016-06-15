#!/usr/bin/env python
'''
	This script extracts marker metadata given a dataset ID.
	Prerequisites:

	@author kdp44 Kevin Palis
'''
from __future__ import print_function
import sys
import traceback
from util.mde_utility import MDEUtility
from db.extract_metadata_manager import ExtractMetadataManager

def main(isVerbose, connectionStr, datasetId, outputFile):
	if isVerbose:
		print("Getting marker metadata for dataset with ID: %s" % datasetId)
		print("Output File: ", outputFile)
	exMgr = ExtractMetadataManager(connectionStr)
	try:
		exMgr.createAllMarkerMetadataFile(outputFile, datasetId)
		exMgr.commitTransaction()
		exMgr.closeConnection()
		print("Created marker metadata file successfully.")
		return outputFile
	except Exception as e:
		MDEUtility.printError('Failed to create marker metadata file. Error: %s' % (str(e)))
		exMgr.rollbackTransaction()
		traceback.print_exc(file=sys.stderr)

if __name__ == "__main__":
	if len(sys.argv) < 4:
		print("Please supply the parameters. \nUsage: preprocess_ifile <db_connection_string> <dataset_id> <output_file_abs_path>")
		sys.exit()
	main(True, str(sys.argv[1]), str(sys.argv[2]), str(sys.argv[3]))

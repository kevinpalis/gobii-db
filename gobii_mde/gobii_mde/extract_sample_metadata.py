#!/usr/bin/env python
'''
	This script extracts sample metadata given a dataset ID.
	Prerequisites:
	Exit codes: 20-29
	@author kdp44 Kevin Palis
'''
from __future__ import print_function
import sys
import traceback
import os
from util.mde_utility import MDEUtility
from db.extract_metadata_manager import ExtractMetadataManager

def main(isVerbose, connectionStr, datasetId, outputFile, allMeta, namesOnly, markerList, sampleList, extractionType, datasetType):
	if isVerbose:
		print("Sample Metadata Output File: ", outputFile)
	exMgr = ExtractMetadataManager(connectionStr)
	try:
		if allMeta:  # deprecated
			exMgr.createAllSampleMetadataFile(outputFile, datasetId)
		elif namesOnly:  # deprecated
			exMgr.createDnarunNamesFile(outputFile, datasetId)
		else:
			if extractionType == 2:
				if isVerbose:
					print("Generating sample metadata by marker list.")
				exMgr.createSampleQCMetadataByMarkerList(outputFile, markerList, datasetType)
			elif extractionType == 3:
				if isVerbose:
					print("Generating sample metadata by sample list.")
				exMgr.createSampleQCMetadataBySampleList(outputFile, sampleList, datasetType)
				exMgr.createSamplePositionsFile(outputFile, sampleList, datasetType)
			elif extractionType == 1:
				if isVerbose:
					print("Generating sample metadata by datasetID.")
				exMgr.createSampleQCMetadataFile(outputFile, datasetId)
			else:
				MDEUtility.printError('ERROR: Extraction type is required.')
				sys.exit(21)

		#expand project user-defined properties
		MDEUtility.expandKeyValuePairColumn(-3, outputFile, outputFile+'.tmp1', isVerbose)
		#expand germplasm user-defined properties
		MDEUtility.expandKeyValuePairColumn(-2, outputFile+'.tmp1', outputFile+'.tmp2', isVerbose)
		#expand dnasample user-defined properties
		MDEUtility.expandKeyValuePairColumn(-1, outputFile+'.tmp2', outputFile+'.tmp3', isVerbose)

		# Replace main sample meta file
		# Although the rename function overwrites destination file silently on UNIX if the user has sufficient permission, it raises an OSError on Windows. So just to get maximum portability, I'm removing the old file before renaming the new one.
		try:
			os.remove(outputFile)
			os.rename(outputFile+'.tmp3', outputFile)
		except OSError as e:  # if for any reason, the old file cannot be deleted, stop MDE execution
			MDEUtility.printError('Failed to delete non-expanded sample metadata file. Error: %s - %s.' % (e.filename, e.strerror))
			sys.exit(22)
		#delete all temp files
		try:
			os.remove(outputFile+'.tmp1')
			os.remove(outputFile+'.tmp2')
		except OSError as e:  # if for any reason, the temp files cannot be deleted, print the error message but continue execution
			MDEUtility.printError('Failed to delete temp file. Error: %s - %s.' % (e.filename, e.strerror))
		exMgr.commitTransaction()
		exMgr.closeConnection()
		''' These don't make sense anymore. Requirements keep changing, I may need to reorganize.
		if allMeta:
			print("Created full sample metadata file successfully.")
		elif namesOnly:
			print("Created DNARun names file successfully.")
		else:
			#print("Created minimal sample metadata file successfully.")
			print("Created full sample metadata file successfully.")
		'''
		if isVerbose:
			print("Created sample metadata file successfully.")
		return outputFile
	except Exception as e:
		MDEUtility.printError('Failed to create sample metadata file. Error: %s' % (str(e)))
		exMgr.rollbackTransaction()
		traceback.print_exc(file=sys.stderr)
		sys.exit(20)


if __name__ == "__main__":
	if len(sys.argv) < 5:
		print("Please supply the parameters. \nUsage: extract_sample_metadata <db_connection_string> <dataset_id> <output_file_abs_path> <all_meta> <names_only> <markerList> <sampleList> <extractionType> <datasetType>")
		sys.exit(1)
	main(True, str(sys.argv[1]), str(sys.argv[2]), str(sys.argv[3]), str(sys.argv[4]), str(sys.argv[5]), str(sys.argv[6]), str(sys.argv[7]), str(sys.argv[8]), str(sys.argv[9]))

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

def main(isVerbose, connectionStr, datasetId, outputFile, allMeta, namesOnly, mapId, includeChrLen, displayMapId, markerList, sampleList):
	if isVerbose:
		print("Marker Metadata Output File: ", outputFile)
	exMgr = ExtractMetadataManager(connectionStr)
	try:
		if allMeta:
			exMgr.createAllMarkerMetadataFile(outputFile, datasetId, mapId)
		elif namesOnly:
			exMgr.createMarkerNamesFile(outputFile, datasetId, mapId)
		else:
			if markerList:
				if isVerbose:
					print("Generating marker metadata by marker list.")
				exMgr.createQCMarkerMetadataByMarkerList(outputFile, markerList)
			elif sampleList:
				if isVerbose:
					print("Generating marker metadata by sample list.")
					print("!!!Not yet implemented. Aborting...")
				return outputFile
			else:
				if isVerbose:
					print("Generating marker metadata by datasetID.")
				exMgr.createQCMarkerMetadataFile(outputFile, datasetId, mapId)
				#current version would pass only one mapId. In future this could be mapId[].
				if displayMapId != -1:
					exMgr.getMarkerAllMapsetInfoByDataset(outputFile, datasetId, displayMapId)
		if includeChrLen:
					exMgr.createChrLenFile(outputFile, datasetId, mapId, markerList, sampleList)
		exMgr.commitTransaction()
		exMgr.closeConnection()
		if allMeta:
			print("Created full marker metadata file successfully.")
		elif namesOnly:
			print("Created marker names file successfully.")
		else:
			print("Created minimal marker metadata file successfully.")
		return outputFile
	except Exception as e:
		MDEUtility.printError('Failed to create marker metadata file. Error: %s' % (str(e)))
		exMgr.rollbackTransaction()
		traceback.print_exc(file=sys.stderr)
		sys.exit(6)


if __name__ == "__main__":
	if len(sys.argv) < 5:
		print("Please supply the parameters. \nUsage: extract_marker_metadata <db_connection_string> <dataset_id> <output_file_abs_path> <all_meta> <names_only:boolean> <map_id> <includeChrLen:boolean> <displayMapId> <markerList> <sampleList>")
		sys.exit(1)
	main(True, str(sys.argv[1]), str(sys.argv[2]), str(sys.argv[3]), str(sys.argv[4]), str(sys.argv[5]), str(sys.argv[6]), str(sys.argv[7]), str(sys.argv[8]), str(sys.argv[9]), str(sys.argv[10]))

#!/usr/bin/env python
'''
	This script extracts marker metadata given a dataset ID.
	Prerequisites:
	Exit Codes: 10-19
	@author kdp44 Kevin Palis

	Extraction types:
	#1 = By dataset, 2 = By Markers, 3 = By Samples

	TODO: Extraction types to constants across IFLs
'''
from __future__ import print_function
import sys
import csv
import traceback
from util.mde_utility import MDEUtility
from db.extract_metadata_manager import ExtractMetadataManager

def main(isVerbose, connectionStr, datasetId, outputFile, allMeta, namesOnly, mapId, includeChrLen, displayMapId, markerList, sampleList, mapsetOutputFile, extractionType, datasetType, markerNames, platformList):
	MAPID_COL_POS = 2
	MARKERNAME_COL_POS_1 = 0
	MARKERNAME_COL_POS_2 = 0
	if isVerbose:
		print("Marker Metadata Output File: ", outputFile)
	exMgr = ExtractMetadataManager(connectionStr)
	try:
		if allMeta:  # deprecated
			exMgr.createAllMarkerMetadataFile(outputFile, datasetId, mapId)
		elif namesOnly:  # deprecated
			exMgr.createMarkerNamesFile(outputFile, datasetId, mapId)
		else:
			if extractionType == 1:  # by dataset
				if isVerbose:
					print("Generating marker metadata by dataset.")
				exMgr.createQCMarkerMetadataFile(outputFile, datasetId, mapId)
			elif extractionType == 2:  # by markers
				if isVerbose:
					print("Generating marker metadata by marker list.")
				if not markerList:
					if isVerbose:
						print("Deriving marker IDs based on the given parameters: markerNames, platformList, datasetType.")
				exMgr.createQCMarkerMetadataByMarkerList(outputFile, markerList)
				exMgr.createMarkerPositionsFileByMarkerList(outputFile, markerList)
			elif extractionType == 3:  # by samples
				if isVerbose:
					print("Generating marker metadata by sample list.")
					print("!!!Not yet implemented. Skipping...")
				return outputFile
			else:
				MDEUtility.printError('ERROR: Extraction type is required.')
				sys.exit(12)

		if displayMapId != -1:
			if mapsetOutputFile == '':
				MDEUtility.printError('ERROR: Mapset output file path is not set.')
				sys.exit(11)
			else:
				exMgr.createMapsetFile(mapsetOutputFile, datasetId, displayMapId, markerList, sampleList)
			#integrating the mapset info with the marker metadata file should be done here
			#Open marker meta file (markerMeta) and mapset meta file (mapsetMeta) and another file for writing.
			#Scan mapsetMeta for the displayMapId. Stop at the first instance found. These files are ordered accordingly, which saves the algorithm a lot of processing time.
			#For the first row found with the displayMapId, look for the row in markerMeta where markerMeta.marker_name=mapsetMeta.marker_name and append all columns of mapsetMeta to that row of markerMeta.
			#Iterate through the next rows until mapsetMeta.mapset_id!=displayMapId or eof
			with open(mapsetOutputFile, 'r') as mapsetMeta:
				with open(outputFile, 'r') as markerMeta:
					with open(outputFile+'.ext', 'w') as markerMetaExt:
						mapsetReader = csv.reader(mapsetMeta, delimiter='\t')
						markerReader = csv.reader(markerMeta, delimiter='\t')
						markerWriter = csv.writer(markerMetaExt, delimiter='\t')
						headerRow = next(markerReader) + next(mapsetReader)[MAPID_COL_POS+1:]
						markerWriter.writerow(headerRow)
						mapsetRowNum = 0
						mapsetRow = None
						for mapsetRow in mapsetReader:
								mapsetRowNum += 1
								if mapsetRow[MAPID_COL_POS] == displayMapId:
									if isVerbose:
										print ('Integrating map data to marker meta file. Found mapId at row %s.' % mapsetRowNum)
									break
						columnsCount = len(mapsetRow[MAPID_COL_POS+1:])
						fillerList = ['' for x in range(columnsCount)]
						if isVerbose:
							print('Mapset Row currently at marker_name=%s' % mapsetRow[MARKERNAME_COL_POS_1])
							print('Total number of columns to append: %s' % columnsCount)
						for markerRow in markerReader:
							if markerRow[MARKERNAME_COL_POS_2] == mapsetRow[MARKERNAME_COL_POS_1]:
								newRow = markerRow + mapsetRow[MAPID_COL_POS+1:]
								markerWriter.writerow(newRow)
								try:
									mapsetRow = next(mapsetReader)
								except StopIteration as e:
									if isVerbose:
										print ('End of file reached.')
									break
								if mapsetRow[MAPID_COL_POS] != displayMapId:
									break
							else:
								newRow = markerRow + fillerList
								markerWriter.writerow(newRow)
		if includeChrLen:
					exMgr.createChrLenFile(outputFile, datasetId, mapId, markerList, sampleList)
		exMgr.commitTransaction()
		exMgr.closeConnection()
		''' These things don't make sense anymore
		if allMeta:
			print("Created full marker metadata file successfully.")
		elif namesOnly:
			print("Created marker names file successfully.")
		else:
			print("Created minimal marker metadata file successfully.")
		'''
		if isVerbose:
			print("Created marker metadata file successfully.")
		return outputFile
	except Exception as e:
		MDEUtility.printError('Failed to create marker metadata file. Error: %s' % (str(e)))
		exMgr.rollbackTransaction()
		traceback.print_exc(file=sys.stderr)
		sys.exit(10)

#extractionType, datasetType, markerNames, platformList
if __name__ == "__main__":
	if len(sys.argv) < 15:
		print("Please supply the parameters. \nUsage: extract_marker_metadata <db_connection_string> <dataset_id> <output_file_abs_path> <all_meta> <names_only:boolean> <map_id> <includeChrLen:boolean> <displayMapId> <markerList> <sampleList> <mapsetOutputFile> <extractionType> <datasetType> <markerNames> <platformList>")
		sys.exit(1)
	main(True, str(sys.argv[1]), str(sys.argv[2]), str(sys.argv[3]), str(sys.argv[4]), str(sys.argv[5]), str(sys.argv[6]), str(sys.argv[7]), str(sys.argv[8]), str(sys.argv[9]), str(sys.argv[10]), str(sys.argv[11]), str(sys.argv[12]), str(sys.argv[13]), str(sys.argv[14]), str(sys.argv[15]))

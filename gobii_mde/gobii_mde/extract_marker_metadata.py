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
import os
import traceback
from util.mde_utility import MDEUtility
from db.extract_metadata_manager import ExtractMetadataManager


def main(isVerbose, connectionStr, datasetId, outputFile, allMeta, namesOnly, mapId, includeChrLen, displayMapId, markerList, sampleList, mapsetOutputFile, extractionType, datasetType, markerNames, platformList, piId, projectId, sampleType, sampleNames, markerGroupList):
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
			markerListFromGrp = []
			markerListFromNames = []
			if markerGroupList:
					if isVerbose:
						print("Deriving marker IDs from a list of marker groups.")
					res = exMgr.getMarkerIdsInGroups(markerGroupList, platformList)
					if res is None:
						MDEUtility.printError('Invalid marker group passed.')
						sys.exit(13)
					markerListFromGrp = [str(i[0]) for i in res]
					if not markerListFromGrp:
						MDEUtility.printError("Marker groups passed don't have any markers.")
						#sys.exit(15)
					#write the generation of marker group summary file here!
					if isVerbose:
						print("Generating marker group summary file.")
					exMgr.createMarkerGroupSummaryFile(outputFile, markerGroupList)
			if extractionType == 1:  # by dataset
				if isVerbose:
					print("Generating marker metadata by dataset.")
				exMgr.createQCMarkerMetadataFile(outputFile, datasetId, mapId)
			elif extractionType == 2:  # by markers
				if isVerbose:
					print("Generating marker metadata by marker list.")
				if not markerList and (markerNames or platformList):
					if isVerbose:
						print("Deriving marker IDs based on the given parameters: markerNames, platformList.")
						#get the marker ids list
					res = exMgr.getMarkerIds(markerNames, platformList, markerGroupList)
					if res is None:
						MDEUtility.printError("Resulting list of marker IDs from names is empty.")
					else:
						markerListFromNames = [str(i[0]) for i in res]

				'''
				if markerListFromGrp and markerListFromNames:
					markerList = list(set(markerListFromGrp + markerListFromNames + markerList))
				elif markerListFromGrp:
					markerList = list(set(markerListFromGrp + markerList))
				elif markerListFromNames:
					markerList = list(set(markerListFromNames + markerList))
				'''
				markerList = list(set(markerListFromGrp + markerListFromNames + markerList))
				if not markerList:
						MDEUtility.printError("Resulting list of marker IDs is empty. Nothing to extract.")
						sys.exit(15)
				#if isVerbose:
				#	print("markerList = ", markerList)
				exMgr.createQCMarkerMetadataByMarkerList(outputFile, markerList)
				if datasetType is None or datasetType < 0:
					MDEUtility.printError('Dataset type is required for extraction by marker list.')
					sys.exit(14)
				exMgr.createMarkerPositionsFile(outputFile, markerList, datasetType)  # this generates the pos file - will get affected by the inroduction of filtering by dataset type
			elif extractionType == 3:  # by samples
				if isVerbose:
					print("Generating marker metadata by sample list.")
				if not sampleList:
					if isVerbose:
						print("Deriving dnarun IDs based on the given parameters: piId, projectId, sampleNames + sampleType.")
						#piId, projectId, sampleType, sampleNames
					res = exMgr.getDnarunIds(piId, projectId, sampleType, sampleNames)
					if res is None:
						MDEUtility.printError('No Dnarun IDs fetched. Possible invalid usage. Check your criteria.')
						sys.exit(13)
					sampleList = [str(i[0]) for i in res]
					if not sampleList:
						MDEUtility.printError("Resulting list of Dnarun IDs is empty. Nothing to extract.")
						sys.exit(15)
					if isVerbose:
						print("Deriving marker IDs based on Dnarun IDs (using the dataset_dnarun_idx route).")
					#get the marker ids list based on the derived samples
					res2 = exMgr.getMarkerIdsFromSamples(sampleList, datasetType, platformList)
					if res2 is None:
						MDEUtility.printError('No Marker IDs fetched. Possible invalid usage. Check your criteria.')
						sys.exit(13)
					#Concatenate markers from markergroup and markerlist IF we are going to allow that capability
					markerList = [str(i[0]) for i in res2]
					markerList = list(set(markerList))  # remove duplicates - for some reasons I cannot comprehend yet, joining a jsonb column key using ? is producing duplicates, while ?| array does not
					if not markerList:
						MDEUtility.printError("Resulting list of marker IDs is empty. Nothing to extract.")
						sys.exit(15)
				exMgr.createQCMarkerMetadataByMarkerList(outputFile, markerList)
				if datasetType is None:
					MDEUtility.printError('Dataset type is required for extraction by sample list.')
					sys.exit(14)
				exMgr.createMarkerPositionsFile(outputFile, markerList, datasetType)  # this generates the marker.pos file
			else:
				MDEUtility.printError('ERROR: Extraction type is required.')
				sys.exit(12)

		#Expand the marker user props column
		MDEUtility.expandKeyValuePairColumn(-1, outputFile, outputFile+'.tmp', isVerbose)

		# Although the rename function overwrites destination file silently on UNIX if the user has sufficient permission, it raises an OSError on Windows. So just to get maximum portability, I'm removing the old file before renaming the new one.
		try:
			os.remove(outputFile)
			os.rename(outputFile+'.tmp', outputFile)
		except OSError as e:  # if for any reason, the old file cannot be deleted, stop MDE execution
			MDEUtility.printError('Failed to delete non-expanded marker metadata file. Error: %s - %s.' % (e.filename, e.strerror))
			sys.exit(16)

		if displayMapId != -1:
			if mapsetOutputFile == '':
				MDEUtility.printError('ERROR: Mapset output file path is not set.')
				sys.exit(11)
			else:
				exMgr.createMapsetFile(mapsetOutputFile, datasetId, displayMapId, markerList, sampleList, extractionType)
			#integrating the mapset info with the marker metadata file:
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
						mapsetRowsList = list(mapsetReader)  # this line unfortunately moves the file pointer to the end of the file
						mapsetMeta.seek(0)  # hence the need for this
						next(mapsetReader)  # skip the header, again
						totalMapsetRows = len(mapsetRowsList)
						foundMapId = False
						if isVerbose:
							print("Total mapset rows: %s" % totalMapsetRows)
							print("Looking for mapId=%s in %s" % (displayMapId, mapsetOutputFile))
							print ("MapsetReader: %s \n MapsetMeta: %s" % (mapsetReader, mapsetMeta))
						for mapsetRow in mapsetReader:
							mapsetRowNum += 1
							if mapsetRow[MAPID_COL_POS] == displayMapId:
								foundMapId = True
								if isVerbose:
									print ('Integrating map data to marker meta file. Found mapId at row %s.' % mapsetRowNum)
								break
						if mapsetRow is None:
							MDEUtility.printError('Failed to read the mapset file. Mapset row fetched is null. Please check if %s exists and contains correct data' % mapsetOutputFile)
							sys.exit(16)
						fillerList = []
						try:
							columnsCount = len(mapsetRow[MAPID_COL_POS+1:])
							fillerList = ['' for x in range(columnsCount)]
							if isVerbose:
								print('Mapset Row currently at marker_name=%s' % mapsetRow[MARKERNAME_COL_POS_1])
								print('Total number of columns to append: %s' % columnsCount)
						except Exception as ce:
							MDEUtility.printError('Failed to build the mapset column filler. Error: %s' % ce)
							sys.exit(16)
						eomReached = False
						if mapsetRowNum >= totalMapsetRows and not foundMapId:
							eomReached = True
						for markerRow in markerReader:
							if eomReached:
								newRow = markerRow + fillerList
								markerWriter.writerow(newRow)
								continue
							if markerRow[MARKERNAME_COL_POS_2] == mapsetRow[MARKERNAME_COL_POS_1]:
								newRow = markerRow + mapsetRow[MAPID_COL_POS+1:]
								markerWriter.writerow(newRow)
								try:
									mapsetRow = next(mapsetReader)
								except StopIteration as e:
									if isVerbose:
										print ('End of file reached.')
									eomReached = True
									#break
								if mapsetRow[MAPID_COL_POS] != displayMapId:
									eomReached = True
									#break
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
		return outputFile, markerList, sampleList
	except Exception as e:
		MDEUtility.printError('Failed to create marker metadata file. Error: %s' % (str(e)))
		exMgr.rollbackTransaction()
		traceback.print_exc(file=sys.stderr)
		sys.exit(10)


#extractionType, datasetType, markerNames, platformList
if __name__ == "__main__":
	if len(sys.argv) < 15:
		print("Please supply the parameters. \nUsage: extract_marker_metadata <db_connection_string> <dataset_id> <output_file_abs_path> <all_meta> <names_only:boolean> <map_id> <includeChrLen:boolean> <displayMapId> <markerList> <sampleList> <mapsetOutputFile> <extractionType> <datasetType> <markerNames> <platformList> <piId> <projectId> <sampleType> <sampleNames> <markerGroupList>")
		sys.exit(1)
	main(True, str(sys.argv[1]), str(sys.argv[2]), str(sys.argv[3]), str(sys.argv[4]), str(sys.argv[5]), str(sys.argv[6]), str(sys.argv[7]), str(sys.argv[8]), str(sys.argv[9]), str(sys.argv[10]), str(sys.argv[11]), str(sys.argv[12]), str(sys.argv[13]), str(sys.argv[14]), str(sys.argv[15]), str(sys.argv[16]), str(sys.argv[17]), str(sys.argv[18]), str(sys.argv[19]), str(sys.argv[20]))

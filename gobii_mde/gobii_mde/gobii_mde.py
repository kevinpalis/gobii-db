#!/usr/bin/env python
'''
	PRECEDENCE:
		1. Extraction by Dataset
		2. Extraction by Markers
		3. Extraction by Samples

	Exit Codes: 2-9
	2 -- Missing a required field
	3 -- Failed to extract marker meta
	4 -- Failed to extract sample meta
	5 -- Failed to extract project meta
	6 -- Validation Failure
'''
from __future__ import print_function
import sys
import getopt
import extract_marker_metadata
import extract_sample_metadata
import extract_project_metadata
from util.mde_utility import MDEUtility

def main(argv):
		verbose = False
		connectionStr = ""
		markerOutputFile = ""
		sampleOutputFile = ""
		datasetId = -1
		projectOutputFile = ""
		allMeta = False
		namesOnly = False
		mapId = -1
		includeChrLen = False
		displayMap = -1
		markerListFile = ""
		sampleListFile = ""
		mapsetOutputFile = ""
		markerNamesFile = ""
		datasetType = -1
		platformList = ""
		#1 = By dataset, 2 = By Markers, 3 = By Samples
		extractionType = 1
		exitCode = 0
		#PARSE PARAMETERS/ARGUMENTS
		try:
			opts, args = getopt.getopt(argv, "hc:m:s:d:p:avnM:lD:x:y:b:X:P:t:", ["connectionString=", "markerOutputFile=", "sampleOutputFile=", "datasetId=", "projectOutputFile=", "all", "verbose", "namesOnly", "map=", "includeChrLen", "displayMap=", "markerList=", "sampleList=", "mapsetOutputFile=", "extractByMarkers", "markerNames=", "platformList=", "datasetType=", "extractByDataset"])
			#print (opts, args)
			if len(args) < 2 and len(opts) < 2:
				printUsageHelp(2)
		except getopt.GetoptError:
			printUsageHelp(9)
		for opt, arg in opts:
			if opt == '-h':
				printUsageHelp(1)
			elif opt in ("-c", "--connectionString"):
				connectionStr = arg
			elif opt in ("-m", "--markerOutputFile"):
				markerOutputFile = arg
			elif opt in ("-s", "--sampleOutputFile"):
				sampleOutputFile = arg
			elif opt in ("-d", "--datasetId"):
				datasetId = arg
			elif opt in ("-p", "--projectOutputFile"):
				projectOutputFile = arg
			elif opt in ("-a", "--all"):
				allMeta = True
			elif opt in ("-v", "--verbose"):
				verbose = True
			elif opt in ("-n", "--namesOnly"):
				namesOnly = True
			elif opt in ("-M", "--map"):
				mapId = arg
			elif opt in ("-l", "--includeChrLen"):
				includeChrLen = True
			elif opt in ("-D", "--displayMap"):
				displayMap = arg
			elif opt in ("-x", "--markerList"):
				markerListFile = arg
			elif opt in ("-y", "--sampleList"):
				sampleListFile = arg
			elif opt in ("-b", "--mapsetOutputFile"):
				mapsetOutputFile = arg
			elif opt in ("--extractByMarkers"):
				extractionType = 2
			elif opt in ("--extractByDataset"):
				extractionType = 1
			elif opt in ("-X", "--markerNames"):
				markerNamesFile = arg
			elif opt in ("-P","--platformList"):
				platformList = arg
			elif opt in ("t","--datasetType"):
				datasetType = arg

		#VALIDATIONS
		if connectionStr == "" or markerOutputFile == "" or sampleOutputFile == "" or projectOutputFile == "":
			MDEUtility.printError("Invalid usage. All of the following parameters are required: connectionStr, markerOutputFile, sampleOutputFile, and projectOutputFile.")
			printUsageHelp(2)
		if extractionType == 1:
			if datasetId == -1:
				MDEUtility.printError("Invalid usage. Extraction by dataset requires a dataset ID.")
				printUsageHelp(6)
		elif extractionType == 2:
			if datasetType == -1 or (markerNamesFile == "" and platformList == ""):
				MDEUtility.printError("Invalid usage. Extraction by marker list requires a dataset type and at least one of: markerNamesFile and platformList.")
				printUsageHelp(6)

		if verbose:
			print("Opts: ", opts)
		markerList = []
		sampleList = []
		markerNames = []

		#PREPARE PARAMETERS
		#convert file contents to lists
		if markerListFile != "":
				markerList = [line.strip() for line in open(markerListFile, 'r')]
		if sampleListFile != "":
				sampleList = [line.strip() for line in open(sampleListFile, 'r')]
		if markerNamesFile != "":
				markerNames = [line.strip() for line in open(markerNamesFile, 'r')]

		rn = False
		if datasetId.isdigit() or markerList or sampleList:
			if connectionStr != "" and markerOutputFile != "":
				try:
					#if verbose:
					#	print("Generating marker metadata file...")
					extract_marker_metadata.main(verbose, connectionStr, datasetId, markerOutputFile, allMeta, namesOnly, mapId, includeChrLen, displayMap, markerList, sampleList, mapsetOutputFile)
				except Exception as e1:
					MDEUtility.printError("Extraction of marker metadata failed. Error: %s" % (str(e1)))
					exitCode = 3
				rn = True
			if connectionStr != "" and sampleOutputFile != "":
				try:
					#if verbose:
					#	print("Generating sample metadata file...")
					extract_sample_metadata.main(verbose, connectionStr, datasetId, sampleOutputFile, allMeta, namesOnly, markerList, sampleList)
				except Exception as e:
					MDEUtility.printError("Extraction of sample metadata failed. Error: %s" % str(e))
					exitCode = 4
				rn = True
			if connectionStr != "" and projectOutputFile != "":
				try:
					#project metadata is only relevant to extraction by datasetID
					if not markerList and not sampleList:
						if verbose:
							print("Generating project metadata file...")
						extract_project_metadata.main(verbose, connectionStr, datasetId, projectOutputFile, allMeta)
				except Exception as e:
					MDEUtility.printError("Error: %s" % str(e))
					exitCode = 5
				rn = True
			if not rn:
				print("At least one of -m, -s, or -p is required for the extractor to run.")
				printUsageHelp(2)
		else:
			MDEUtility.printError("At least one of these is required: a valid dataset_id, a markerID file, or a dnarunID file.")
			exitCode = 5
		sys.exit(exitCode)
		#cleanup

def printUsageHelp(eCode):
	print ("gobii_mde.py -c <connectionString> -m <markerOutputFile> -s <sampleOutputFile> -p <projectOutputFile> -d <dataset_id> -M <mapset_id> -D <mapset_id> for Display> -a -v -n")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-m or --markerOutputFile = The marker metadata output file. This should be an absolute path.")
	print ("\t-s or --sampleOutputFile = The sample metadata output file. This should be an absolute path.")
	print ("\t-b or --mapsetOutputFile = The mapset metadata output file. This should be an absolute path.")
	print ("\t-p or --projectOutputFile = The project metadata output file. This should be an absolute path.")
	print ("\t-d or --datasetId = The dataset ID of which marker metadata will be extracted from. This should be a valid integer ID.")
	print ("\t-a or --all = [OBSOLETE] Currently the 'all' metadata is actually less columns than the default. So don't use this for now. We may offer a more verbose output than the default in the future.")
	print ("\t-v or --verbose = Print the status of the MDE in more detail.")
	print ("\t-n or --namesOnly = [OBSOLETE] This was originally requested to link postgres and monet. But this is not being used and the business logic of the MDEs changed significantly, leaving this behind.")
	print ("\t-M or --map = This FILTERS the result by mapset, ie. get only the markers in the specified mapset. This is useful if a dataset contains markers that belongs to multiple maps.")
	print ("\t-l or --includeChrLen = Generates a file that lists all the chromosomes (or any linkage groups) that appear on the markers list, along with their lengths. Filename is the same as the marker file but appended with .chr.")
	print ("\t-D or --displayMap = This creates two files: one with the marker metadata appended with the map data of the selected mapset (marker_filename.ext) and a mapset metadata file. The mapset metadata filename is fetched from the value passed to  the -b (--mapsetOutputFile) parameter.")
	print ("\t-x or --markerList = Supplies the file containing a list of marker_ids, newline-delimited. Setting this instructs the MDE to do extraction by marker list.")
	print ("\t-y or --sampleList = Supplies the file containing a list of dnarun_ids, newline-delimited. Setting this instructs the MDE to do extraction by dnarun list.")
	print ("\t-X or --markerNames = Supplies the file containing a list of marker names, newline-delimited. Setting this instructs the MDE to do extraction by marker list.")
	sys.exit(eCode)

if __name__ == "__main__":
	main(sys.argv[1:])

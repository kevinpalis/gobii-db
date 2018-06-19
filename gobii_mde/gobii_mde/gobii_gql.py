#!/usr/bin/env python
'''
	This module will support the UI's FlexQuery functionality. It also functions independently if needed.
	This is basically an abstraction library to support graph queries on our relational database -- a unique
	requirement since we are storing entities on varying storage formats: ie. standard table.column representation,
	key-value-pairs on jsonb, categories or types as a subset of the CV table, HDF5 indices as jsonb, etc.
	The following features are supported:
		1. Extraction by Markers
		2. Extraction by Samples
		3. Extraction by Markers AND Samples

	Exit Codes:TBD
'''
from __future__ import print_function
import sys
import getopt
import extract_marker_metadata
import extract_sample_metadata
import extract_project_metadata
from util.mde_utility import MDEUtility

def main(argv):
		#TODO: Create a constant class when there's time, probably post-V1
		EXTRACTION_TYPES = [1, 2, 3]
		SAMPLE_TYPES = [1, 2, 3]

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
		sampleNamesFile = ""
		datasetType = -1
		platformList = []
		piId = -1
		projectId = -1
		markerGroupList = ""
		#1 = By dataset, 2 = By Markers, 3 = By Samples
		extractionType = -1
		#1 = Germplasm Names, 2 = External Codes, 3 = DnaSample Names
		sampleType = -1
		exitCode = 0
		#PARSE PARAMETERS/ARGUMENTS
		try:
			opts, args = getopt.getopt(argv, "hc:m:s:d:p:avnM:lD:x:y:b:X:P:t:Y:G:", ["connectionString=", "markerOutputFile=", "sampleOutputFile=", "datasetId=", "projectOutputFile=", "all", "verbose", "namesOnly", "map=", "includeChrLen", "displayMap=", "markerList=", "sampleList=", "mapsetOutputFile=", "extractByMarkers", "markerNames=", "platformList=", "datasetType=", "extractByDataset", "piId=", "projectId=", "sampleType=", "sampleNames=", "extractBySamples", "markerGroupList="])
			#print (opts, args)
			if len(args) < 2 and len(opts) < 2:
				printUsageHelp(2)
		except getopt.GetoptError as e:
			MDEUtility.printError("Error parsing parameters: %s" % str(e))
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
			elif opt in ("--extractBySamples"):
				extractionType = 3
			elif opt in ("--extractByMarkers"):
				extractionType = 2
			elif opt in ("--extractByDataset"):
				extractionType = 1
			elif opt in ("-X", "--markerNames"):
				markerNamesFile = arg
			elif opt in ("-P", "--platformList"):
				try:
					platformList = arg.split(",")
				except Exception as e:
					MDEUtility.printError("Invalid platform list format. Only comma-delimited ID list is accepted. Error: %s" % str(e))
					exitCode = 6
					sys.exit(exitCode)
			elif opt in ("t", "--datasetType"):
				datasetType = arg
			elif opt in ("--piId"):
				piId = arg
			elif opt in ("--projectId"):
				projectId = arg
			elif opt in ("--sampleType"):
				sampleType = int(arg)
			elif opt in ("-Y", "--sampleNames"):
				sampleNamesFile = arg
			elif opt in ("-G", "--markerGroupList"):
				try:
					markerGroupList = arg.split(",")
				except Exception as e:
					MDEUtility.printError("Invalid marker group format. Only comma-delimited ID list is accepted. Error: %s" % str(e))
					exitCode = 6
					sys.exit(exitCode)

		#VALIDATIONS
		if connectionStr == "" or markerOutputFile == "" or sampleOutputFile == "":
			MDEUtility.printError("Invalid usage. All of the following parameters are required: connectionStr, markerOutputFile, and sampleOutputFile.")
			printUsageHelp(2)
		if extractionType not in EXTRACTION_TYPES:
			MDEUtility.printError("Invalid usage. Invalid extraction type.")
			printUsageHelp(2)
		if extractionType == 1:
			if datasetId < 1:
				MDEUtility.printError("Invalid usage. Extraction by dataset requires a dataset ID.")
				printUsageHelp(6)
		elif extractionType == 2:
			if markerNamesFile == "" and not platformList and not markerGroupList:
				MDEUtility.printError("Invalid usage. Extraction by marker list requires at least one of: markerNamesFile, platformList, or markerGroupList.")
				printUsageHelp(6)
		elif extractionType == 3:
			if datasetType < 1:
				MDEUtility.printError("Invalid usage. Extraction by samples list requires a dataset type.")
				printUsageHelp(8)
			if piId < 1 and projectId < 1 and sampleNamesFile == "":
				MDEUtility.printError("Invalid usage. Extraction by samples list requires at least one of the following: PI, Project, Samples List.")
				printUsageHelp(8)
			if sampleNamesFile != "" and sampleType not in SAMPLE_TYPES:
				MDEUtility.printError("Invalid usage. Providing a sample names list requires a sample type: 1 = Germplasm Names, 2 = External Codes, 3 = DnaSample Names.")
				printUsageHelp(8)
		if verbose:
			print("Opts: ", opts)
		markerList = []
		sampleList = []
		markerNames = []
		sampleNames = []
		#PREPARE PARAMETERS
		#convert file contents to lists
		if markerListFile != "":
				markerList = [line.strip() for line in open(markerListFile, 'r')]
		if sampleListFile != "":
				sampleList = [line.strip() for line in open(sampleListFile, 'r')]
		if markerNamesFile != "":
				markerNames = [line.strip() for line in open(markerNamesFile, 'r')]
		if sampleNamesFile != "":
				sampleNames = [line.strip() for line in open(sampleNamesFile, 'r')]

		#Do the Dew
		#rn = False
		#if connectionStr != "" and markerOutputFile != "":
		try:
			#if verbose:
			#	print("Generating marker metadata file...")
			mFile, markerList, sampleList = extract_marker_metadata.main(verbose, connectionStr, datasetId, markerOutputFile, allMeta, namesOnly, mapId, includeChrLen, displayMap, markerList, sampleList, mapsetOutputFile, extractionType, datasetType, markerNames, platformList, piId, projectId, sampleType, sampleNames, markerGroupList)
			if extractionType == 2 and not markerList:
				MDEUtility.printError("Resulting list of marker IDs is empty. Nothing to extract.")
				sys.exit(7)
		except Exception as e1:
			MDEUtility.printError("Extraction of marker metadata failed. Error: %s" % (str(e1)))
			exitCode = 3
		#rn = True
		#if connectionStr != "" and sampleOutputFile != "":
		try:
			#if verbose:
			#	print("Generating sample metadata file...")
			extract_sample_metadata.main(verbose, connectionStr, datasetId, sampleOutputFile, allMeta, namesOnly, markerList, sampleList, extractionType, datasetType)
		except Exception as e:
			MDEUtility.printError("Extraction of sample metadata failed. Error: %s" % str(e))
			exitCode = 4
		#rn = True
		if projectOutputFile != "":
			try:
				#project metadata is only relevant to extraction by datasetID ---- OR IS IT? GOTTA ASK PEOPLE IF WE WANT THIS FANCY
				if extractionType == 1:
					if verbose:
						print("Generating project metadata file...")
					extract_project_metadata.main(verbose, connectionStr, datasetId, projectOutputFile, allMeta)
			except Exception as e:
				MDEUtility.printError("Error: %s" % str(e))
				exitCode = 5
			#rn = True
		#if not rn:
		#	print("At least one of -m, -s, or -p is required for the extractor to run.")
		#	printUsageHelp(2)

		sys.exit(exitCode)
		#cleanup

def printUsageHelp(eCode):
	print ("python gobii_gql.py -c <connectionString:string> -o <outputFilePath:string> -g <subGraphPath:json> -t <targetVertexName:string> -f <vertexColumnsToFetch:array>")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-o or --outputFilePath = The absolute path of the file where the result of the query will be written to.")
	print ("\t-g or --subGraphPath = This is a JSON string of key-value-pairs of this format: {vertex_name1:[value_id1, value_id2], vertex_name2:[value_id1], ...}. This is basically just a list of vertices to visit but filtered with the listed vertices values (which affects the target vertex' values as well).")
	print ("\t-t or --targetVertexName = The vertex to get the values of. In the context of flexQuery, this is the currently selected filter option.")
	print ("\t-f or --vertexColumnsToFetch = The list of columns of the target vertex to get values of. This is OPTIONAL. If it is not set, the library will just use target vertex.data_loc. For example, if the target vertex is 'project', then this will be just the column 'name', while for vertex 'marker', this will be 'name, dataset_marker_idx'. The columns that will appear on the output file is dependent on this. Just note that the list of columns will always be prepended with 'id' and will come out in the order you specify.")
	print ("\tNOTE: If vertex_type=KVP, vertexColumnsToFetch is irrelevant (and hence, ignored) as there is only one column returnable which will always be called 'value'.")

	sys.exit(eCode)


if __name__ == "__main__":
	main(sys.argv[1:])

#!/usr/bin/env python
'''
	This module will support GDM's FlexQuery functionality. It also functions independently if needed.
	This is basically an abstraction library to support graph queries on our relational database -- a unique
	requirement since we are storing entities on varying storage formats than a typical relational database:
	ie. standard table.column representation, key-value-pairs on jsonb, categories or types as a subset of the
	CV table, HDF5 indices as jsonb, etc.
	The following features are supported:
		1. Extraction by Markers
		2. Extraction by Samples
		3. Extraction by Markers AND Samples

	Exit Codes:TBD

	Sample Usage:
	> python gobii_gql.py -o /temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t experiment -f '["name"]' -v
'''
from __future__ import print_function
import sys
import getopt
import traceback
import json
from util.mde_utility import MDEUtility
from util.gql_utility import ReturnCodes
from util.gql_utility import GQLException

def main(argv):
		#TODO: Create a constant class when there's time, probably post-V1
		# EXTRACTION_TYPES = [1, 2, 3]
		# SAMPLE_TYPES = [1, 2, 3]

		verbose = False
		connectionStr = ""
		outputFilePath = ""
		subGraphPath = ""
		targetVertexName = ""
		vertexColumnsToFetch = ""
		exitCode = ReturnCodes.SUCCESS

		#PARSE PARAMETERS/ARGUMENTS
		try:
			opts, args = getopt.getopt(argv, "hc:o:g:t:f:v", ["connectionString=", "outputFilePath=", "subGraphPath=", "targetVertexName=", "vertexColumnsToFetch=", "verbose"])
			#print (opts, args)
			if len(args) < 1 and len(opts) < 1:
				printUsageHelp(ReturnCodes.SUCCESS)
		except getopt.GetoptError:
			# print ("OptError: %s" % (str(e1)))
			exitWithException(ReturnCodes.INVALID_OPTIONS)
		for opt, arg in opts:
			if opt == '-h':
				printUsageHelp(ReturnCodes.SUCCESS)
			elif opt in ("-c", "--connectionString"):
				connectionStr = arg
			elif opt in ("-o", "--outputFilePath"):
				outputFilePath = arg
			elif opt in ("-g", "--subGraphPath"):
				subGraphPath = arg
			elif opt in ("-t", "--targetVertexName"):
				targetVertexName = arg
			elif opt in ("-f", "--vertexColumnsToFetch"):
				vertexColumnsToFetch = arg
			elif opt in ("-v", "--verbose"):
				verbose = True
			# elif opt in ("-P", "--platformList"):
			# 	try:
			# 		platformList = arg.split(",")
			# 	except Exception as e:
			# 		MDEUtility.printError("Invalid platform list format. Only comma-delimited ID list is accepted. Error: %s" % str(e))
			# 		exitCode = 6
			# 		sys.exit(exitCode)

		#VALIDATIONS
		if len(args) < 4 and len(opts) < 4:
				exitWithException(ReturnCodes.INCOMPLETE_PARAMETERS)
		if verbose:
			print ("Opts: ", opts)

		try:
			subGraphPathJson = json.loads(subGraphPath)
			if verbose:
				for key, value in subGraphPathJson.iteritems():
					print ("Visiting vertex %s with filter IDs %s" % (key, value))
					for filterId in value:
						print ("Filtering by ID=%d" % filterId)
		except Exception as e:
			print ("Exception occured while parsing subGraphPath: %s" % e.message)
			exitWithException(ReturnCodes.ERROR_PARSING_JSON)

		try:
			vertexColumnsToFetchJson = json.loads(vertexColumnsToFetch)
			if verbose:
				for col in vertexColumnsToFetchJson:
					print ("Fetching columns %s" % col)
		except Exception as e:
			traceback.print_exc()
			print ("Exception occured while parsing vertexColumnsToFetch: %s" % e.message)
			exitWithException(ReturnCodes.ERROR_PARSING_JSON)

		# markerList = []
		# sampleList = []
		# markerNames = []
		# sampleNames = []

		#PREPARE PARAMETERS
		#convert file contents to lists
		# if markerListFile != "":
		# 		markerList = [line.strip() for line in open(markerListFile, 'r')]
		# if sampleListFile != "":
		# 		sampleList = [line.strip() for line in open(sampleListFile, 'r')]
		# if markerNamesFile != "":
		# 		markerNames = [line.strip() for line in open(markerNamesFile, 'r')]
		# if sampleNamesFile != "":
		# 		sampleNames = [line.strip() for line in open(sampleNamesFile, 'r')]

		#Do the Dew
		#rn = False
		#if connectionStr != "" and markerOutputFile != "":
		# try:
		# 	mFile, markerList, sampleList = extract_marker_metadata.main(verbose, connectionStr, datasetId, markerOutputFile, allMeta, namesOnly, mapId, includeChrLen, displayMap, markerList, sampleList, mapsetOutputFile, extractionType, datasetType, markerNames, platformList, piId, projectId, sampleType, sampleNames, markerGroupList)
		# 	if extractionType == 2 and not markerList:
		# 		MDEUtility.printError("Resulting list of marker IDs is empty. Nothing to extract.")
		# 		sys.exit(7)
		# except Exception as e1:
		# 	MDEUtility.printError("Extraction of marker metadata failed. Error: %s" % (str(e1)))
		# 	exitCode = 3
		#rn = True
		#if connectionStr != "" and sampleOutputFile != "":
		# try:
		# 	extract_sample_metadata.main(verbose, connectionStr, datasetId, sampleOutputFile, allMeta, namesOnly, markerList, sampleList, extractionType, datasetType)
		# except Exception as e:
		# 	MDEUtility.printError("Extraction of sample metadata failed. Error: %s" % str(e))
		# 	exitCode = 4
		#rn = True
		# if projectOutputFile != "":
		# 	try:
		# 		if extractionType == 1:
		# 			if verbose:
		# 				print("Generating project metadata file...")
		# 			extract_project_metadata.main(verbose, connectionStr, datasetId, projectOutputFile, allMeta)
		# 	except Exception as e:
		# 		MDEUtility.printError("Error: %s" % str(e))
		# 		exitCode = 5
		#if not rn:
		#	print("At least one of -m, -s, or -p is required for the extractor to run.")
		#	printUsageHelp(2)

		sys.exit(exitCode)
		#cleanup

def printUsageHelp(eCode):
	print (eCode)
	print ("python gobii_gql.py -c <connectionString:string> -o <outputFilePath:string> -g <subGraphPath:json> -t <targetVertexName:string> -f <vertexColumnsToFetch:array>")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-o or --outputFilePath = The absolute path of the file where the result of the query will be written to.")
	print ("\t-g or --subGraphPath = This is a JSON string of key-value-pairs of this format: {vertex_name1:[value_id1, value_id2], vertex_name2:[value_id1], ...}. This is basically just a list of vertices to visit but filtered with the listed vertices values (which affects the target vertex' values as well).")
	print ("\t-t or --targetVertexName = The vertex to get the values of. In the context of flexQuery, this is the currently selected filter option.")
	print ("\t-f or --vertexColumnsToFetch = The list of columns of the target vertex to get values of. This is OPTIONAL. If it is not set, the library will just use target vertex.data_loc. For example, if the target vertex is 'project', then this will be just the column 'name', while for vertex 'marker', this will be 'name, dataset_marker_idx'. The columns that will appear on the output file is dependent on this. Just note that the list of columns will always be prepended with 'id' and will come out in the order you specify.")
	print ("\t-v or --verbose = Print the status of GQL execution in more detail. Use only for debugging as this will slow down most of the library's queries.")
	print ("\tNOTE: If vertex_type=KVP, vertexColumnsToFetch is irrelevant (and hence, ignored) as there is only one column returnable which will always be called 'value'.")
	if eCode == ReturnCodes.SUCCESS:
		sys.exit(eCode)
	try:
		raise GQLException(eCode)
	except GQLException as e1:
		print (e1.message)
		traceback.print_exc()
		sys.exit(eCode)

def exitWithException(eCode):
	try:
		raise GQLException(eCode)
	except GQLException as e1:
		print (e1.message)
		traceback.print_exc()
		sys.exit(eCode)


if __name__ == "__main__":
	main(sys.argv[1:])

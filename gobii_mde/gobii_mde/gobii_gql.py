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

	* Entry vertices:
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t trial_name -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t germplasm_subspecies -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t dataset -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t marker_linkage_group -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t reference_sample -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t project -f '["name"]' -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t sampling_date -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t germplasm_type -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t dataset_type -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t analysis_type -v -d

	* Limit Tests:
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t germplasm_subspecies -v -d -u -l 10
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d -l 10

	With Subgraphs/Vertices-to-visit:
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /temp/filter2.out -g '{"principal_investigator":[67,69,70]}' -t project -f '["name"]' -v
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t division -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /temp/filter3b.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t experiment -f '["name"]' -v
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /temp/filter4.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "division":[25,30]}' -t experiment -f '["name"]' -v
'''
from __future__ import print_function
import sys
import getopt
import traceback
import json
from util.gql_utility import ReturnCodes
from util.gql_utility import GQLException
from db.graph_query_manager import GraphQueryManager

def main(argv):
		verbose = False
		debug = False
		isKvpVertex = False
		isDefaultDataLoc = False
		isUnique = False
		connectionStr = ""
		outputFilePath = ""
		subGraphPath = ""
		targetVertexName = ""
		vertexColumnsToFetch = ""
		limit = ""
		vertexTypes = {}
		exitCode = ReturnCodes.SUCCESS

		####################################################
		# START: GET PARAMETERS/ARGUMENTS
		####################################################
		try:
			opts, args = getopt.getopt(argv, "hc:o:g:t:f:l:uvd", ["connectionString=", "outputFilePath=", "subGraphPath=", "targetVertexName=", "vertexColumnsToFetch=", "limit=", "unique", "verbose", "debug"])
			#print (opts, args)
			# No arguments supplied, show help
			if len(args) < 2 and len(opts) < 2:
				printUsageHelp(ReturnCodes.SUCCESS)
		except getopt.GetoptError:
			# print ("OptError: %s" % (str(e1)))
			exitWithException(ReturnCodes.INVALID_OPTIONS, None)
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
			elif opt in ("-l", "--limit"):
				limit = arg
			elif opt in ("-u", "--unique"):
				isUnique = True
			elif opt in ("-v", "--verbose"):
				verbose = True
			elif opt in ("-d", "--debug"):
				debug = True

		####################################################
		# END: GET PARAMETERS/ARGUMENTS
		# START: INITIAL VALIDATIONS AND PARAMETERS PARSING
		####################################################
		#initialize database connection
		gqlMgr = GraphQueryManager(connectionStr, debug)
		if len(args) < 3 and len(opts) < 3:
				exitWithException(ReturnCodes.INCOMPLETE_PARAMETERS, gqlMgr)
		if verbose:
			print ("Opts: ", opts)
		if outputFilePath == "":
			exitWithException(ReturnCodes.NO_OUTPUT_PATH, gqlMgr)
		if subGraphPath == "":
			if verbose:
				print ("No vertices to visit. Proceeding as an entry vertex call.")
		else:
			try:
				subGraphPathJson = json.loads(subGraphPath)
				if debug:
					for key, value in subGraphPathJson.iteritems():
						print ("Visiting vertex %s with filter IDs %s" % (key, value))
						for filterId in value:
							print ("Filtering by ID=%d" % filterId)
			except Exception as e:
				print ("Exception occured while parsing subGraphPath: %s" % e.message)
				exitWithException(ReturnCodes.ERROR_PARSING_JSON, gqlMgr)

		if vertexColumnsToFetch == "":
			isDefaultDataLoc = True
			if verbose:
				print ("No columns to fetch specified - will default to vertex.data_loc.")
		else:
			try:
				vertexColumnsToFetchJson = json.loads(vertexColumnsToFetch)
				if debug:
					for col in vertexColumnsToFetchJson:
						print ("Fetching column %s" % col)
			except Exception as e:
				traceback.print_exc()
				print ("Exception occured while parsing vertexColumnsToFetch: %s" % e.message)
				exitWithException(ReturnCodes.ERROR_PARSING_JSON, gqlMgr)

		####################################################
		# END: INITIAL VALIDATIONS AND PARAMETERS PARSING
		# START: PREPARE DATABASE VARIABLES AND PARAMETERS
		####################################################
		#initialize vertex types
		vertexTypes['standard'] = gqlMgr.getCvId('standard', 'vertex_type')['cvid']
		vertexTypes['standard_subset'] = gqlMgr.getCvId('standard_subset', 'vertex_type')['cvid']
		vertexTypes['cv_subset'] = gqlMgr.getCvId('cv_subset', 'vertex_type')['cvid']
		vertexTypes['key_value_pair'] = gqlMgr.getCvId('key_value_pair', 'vertex_type')['cvid']

		targetVertexInfo = gqlMgr.getVertex(targetVertexName)
		if debug:
			# print (vertexTypes)
			print ("targetVertexInfo: %s" % targetVertexInfo)
		tvAlias = targetVertexInfo['alias']
		tvTableName = targetVertexInfo['table_name']
		tvCriterion = targetVertexInfo['criterion']
		tvType = targetVertexInfo['type_id']
		tvId = targetVertexInfo['vertex_id']
		# print ("tvType=%s, vertex_type.type_id=%s" % (type(tvType), type(vertexTypes['key_value_pair'])))
		if tvType == vertexTypes['key_value_pair']:
			isKvpVertex = True
		if isKvpVertex:
			# for KVP vertices, we ignore the vertexColumnsToFetch parameter
			if verbose:
				print ("Since this is a KVP vertex, vertexColumnsToFetch parameter will be ignored.")
			tvDataLoc = targetVertexInfo['data_loc']
		else:
			if isDefaultDataLoc:
				# parameter vertexColumnsToFetch wasn't set, defaulting to vertex.data_loc
				tvDataLoc = targetVertexInfo['data_loc']
			else:
				tvDataLoc = vertexColumnsToFetchJson
		tvIsEntry = targetVertexInfo['is_entry']

		#VALIDATIONS OF PARSED PARAMETERS
		if not tvIsEntry and subGraphPath == "":
			if verbose:
				print ("This is not an entry vertex, so a subgraph is required.")
			exitWithException(ReturnCodes.NOT_ENTRY_VERTEX, gqlMgr)
		####################################################
		# END: PREPARE DATABASE VARIABLES AND PARAMS
		####################################################

		# if res is None:
		# 	MDEUtility.printError('Invalid marker group passed.')
		# 	sys.exit(13)
		# markerListFromGrp = [str(i[0]) for i in res]
		#convert file contents to lists
		# if markerListFile != "":
		# 		markerList = [line.strip() for line in open(markerListFile, 'r')]
		# if sampleListFile != "":
		# 		sampleList = [line.strip() for line in open(sampleListFile, 'r')]
		# if markerNamesFile != "":
		# 		markerNames = [line.strip() for line in open(markerNamesFile, 'r')]
		# if sampleNamesFile != "":
		# 		sampleNames = [line.strip() for line in open(sampleNamesFile, 'r')]

		####################################################
		# START: CREATE THE DYNAMIC QUERY
		####################################################
		#Do the Dew
		selectStr = "select "
		fromStr = "from"
		conditionStr = "where"
		dynamicQuery = ""

		#Case when this is an entry vertex
		if tvIsEntry and subGraphPath == "":
			if verbose:
				print ("Building dynamic query for an entry vertex.")
			if isUnique:
				selectStr += "distinct "
			else:
				selectStr += tvAlias+"."+tvTableName+"_id as id"
			print ("dataloc: %s" % tvDataLoc)
			print ("type: %s" % type(tvDataLoc))

			if isKvpVertex and isUnique:
				selectStr += tvAlias+"."+tvDataLoc+" as "+targetVertexName
			elif isKvpVertex and not isUnique:
				selectStr += ", "+tvAlias+"."+tvDataLoc+" as "+targetVertexName
			elif not isKvpVertex and not isUnique and isDefaultDataLoc:
				selectStr += ", " + ",".join([tvAlias+"."+col.strip() for col in tvDataLoc.split(',')])
				if verbose:
					print ("@isDefaultDataLoc and not unique: %s" % selectStr)
			elif not isKvpVertex and isUnique and isDefaultDataLoc:
				selectStr += ",".join([tvAlias+"."+col.strip() for col in tvDataLoc.split(',')])
				print ("@isDefaultDataLoc and unique: %s" % selectStr)
			else:
				for col in tvDataLoc:
					if verbose:
						print ("Adding column %s to selectStr." % col)
					selectStr += ", "+tvAlias+"."+col
			#TODO: Handle case when data_loc is used instead (prepend with alias)
			fromStr += " "+tvTableName+" as "+tvAlias
			if tvCriterion is not None:
				conditionStr += " "+tvCriterion
				dynamicQuery = selectStr+" "+fromStr+" "+conditionStr
			else:
				dynamicQuery = selectStr+" "+fromStr

			#apply the limit if set
			if limit.isdigit():
				if verbose:
					print ("Limit is set to %s." % limit)
				dynamicQuery += " limit "+limit
		if debug:
			print ("Generated dynamic query: \n%s" % dynamicQuery)

		if verbose:
			print("Creating main output file: %s" % outputFilePath)
		try:
			gqlMgr.outputQueryToFile(outputFilePath, dynamicQuery)
		except Exception as e:
			print("Exception caught: %s" % e.message)
			exitWithException(ReturnCodes.OUTPUT_FILE_CREATION_FAILED, gqlMgr)

		####################################################
		# START: CLEANUP
		####################################################
		gqlMgr.commitTransaction()
		gqlMgr.closeConnection()
		sys.exit(exitCode)
		#cleanup

def printUsageHelp(eCode):
	print (eCode)
	print ("python gobii_gql.py -c <connectionString:string> -o <outputFilePath:string> -g <subGraphPath:json> -t <targetVertexName:string> -f <vertexColumnsToFetch:array>")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-o or --outputFilePath = The absolute path of the file where the result of the query will be written to.")
	print ("\t-g or --subGraphPath = (OPTIONAL) This is a JSON string of key-value-pairs of this format: {vertex_name1:[value_id1, value_id2], vertex_name2:[value_id1], ...}. This is basically just a list of vertices to visit but filtered with the listed vertices values (which affects the target vertex' values as well). To fetch the values for an entry vertex, simply don't set this parameter.")
	print ("\t-t or --targetVertexName = The vertex to get the values of. In the context of flexQuery, this is the currently selected filter option.")
	print ("\t-f or --vertexColumnsToFetch = (OPTIONAL) The list of columns of the target vertex to get values of. If it is not set, the library will just use target vertex.data_loc. For example, if the target vertex is 'project', then this will be just the column 'name', while for vertex 'marker', this will be 'name, dataset_marker_idx'. The columns that will appear on the output file is dependent on this. Just note that the list of columns will always be prepended with 'id' (IF the unique flag is not set) and will come out in the order you specify.")
	print ("\t-l or --limit = (OPTIONAL) This will effectively apply a row limit to all query results. Hence, the output files will have at most limit+1 number of rows.")
	print ("\t-u or --unique = (OPTIONAL) This will add a 'distinct' keyword to the dynamic SQL - useful for KVP vertices (props fields).")
	print ("\t-v or --verbose = (OPTIONAL) Print the status of GQL execution in more detail. Use only for debugging as this will slow down most of the library's queries.")
	print ("\t-d or --debug = (OPTIONAL) Turns the debug mode on. The script will run significantly slower but will allow for very fine-tuned debugging.")
	print ("\tNOTE: If vertex_type=KVP, vertexColumnsToFetch is irrelevant (and hence, ignored) as there is only one column returnable which will always be called 'value'.")
	if eCode == ReturnCodes.SUCCESS:
		sys.exit(eCode)
	try:
		raise GQLException(eCode)
	except GQLException as e1:
		print (e1.message)
		traceback.print_exc()
		sys.exit(eCode)

def exitWithException(eCode, gqlMgr):
	try:
		if gqlMgr is not None:
			gqlMgr.commitTransaction()
			gqlMgr.closeConnection()
		raise GQLException(eCode)
	except GQLException as e1:
		print (e1.message)
		traceback.print_exc()
		sys.exit(eCode)


if __name__ == "__main__":
	main(sys.argv[1:])

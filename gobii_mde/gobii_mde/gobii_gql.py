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
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter2.out -g '{"principal_investigator":[67,69,70]}' -t project -f '["name"]' -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t division -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t experiment -f '["name"]' -v
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "division":[25,30]}' -t experiment -f '["name"]' -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t dataset -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "dataset":[1,2,3,4,5]}' -t marker -v -d
'''
from __future__ import print_function
import sys
import getopt
import traceback
import json
import itertools
from collections import OrderedDict
from util.gql_utility import ReturnCodes
from util.gql_utility import GQLException
from db.graph_query_manager import GraphQueryManager
from collections import namedtuple

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
		tableDict = {}
		vertices = OrderedDict()
		exitCode = ReturnCodes.SUCCESS
		FilteredVertex = namedtuple('FilteredVertex', 'name filter')
		pathStr = ""
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
			#create a dictionary of vertexID:vertexName
			try:
				subGraphPathJson = json.loads(subGraphPath)
				print ("subGraphPathJson: %s" % subGraphPathJson)
				for key, value in subGraphPathJson.iteritems():
					if verbose:
						print ("Building the dictionary entry for vertex %s with filter IDs %s" % (key, value))
					vId = gqlMgr.getVertexId(key)['vertex_id']
					vertices[vId] = FilteredVertex(key, value)
					# for filterId in value:
					# 	print ("Filtering by ID=%d" % filterId)
				if debug:
					print ("Vertices: %s" % vertices)
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

		#COMPUTE FOR THE ACTUAL PATH
		if subGraphPath != "":
			path = []
			totalVertices = len(vertices)
			print ("totalVertices: %s" % totalVertices)
			if totalVertices == 1:
				pathStr = str(vertices.items()[0][0])
			else:
				for i, j in zip(range(0, totalVertices), range(1, totalVertices)):
					print ("i: %d, j: %d" % (i, j))
					print ("FilteredVertex[%d]: %s" % (i, vertices.items()[i]))
					print ("FilteredVertex[%d]: %s" % (j, vertices.items()[j]))
					pathStr += gqlMgr.getPath(vertices.items()[i][0], vertices.items()[j][0])['path_string']

			if totalVertices > 0:
				#parse the path string to an iterable object, removing empty strings
				tempPath = [col.strip() for col in filter(None, pathStr.split('.'))]
				#remove duplicated adjacent entries
				path = [k for k, g in itertools.groupby(tempPath)]
				lastVertexInPath = path[len(path)-1]
				endPathStr = gqlMgr.getPath(lastVertexInPath, tvId)['path_string']
				print ("path length: %s, path=%s, last element=%s, endPathStr=%s" % (len(path), path, path[len(path)-1], endPathStr))
				#parse the path string to an iterable object, removing empty strings
				endPath = [col.strip() for col in filter(None, endPathStr.split('.'))]
				#remove duplicated adjacent entries
				path = [k for k, g in itertools.groupby(path+endPath)]
				if verbose:
					print ("Derived path: %s" % pathStr)
			# elif totalVertices == 1:
			# 	path.append(str(vertices.keys()[0]))
			else:
				#TODO
				print ("Did not resolve to vertices to visit. Throw an exception here.")
			print ("Path: %s" % path)

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

		#Common parts of the dynamic query between a non-entry and an entry vertex
		#----------------------------
		# Building the select string
		#----------------------------
		if isUnique:
				selectStr += "distinct "
		else:
			selectStr += tvAlias+"."+tvTableName+"_id as id"

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

		#--------------------------------------
		# Case when this is an entry vertex - build the from and where clause strings
		#--------------------------------------
		if tvIsEntry and subGraphPath == "":
			fromStr += " "+tvTableName+" as "+tvAlias
			if verbose:
				print ("Building dynamic query for an entry vertex.")
				print ("dataloc: %s" % tvDataLoc)
				print ("type: %s" % type(tvDataLoc))
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

		#--------------------------------------
		#Case when this is NOT an entry vertex
		#--------------------------------------
		elif subGraphPath != "":
			if verbose:
				print ("Building dynamic query for a vertex with a list of vertices to visit (subGraphPath).")
				print ("dataloc: %s" % tvDataLoc)
				print ("type: %s" % type(tvDataLoc))
			#iterate through the path
			totalVerticesInPath = len(path)
			print ("totalVerticesInPath: %s" % totalVerticesInPath)
			#----------------------------
			# Building the from clause string
			#----------------------------
			for i, j in zip(range(0, totalVerticesInPath), range(1, totalVerticesInPath)):
				print ("i: %d, j: %d" % (i, j))
				print ("path[%d]: %s" % (i, path[i]))
				print ("path[%d]: %s" % (j, path[j]))
				edge = gqlMgr.getEdge(path[i], path[j])
				print ("Current edge: %s" % edge)
				vertexI = gqlMgr.getVertexById(path[i])
				vertexJ = gqlMgr.getVertexById(path[j])
				print ("vertices in edge: %s ||| %s" % (vertexI, vertexJ))
				#BUILD THE TABLE NAMES DICTIONARY (unique list of table names that allows reuse - hence, save query time by avoiding joins)
				#for vertexI
				tableReuseVi = False
				tableReuseVj = False
				if vertexI['table_name'] in tableDict:
					vertexI['alias'] = tableDict[vertexI['table_name']]
					tableReuseVi = True
				else:
					tableDict[vertexI['table_name']] = vertexI['alias']
				#for vertexJ
				if vertexJ['table_name'] in tableDict:
					vertexJ['alias'] = tableDict[vertexJ['table_name']]
					tableReuseVj = True
				else:
					tableDict[vertexJ['table_name']] = vertexJ['alias']
				if debug:
					print ("tableDict: %s" % tableDict)
				if i == 0:
					fromStr += " "+vertexI['table_name']+" as "+vertexI['alias']
				if not tableReuseVj:
					fromStr += " inner join "+vertexJ['table_name']+" as "+vertexJ['alias']
					qualifiedCriterion = ""
					if edge['criterion'] is not None:
						if '=' in edge['criterion']:
							#todo: error checks
							critList = edge['criterion'].split('=')
							critList[0] = vertexI['alias']+"."+critList[0]
							critList[1] = vertexJ['alias']+"."+critList[1]
							qualifiedCriterion = "=".join(critList)
						elif '?' in edge['criterion']:
							critList = edge['criterion'].split('?')
							critList[0] = vertexJ['alias']+"."+critList[0]
							critList[1] = vertexI['alias']+"."+critList[1]
							qualifiedCriterion = "?".join(critList)
					#handle: criterion==null
					fromStr += " on "+qualifiedCriterion
			#Case when the last vertex in the path, aka targetVertex, was tagged to reuse a table in the subpath
			if tableReuseVj:
				selectStr = selectStr.replace(tvAlias+".", vertexJ['alias']+".")
			#----------------------------
			# Building the where clause string
			#----------------------------
			i = 0
			for p in path:
				v = gqlMgr.getVertexById(p)
				print ("Processing condition for vertex %s" % v)
				if v['criterion'] is not None:
					# unfortunately, with the current seed data, this vertex needs to be treated differently
					if v['name'] != 'principal_investigator':
						#if the current vertex was tagged as tableReuse earlier
						if v['table_name'] in tableDict:
							v['alias'] = tableDict[v['table_name']]
						v['criterion'] = v['alias'] + "." + v['criterion']
					if i == 0:
						#TODO: Append alias wherever needed
						conditionStr += " "+v['criterion']
						i += 1
					else:
						conditionStr += " and "+v['criterion']
						i += 1

			for key, value in vertices.items():
				print ("Adding where clause entry for filtered vertex: %s = ( %s : %s )" % (key, value[0], value[1]))
				fv = gqlMgr.getVertexById(key)
				if fv['table_name'] in tableDict:
					fv['alias'] = tableDict[fv['table_name']]
				idCol = fv['alias'] + "." + fv['table_name'] + "_id"
				if i == 0:
					#TODO: Append alias wherever needed
					conditionStr += " " + idCol + " in (" + ",".join(map(str, value[1])) + ")"
					i += 1
				else:
					conditionStr += " and " + idCol + " in (" + ",".join(map(str, value[1])) + ")"
					i += 1
				# gqlMgr.getPath(vertices.items()[i][0], vertices.items()[j][0])['path_string']
			dynamicQuery = selectStr+" "+fromStr+" "+conditionStr
			print ("Generated dynamic query: \n%s" % dynamicQuery)
			exitWithException(ReturnCodes.FEATURE_NOT_IMPLEMENTED, gqlMgr)
		if debug:
			print ("Generated dynamic query: \n%s" % dynamicQuery)

		if verbose:
			print("Creating main output file: %s" % outputFilePath)
		try:
			gqlMgr.outputQueryToFile(outputFilePath, dynamicQuery)
		except Exception as e:
			print("Exception caught: %s" % e)
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

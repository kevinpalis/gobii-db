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


	With Subgraphs/Vertices-to-visit:
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter2.out -g '{"principal_investigator":[67,69,70]}' -t project -f '["name"]' -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t division -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t experiment -f '["name"]' -v
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "division":[25,30]}' -t experiment -f '["name"]' -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t dataset -v -d
	> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "dataset":[1,2,3,4,5]}' -t marker -v -d


	VALID SYNTAX FOR PROP FIELDS FETCHING:
	select * from project p
	where props@>('{"'||getCvId('division', 'project_prop', 1)::text||'":"Sim_division"}')::jsonb;

	Data Structure to store all computed paths and filters:
	allPaths = {vertexId:(vertexName, userFilters, pathToTarget[])}
'''
from __future__ import print_function
import sys
import getopt
import traceback
import json
# import itertools
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
		vertices = OrderedDict()
		exitCode = ReturnCodes.SUCCESS
		# FilteredVertex = namedtuple('FilteredVertex', 'name filter')  # TODO: Get rid of this once the new datastruct is in place
		allPaths = OrderedDict()
		FilteredPath = namedtuple('FilteredPath', 'vertexName userFilters pathToTarget')
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
		#initialize vertex types
		vertexTypes['standard'] = gqlMgr.getCvId('standard', 'vertex_type')['cvid']
		vertexTypes['standard_subset'] = gqlMgr.getCvId('standard_subset', 'vertex_type')['cvid']
		vertexTypes['cv_subset'] = gqlMgr.getCvId('cv_subset', 'vertex_type')['cvid']
		vertexTypes['key_value_pair'] = gqlMgr.getCvId('key_value_pair', 'vertex_type')['cvid']

		if len(args) < 3 and len(opts) < 3:
				exitWithException(ReturnCodes.INCOMPLETE_PARAMETERS, gqlMgr)
		if verbose:
			print ("Opts: ", opts)
		if outputFilePath == "":
			exitWithException(ReturnCodes.NO_OUTPUT_PATH, gqlMgr)

		#------------------------------------------
		# Parse and prep the target vertex info
		#------------------------------------------
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

		targetVertex = gqlMgr.getVertex(targetVertexName)
		if debug:
			# print (vertexTypes)
			print ("targetVertex: %s" % targetVertex)
		tvAlias = targetVertex['alias']
		tvTableName = targetVertex['table_name']
		tvCriterion = targetVertex['criterion']
		tvType = targetVertex['type_id']
		tvId = targetVertex['vertex_id']
		tvIsEntry = targetVertex['is_entry']
		# print ("tvType=%s, vertex_type.type_id=%s" % (type(tvType), type(vertexTypes['key_value_pair'])))
		if tvType == vertexTypes['key_value_pair']:
			isKvpVertex = True
		if isKvpVertex:
			# for KVP vertices, we ignore the vertexColumnsToFetch parameter
			if verbose:
				print ("Since this is a KVP vertex, vertexColumnsToFetch parameter will be ignored.")
			tvDataLoc = targetVertex['data_loc']
		else:
			if isDefaultDataLoc:
				# parameter vertexColumnsToFetch wasn't set, defaulting to vertex.data_loc
				tvDataLoc = targetVertex['data_loc']
			else:
				tvDataLoc = vertexColumnsToFetchJson

		#Validate the target vertex
		if not tvIsEntry and subGraphPath == "":
			if verbose:
				print ("The target vertex is not an entry vertex, hence a subgraph (-g) is required.")
			exitWithException(ReturnCodes.NOT_ENTRY_VERTEX, gqlMgr)

		#Do the Dew
		selectStr = "select "
		fromStr = "from"
		conditionStr = "where"
		dynamicQuery = ""
		#----------------------------------------
		# CASE: ENTRY VERTEX - No subgraph given
		#----------------------------------------
		if subGraphPath == "" and tvIsEntry:
			if verbose:
				print ("No vertices to visit. Proceeding as an entry vertex call.")
				# print ("dataloc: %s" % tvDataLoc)
			selectStr = buildSelectString(isUnique, isKvpVertex, isDefaultDataLoc, targetVertex['alias'], targetVertex['table_name'], tvDataLoc, targetVertex['name'], verbose, debug)
			fromStr += " "+tvTableName+" as "+tvAlias
			# If there is a target vertex criterion, add it to the dynamic query, otherwise, end the sql on the from-clause.
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
		#--------------------------------------------------------------------------------------------------------
		# CASE: WITH SUBGRAPH - FOR ALL V IN SUBGRAPH, COMPUTE THE PATH, THEN BUILD THE DYNAMIC NESTED SQL
		# MAIN DATA STRUCT: allPaths = {vertexId:FilteredPath(vertexName, userFilters, pathToTarget[Vertex()])}
		#--------------------------------------------------------------------------------------------------------
		else:
			try:
				subDynamicQueries = []
				subGraphPathJson = json.loads(subGraphPath)
				# path = []
				totalVertices = len(subGraphPathJson)
				if verbose:
					print ("Total source vertices (subgraph): %s" % totalVertices)
				if debug:
					print ("subGraphPathJson: %s" % subGraphPathJson)
				#----------------------
				# SUBGRAPH LOOP START
				#----------------------
				for vertexName, vertexFilter in subGraphPathJson.iteritems():
					# selectStr = "select "
					# fromStr = "from"
					# conditionStr = "where"
					pathStr = ""
					propConditions = []
					currVertexIsKvp = False
					if verbose:
						print ("Building the dictionary entry for vertex %s with filter IDs %s" % (vertexName, vertexFilter))
					currVertex = gqlMgr.getVertex(vertexName)
					if currVertex['type_id'] == vertexTypes['key_value_pair']:
						#get the kvp vertex's parent vertex (as all kvp vertices are property entities)
						parentVertex = gqlMgr.getVertex(currVertex['table_name'])
						currVertexIsKvp = True
						# vertices[parentVertex['vertex_id']] = FilteredVertex(currVertex['table_name'], '')
						#pathToTarget = [parentVertex['vertex_id']]  # TODO: Check if computing for the path to target in here is doable
						try:
							pathStr += gqlMgr.getPath(parentVertex['vertex_id'], tvId)['path_string']
							#parse the path string to an iterable object, removing empty strings
							pathToTarget = [gqlMgr.getVertexById(col.strip()) for col in filter(None, pathStr.split('.'))]
							#for KVPs, add a special jsonb where clause for each filter
							#as of postgres 9.5, there is no "in" construct for jsonb columns of kvp format
							for fil in vertexFilter:
								propConditionStr = buildPropConditionString(gqlMgr, currVertex['name'], currVertex['table_name']+"_prop", fil, parentVertex['alias'], verbose, debug)
								propConditions.append(propConditionStr)
							if debug:
								print (" pathStr=%s\n pathToTarget=%s" % (pathStr, pathToTarget))
						except Exception as e:
							traceback.print_exc()
							print ("ERROR: No path found from vertex %s to %s. Message: %s" % (parentVertex['vertex_id'], tvId, e.message))
							exitWithException(ReturnCodes.NO_PATH_FOUND, gqlMgr)
						allPaths[currVertex['vertex_id']] = FilteredPath(vertexName, vertexFilter, pathToTarget)
						if debug:
							print ("Added the parent vertex '%s' for the kvp vertex '%s'." % (parentVertex['name'], currVertex['name']))
					else:
						# vertices[currVertex['vertex_id']] = FilteredVertex(key, value)
						# pathToTarget = [currVertex['vertex_id']]  # TODO: Check if computing for the path to target in here is doable
						try:
							pathStr += gqlMgr.getPath(currVertex['vertex_id'], tvId)['path_string']
							#parse the path string to an iterable object, removing empty strings
							pathToTarget = [gqlMgr.getVertexById(col.strip()) for col in filter(None, pathStr.split('.'))]
							#remove duplicated adjacent entries
							# pathToTarget = [k for k, g in itertools.groupby(tempPath)]
							if debug:
								print (" pathStr=%s\n pathToTarget=%s" % (pathStr, pathToTarget))
						except Exception as e:
							print ("ERROR: No path found from vertex %s to %s. Message: %s" % (currVertex['vertex_id'], tvId, e.message))
							exitWithException(ReturnCodes.NO_PATH_FOUND, gqlMgr)
						allPaths[currVertex['vertex_id']] = FilteredPath(vertexName, vertexFilter, pathToTarget)

					selectStr = buildSelectString(isUnique, isKvpVertex, isDefaultDataLoc, targetVertex['alias'], targetVertex['table_name'], tvDataLoc, targetVertex['name'], verbose, debug)
					fromStr, selectStr, tableDict = buildFromString(gqlMgr, pathToTarget, selectStr, tvAlias, verbose, debug)
					conditionStr = buildConditionString(gqlMgr, pathToTarget, tableDict, vertexFilter, currVertex, verbose, debug, currVertexIsKvp)
					for propCond in propConditions:
						if conditionStr == "where":
							conditionStr += " "+propCond
						else:
							conditionStr += " or "+propCond
					subDynamicQuery = selectStr+" "+fromStr+" "+conditionStr
					if debug:
						print ("\nsubDynamicQuery:\n %s\n" % subDynamicQuery)
					subDynamicQueries.append(subDynamicQuery)
				# if debug:
					# print ("allPaths: %s" % allPaths)
				print ("\nsubDynamicQueries: %s" % subDynamicQueries)
				f = 1
				dynamicQuery = "with"
				selectStr = "select f1.*"
				fromStr = "from"
				conditionStr = "where"
				for q in subDynamicQueries:
					# CTE part of the query
					if f == 1:
						dynamicQuery += " f" + str(f) + " as (" + q + ")"
						fromStr += " f" + str(f)
					else:
						dynamicQuery += ", f" + str(f) + " as (" + q + ")"
						if isUnique:
							#case: property field or -u flag set or a kvp
							fromStr += " inner join f" + str(f) + " on f" + str(f-1) + "." + targetVertex['name'] + "=f" + str(f) + "." + targetVertex['name']
						else:
							fromStr += " inner join f" + str(f) + " on f" + str(f-1) + ".id=f" + str(f) + ".id"
					f += 1
				dynamicQuery += " " + selectStr + " " + fromStr
				if verbose:
					print ("Dynamic Query: \n %s" % dynamicQuery)
				exit(1)  # TEMP
			except Exception as e:
				print ("Exception occured while parsing subGraphPath and creating allPaths: %s" % e.message)
				traceback.print_exc()
				exitWithException(ReturnCodes.ERROR_PARSING_JSON, gqlMgr)

		####################################################
		# END: INITIAL VALIDATIONS AND PARAMETERS PARSING
		# START: PREPARE DATABASE VARIABLES AND PARAMETERS
		####################################################
		#COMPUTE FOR THE ACTUAL PATH
		'''if subGraphPath != "":
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
					try:
						pathStr += gqlMgr.getPath(vertices.items()[i][0], vertices.items()[j][0])['path_string']
					except Exception as e:
						print ("ERROR: No path found from vertex %s to %s. Message: %s" % (vertices.items()[i][0], vertices.items()[j][0], e.message))
						exitWithException(ReturnCodes.NO_PATH_FOUND, gqlMgr)
			if totalVertices > 0:
				#parse the path string to an iterable object, removing empty strings
				tempPath = [col.strip() for col in filter(None, pathStr.split('.'))]
				#remove duplicated adjacent entries
				path = [k for k, g in itertools.groupby(tempPath)]
				lastVertexInPath = path[len(path)-1]
				try:
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
				except Exception as e:
					print ("ERROR: No path found from vertex %s to %s. Message: %s" % (lastVertexInPath, tvId, e.message))
					exitWithException(ReturnCodes.NO_PATH_FOUND, gqlMgr)
			else:
				#TODO
				print ("Did not resolve to vertices to visit. Throw an exception here.")
			print ("Path: %s" % path)'''

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
		# selectStr = "select "
		# fromStr = "from"
		# conditionStr = "where"
		# dynamicQuery = ""

		#Common parts of the dynamic query between a non-entry and an entry vertex
		#----------------------------
		# Building the select string
		#----------------------------
		# if isUnique:
		# 		selectStr += "distinct "
		# else:
		# 	selectStr += tvAlias+"."+tvTableName+"_id as id"

		# if isKvpVertex and isUnique:
		# 	selectStr += tvAlias+"."+tvDataLoc+" as "+targetVertexName
		# elif isKvpVertex and not isUnique:
		# 	selectStr += ", "+tvAlias+"."+tvDataLoc+" as "+targetVertexName
		# elif not isKvpVertex and not isUnique and isDefaultDataLoc:
		# 	selectStr += ", " + ",".join([tvAlias+"."+col.strip() for col in tvDataLoc.split(',')])
		# 	if verbose:
		# 		print ("@isDefaultDataLoc and not unique: %s" % selectStr)
		# elif not isKvpVertex and isUnique and isDefaultDataLoc:
		# 	selectStr += ",".join([tvAlias+"."+col.strip() for col in tvDataLoc.split(',')])
		# 	print ("@isDefaultDataLoc and unique: %s" % selectStr)
		# else:
		# 	for col in tvDataLoc:
		# 		if verbose:
		# 			print ("Adding column %s to selectStr." % col)
		# 		selectStr += ", "+tvAlias+"."+col
		#TODO: Handle case when data_loc is used instead (prepend with alias)

		#--------------------------------------
		# Case when this is an entry vertex - build the from and where clause strings
		#--------------------------------------
		# if tvIsEntry and subGraphPath == "":
		# 	fromStr += " "+tvTableName+" as "+tvAlias
		# 	if verbose:
		# 		print ("Building dynamic query for an entry vertex.")
		# 		print ("dataloc: %s" % tvDataLoc)
		# 		print ("type: %s" % type(tvDataLoc))
		# 	if tvCriterion is not None:
		# 		conditionStr += " "+tvCriterion
		# 		dynamicQuery = selectStr+" "+fromStr+" "+conditionStr
		# 	else:
		# 		dynamicQuery = selectStr+" "+fromStr

		# 	#apply the limit if set
		# 	if limit.isdigit():
		# 		if verbose:
		# 			print ("Limit is set to %s." % limit)
		# 		dynamicQuery += " limit "+limit

		#--------------------------------------
		#Case when this is NOT an entry vertex
		#--------------------------------------
		# if subGraphPath != "":
		# 	if verbose:
		# 		print ("Building dynamic query for a vertex with a list of vertices to visit (subGraphPath).")
		# 		print ("dataloc: %s" % tvDataLoc)
		# 		print ("type: %s" % type(tvDataLoc))
		# 	iterate through the path
		# 	totalVerticesInPath = len(path)
		# 	print ("totalVerticesInPath: %s" % totalVerticesInPath)
		# 	#----------------------------
		# 	# Building the from clause string
		# 	#----------------------------
		# 	for i, j in zip(range(0, totalVerticesInPath), range(1, totalVerticesInPath)):
		# 		print ("i: %d, j: %d" % (i, j))
		# 		print ("path[%d]: %s" % (i, path[i]))
		# 		print ("path[%d]: %s" % (j, path[j]))
		# 		edge = gqlMgr.getEdge(path[i], path[j])
		# 		print ("Current edge: %s" % edge)
		# 		vertexI = gqlMgr.getVertexById(path[i])
		# 		vertexJ = gqlMgr.getVertexById(path[j])
		# 		print ("vertices in edge: %s ||| %s" % (vertexI, vertexJ))
		# 		#BUILD THE TABLE NAMES DICTIONARY (unique list of table names that allows reuse - hence, save query time by avoiding joins)
		# 		#for vertexI
		# 		tableReuseVi = False
		# 		tableReuseVj = False
		# 		if vertexI['table_name'] in tableDict:
		# 			vertexI['alias'] = tableDict[vertexI['table_name']]
		# 			tableReuseVi = True
		# 		else:
		# 			tableDict[vertexI['table_name']] = vertexI['alias']
		# 		#for vertexJ
		# 		if vertexJ['table_name'] in tableDict:
		# 			vertexJ['alias'] = tableDict[vertexJ['table_name']]
		# 			tableReuseVj = True
		# 		else:
		# 			tableDict[vertexJ['table_name']] = vertexJ['alias']
		# 		if debug:
		# 			print ("tableDict: %s" % tableDict)
		# 		if i == 0:
		# 			fromStr += " "+vertexI['table_name']+" as "+vertexI['alias']
		# 		if not tableReuseVj:
		# 			fromStr += " inner join "+vertexJ['table_name']+" as "+vertexJ['alias']
		# 			qualifiedCriterion = ""
		# 			if edge['criterion'] is not None:
		# 				if '=' in edge['criterion']:
		# 					#todo: error checks
		# 					critList = edge['criterion'].split('=')
		# 					critList[0] = vertexI['alias']+"."+critList[0]
		# 					critList[1] = vertexJ['alias']+"."+critList[1]
		# 					qualifiedCriterion = "=".join(critList)
		# 				elif '?' in edge['criterion']:
		# 					critList = edge['criterion'].split('?')
		# 					critList[0] = vertexJ['alias']+"."+critList[0]
		# 					critList[1] = vertexI['alias']+"."+critList[1]
		# 					qualifiedCriterion = "?".join(critList)
		# 			#handle: criterion==null
		# 			fromStr += " on "+qualifiedCriterion
		# 	#Case when the last vertex in the path, aka targetVertex, was tagged to reuse a table in the subpath
		# 	if tableReuseVj:
		# 		selectStr = selectStr.replace(tvAlias+".", vertexJ['alias']+".")
		# 	----------------------------
		# 	Building the where clause string
		# 	----------------------------
		# 	i = 0
		# 	for p in path:
		# 		v = gqlMgr.getVertexById(p)
		# 		print ("Processing condition for vertex %s" % v)
		# 		if v['criterion'] is not None:
		# 			# unfortunately, with the current seed data, this vertex needs to be treated differently
		# 			if v['name'] != 'principal_investigator':
		# 				#if the current vertex was tagged as tableReuse earlier
		# 				if v['table_name'] in tableDict:
		# 					v['alias'] = tableDict[v['table_name']]
		# 				v['criterion'] = v['alias'] + "." + v['criterion']
		# 			if i == 0:
		# 				#TODO: Append alias wherever needed
		# 				conditionStr += " "+v['criterion']
		# 				i += 1
		# 			else:
		# 				conditionStr += " and "+v['criterion']
		# 				i += 1

		# 	for key, value in vertices.items():
		# 		print ("Adding where clause entry for filtered vertex: %s = ( %s : %s )" % (key, value[0], value[1]))
		# 		fv = gqlMgr.getVertexById(key)
		# 		if fv['table_name'] in tableDict:
		# 			fv['alias'] = tableDict[fv['table_name']]
		# 		idCol = fv['alias'] + "." + fv['table_name'] + "_id"
		# 		if i == 0:
		# 			#TODO: Append alias wherever needed
		# 			conditionStr += " " + idCol + " in (" + ",".join(map(str, value[1])) + ")"
		# 			i += 1
		# 		else:
		# 			conditionStr += " and " + idCol + " in (" + ",".join(map(str, value[1])) + ")"
		# 			i += 1
		# 		# gqlMgr.getPath(vertices.items()[i][0], vertices.items()[j][0])['path_string']
		# 	dynamicQuery = selectStr+" "+fromStr+" "+conditionStr
		# 	print ("Generated dynamic query: \n%s" % dynamicQuery)
		# 	exitWithException(ReturnCodes.FEATURE_NOT_IMPLEMENTED, gqlMgr)
		if debug:
			print ("\nGenerated dynamic query: \n%s\n" % dynamicQuery)

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
	print ("\t-g or --subGraphPath = (OPTIONAL) This is a JSON string of key-value-pairs of this format: {vertex_name1:[value_id1, value_id2], vertex_name2:[value_id1], ...}. This is a list of SOURCE vertices filtered with the listed vertices values (which affects the target vertex' values as well). To fetch the values for an entry vertex, simply don't set this parameter.")
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

def buildSelectString(isUnique, isKvpVertex, isDefaultDataLoc, tvAlias, tvTableName, tvDataLoc, tvName, verbose, debug):
	#----------------------------
	# Building the select string
	#----------------------------
	selectStr = "select "
	if isUnique:
			selectStr += "distinct "
	else:
		selectStr += tvAlias+"."+tvTableName+"_id as id"

	if isKvpVertex and isUnique:
		selectStr += tvAlias+"."+tvDataLoc+" as "+tvName
	elif isKvpVertex and not isUnique:
		selectStr += ", "+tvAlias+"."+tvDataLoc+" as "+tvName
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
				print ("Adding column '%s' to selectStr." % col)
			selectStr += ", "+tvAlias+"."+col
	return selectStr

def buildFromString(gqlMgr, path, selectStr, tvAlias, verbose, debug):
	#iterate through the path
	totalVerticesInPath = len(path)
	tableDict = {}
	fromStr = "from"
	tableReuseVi = False
	tableReuseVj = False
	if debug:
		print ("@buildFromString: totalVerticesInPath=%s" % totalVerticesInPath)
	# print ("\nPATH: %s\n" % path)
	#----------------------------
	# Building the from clause string
	#----------------------------
	for i, j in zip(range(0, totalVerticesInPath), range(1, totalVerticesInPath)):
		edge = gqlMgr.getEdge(path[i]['vertex_id'], path[j]['vertex_id'])
		if debug:
			# print ("i: %d, j: %d" % (i, j))
			# print ("path[%d]['name']: %s" % (i, path[i]['name']))
			# print ("path[%d]['name']: %s" % (j, path[j]['name']))
			print ("Current edge: %s" % edge)

		# print ("vertices in edge:\n %s \n %s" % (path[i], path[j]))
		#BUILD THE TABLE NAMES DICTIONARY (unique list of table names that allows reuse - hence, save query time by avoiding joins)
		#for path[i]
		tableReuseVi = False
		tableReuseVj = False
		if path[i]['table_name'] in tableDict:
			path[i]['alias'] = tableDict[path[i]['table_name']]
			tableReuseVi = True
		else:
			tableDict[path[i]['table_name']] = path[i]['alias']
		#for path[j]
		if path[j]['table_name'] in tableDict:
			path[j]['alias'] = tableDict[path[j]['table_name']]
			tableReuseVj = True
		else:
			tableDict[path[j]['table_name']] = path[j]['alias']
		if debug:
			print ("tableDict: %s" % tableDict)
		if i == 0:
			fromStr += " "+path[i]['table_name']+" as "+path[i]['alias']
		if not tableReuseVj:
			fromStr += " inner join "+path[j]['table_name']+" as "+path[j]['alias']
			qualifiedCriterion = ""
			if edge['criterion'] is not None:
				if '=' in edge['criterion']:
					#todo: error checks
					critList = edge['criterion'].split('=')
					critList[0] = path[i]['alias']+"."+critList[0]
					critList[1] = path[j]['alias']+"."+critList[1]
					qualifiedCriterion = "=".join(critList)
				elif '?' in edge['criterion']:
					critList = edge['criterion'].split('?')
					critList[0] = path[j]['alias']+"."+critList[0]
					critList[1] = path[i]['alias']+"."+critList[1]
					qualifiedCriterion = "?".join(critList)
			#todo: handle: criterion==null
			fromStr += " on "+qualifiedCriterion
	#Case when the last vertex in the path, aka targetVertex, was tagged to reuse a table in the subpath
	if tableReuseVj:
		selectStr = selectStr.replace(tvAlias+".", path[j]['alias']+".")
	return fromStr, selectStr, tableDict

def buildConditionString(gqlMgr, path, tableDict, vertexFilter, currVertex, verbose, debug, currVertexIsKvp):
	#----------------------------
	# Building the where clause string
	#----------------------------
	conditionStr = "where"
	i = 0
	for v in path:
		# print ("Processing condition for vertex %s" % v)
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
	if debug:
		print ("Adding where clause entry for filtered vertex, filter = %s" % (vertexFilter))
	if not currVertexIsKvp:
		if currVertex['table_name'] in tableDict:
			currVertex['alias'] = tableDict[currVertex['table_name']]
		idCol = currVertex['alias'] + "." + currVertex['table_name'] + "_id"
		if i == 0:
			conditionStr += " " + idCol + " in (" + ",".join(map(str, vertexFilter)) + ")"
			i += 1
		else:
			conditionStr += " and " + idCol + " in (" + ",".join(map(str, vertexFilter)) + ")"
			i += 1
	return conditionStr

# VALID SYNTAX FOR PROP FIELDS FETCHING:
# 	select * from project p
# 	where p.props@>('{"'||getCvId('division', 'project_prop', 1)::text||'":"Sim_division"}')::jsonb;
def buildPropConditionString(gqlMgr, propName, propGroup, propValue, tableAlias, verbose, debug):
	print ("propval: %s" % propValue)
	propConditionStr = tableAlias+"."+"props @> ('{\"'||getCvId('"
	propConditionStr += propName+"', '"+propGroup+"', 1)::text||'\":\""+propValue+"\"}')::jsonb"
	return propConditionStr


if __name__ == "__main__":
	main(sys.argv[1:])

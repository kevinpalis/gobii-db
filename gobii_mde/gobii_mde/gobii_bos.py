#!/usr/bin/env python
'''
	GOBii Big-O Splitter

	This module aims to improve the worst-case time-complexity of big data queries (hence, the Big-O) by spawning multiple worker jobs based on the given partition size.
	This employs a basic boss/worker model to spawn jobs.

'''
from __future__ import print_function
import sys
import getopt
import traceback
import json
from util.bos_utility import ReturnCodes
from util.bos_utility import BOSException
from util.bos_utility import BOSUtility

def main(argv):
		goalVertices = ['marker', 'dnarun']


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
		GQLUtility.printError(e1.message)
		traceback.print_exc()
		sys.exit(eCode)

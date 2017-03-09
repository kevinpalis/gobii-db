#!/usr/bin/env python
from __future__ import print_function
import sys
import csv
import traceback
import itertools
from os.path import basename
from os.path import splitext
from pkg_resources import resource_stream
from util.ifl_utility import IFLUtility

def main(isVerbose,preprocessedFile,outputPath, tableName):
	IS_VERBOSE =isVerbose
	SUFFIX_LEN = 8 
	#if IS_VERBOSE:
	#	print("arguments: %s" % str(sys.argv))
	
	outputFile = outputPath+"ddp_"+basename(preprocessedFile)
	longPreProcFile = outputPath+"long_"+basename(preprocessedFile)
	exitCode = 0
	#isKVP = False
	#isProp = False
	tableName = splitext(basename(preprocessedFile))[1][1:]
	randomStr = IFLUtility.generateRandomString(SUFFIX_LEN)
	if IS_VERBOSE:
		print("PreprocessedFile: ", preprocessedFile)
		print("Table Name: ", tableName)
		print("Output File: ", outputFile)
		print("Getting info from dupmap file: ", tableName+'.dupmap')
		#print("")

	isProp = tableName.endswith('_prop')
	dupMapFile = resource_stream('res.map',tableName+'.dupmap')

	##open preprocessedFile
	with open(preprocessedFile,'r') as preProcFile:
		for row in preProcFile:
			print(row)
		
		## get columns from dupmap
		reader = csv.reader(dupMapFile,delimiter='\t')
		dupMapColList = [i[0].split(",")[0] for i in reader]
		print ("Check for this columns: ", dupMapColList)
	
		

if __name__ == "__main__":
	if len(sys.argv) < 3:
		print("Please supply the parameters. \nUsage: deduplicate_ifile <preprocessed_file> <output_directory_path> <tableName>")
		sys.exit(1)
	preprocessedFile = str(sys.argv[1])
	outputPath = str(sys.argv[2])
	tableName = str(sys.argv[3])
	main(True, preprocessedFile, outputPath,tableName)

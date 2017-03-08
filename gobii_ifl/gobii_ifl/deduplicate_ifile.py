#!/usr/bin/env python
from __future__ import print_function
import sys
import csv
import traceback
import itertools
from os.path import basename
from os.path import splitext
from pkg_resources import resource_stream
#from db.preprocess_ifile_manager import PreprocessIfileManager
from util.ifl_utility import IFLUtility

def main(isVerbose,preprocessedFile,outputPath, tableName):
	IS_VERBOSE =isVerbose
	SUFFIX_LEN = 8 
	if is_VERBOSE:
		print("arguments: %s" % str(sys.argv))

if __name__ == "__main__":
	if len(sys.argv) < 4:
		print("Please supply the parameters. \nUsage: deduplicate_ifile <preprocessed_file> <output_directory_path> <tableName>")
		sys.exit(1)
	preprocessedFile = str(sys.argv[1])
	outputPath = str(sys.argv[2])
	tableName = str(sys.argv[3])
	main(True, preprocessedFile, outputPath,tableName)

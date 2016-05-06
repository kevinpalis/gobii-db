#!/usr/bin/env python

from __future__ import print_function
import sys
import getopt
import load_ifile
import preprocess_ifile

def main(argv):
		verbose = False
		connectionStr = ""
		iFile = ""
		outputPath = ""
		#print("Args count: ", len(argv))
		try:
			opts, args = getopt.getopt(argv, "hc:i:o:v", ["connectionString=", "inputFile=", "outputDir=", "verbose"])
			#print (opts, args)
			if len(args) < 3 and len(opts) < 3:
				printUsageHelp()
		except getopt.GetoptError:
			printUsageHelp()
			sys.exit(2)
		for opt, arg in opts:
			if opt == '-h':
				printUsageHelp()
			elif opt in ("-c", "--connectionString"):
				connectionStr = arg
			elif opt in ("-i", "--inputFile"):
				iFile = arg
			elif opt in ("-o", "--outputDir"):
				outputPath = arg
			elif opt in ("-v", "--verbose"):
				verbose = True
		if verbose:
			print("Opts: ", opts)
		if connectionStr != "" and outputPath != "" and iFile != "":
			preprocessedFile = preprocess_ifile.main(verbose, connectionStr, iFile, outputPath)
			load_ifile.main(verbose, connectionStr, preprocessedFile, outputPath)
		else:
			printUsageHelp()

def printUsageHelp():
	print ("gobii_ifl.py -c <connectionString> -i <inputFile> -o <outputDirectory> -v")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-i or --inputFile = The intermediate file. Expected format: freetext.tablename")
	print ("\t-o or --outputDir = The output directory where preprocessed file and file for bulk loading (no duplicates) will be placed.\n\t\tEnsure that this path is writeable.")
	print ("\t-v or --verbose = Print the status of the IFL in more detail")
	sys.exit()

if __name__ == "__main__":
	main(sys.argv[1:])

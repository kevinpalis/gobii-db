#!/usr/bin/env python

from __future__ import print_function
import sys
import getopt
import extract_marker_metadata
from util.mde_utility import MDEUtility

def main(argv):
		verbose = False
		connectionStr = ""
		markerOutputFile = ""
		sampleOutputFile = ""
		datasetId = ""
		allMeta = False
		#print("Args count: ", len(argv))
		try:
			opts, args = getopt.getopt(argv, "hc:m:s:d:av", ["connectionString=", "markerOutputFile=", "sampleOutputFile=", "datasetId=", "all", "verbose"])
			#print (opts, args)
			if len(args) < 2 and len(opts) < 2:
				printUsageHelp()
		except getopt.GetoptError:
			printUsageHelp()
			sys.exit(2)
		for opt, arg in opts:
			if opt == '-h':
				printUsageHelp()
			elif opt in ("-c", "--connectionString"):
				connectionStr = arg
			elif opt in ("-m", "--markerOutputFile"):
				markerOutputFile = arg
			elif opt in ("-s", "--sampleOutputFile"):
				sampleOutputFile = arg
			elif opt in ("-d", "--datasetId"):
				datasetId = arg
			elif opt in ("-a", "--all"):
				allMeta = True
			elif opt in ("-v", "--verbose"):
				verbose = True

		#if verbose:
		#print("Opts: ", opts)
		if datasetId.isdigit():
			if connectionStr != "" and markerOutputFile != "":
				try:
					if verbose:
						print("Generating marker metadata file...")
					extract_marker_metadata.main(verbose, connectionStr, datasetId, markerOutputFile, allMeta)
				except Exception as e1:
					MDEUtility.printError("Error: %s" % (str(e1)))
			elif connectionStr != "" and sampleOutputFile != "":
				try:
					if verbose:
						print("Generating sample metadata file...")
				except Exception as e:
					MDEUtility.printError("Error: %s" % str(e))
			else:
				printUsageHelp()
		else:
			MDEUtility.printError("The supplied dataset ID is not valid.")
		#cleanup

def checkDataIntegrity(iFile, pFile, verbose):
	iCount = MDEUtility.getFileLineCount(iFile)
	pCount = MDEUtility.getFileLineCount(pFile)
	#print ("Input file line count: %i" % iCount)
	#print ("Ppd file line count: %i" % pCount)
	if iCount == pCount:
		return True
	else:
		if verbose:
			print ("Mismatch: input_file=%s preprocessed_file=%s" % (iCount, pCount))
		return False

def printUsageHelp():
	print ("gobii_ifl.py -c <connectionString> -m <markerOutputFile> -s <sampleOutputFile> -d <dataset_id> -all -v")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-m or --markerOutputFile = The marker output file. This should be an absolute path.")
	print ("\t-s or --sampleOutputFile = The sample output file. This should be an absolute path.")
	print ("\t-d or --datasetId = The dataset ID of which marker metadata will be extracted from. This should be a valid integer ID.")
	print ("\t-a or --all = Get all metadata information available, regardless if they are relevant to HMP, Flapjack, etc. formats.")
	print ("\t-v or --verbose = Print the status of the MDE in more detail")
	sys.exit()

if __name__ == "__main__":
	main(sys.argv[1:])

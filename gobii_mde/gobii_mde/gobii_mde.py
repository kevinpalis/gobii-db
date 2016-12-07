#!/usr/bin/env python

from __future__ import print_function
import sys
import getopt
import extract_marker_metadata
import extract_sample_metadata
import extract_project_metadata
from util.mde_utility import MDEUtility

def main(argv):
		verbose = False
		connectionStr = ""
		markerOutputFile = ""
		sampleOutputFile = ""
		datasetId = ""
		projectOutputFile = ""
		allMeta = False
		namesOnly = False
		mapId = -1
		includeChrLen = False
		displayMap = -1
		exitCode = 0
		#print("Args count: ", len(argv))
		try:
			opts, args = getopt.getopt(argv, "hc:m:s:d:p:avnM:lD:", ["connectionString=", "markerOutputFile=", "sampleOutputFile=", "datasetId=", "projectOutputFile=", "all", "verbose", "namesOnly", "map=", "includeChrLen","displayMap="])
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
			elif opt  in ("-D", "--displayMap"):
				displayMap = arg

		#if verbose:
		#print("Opts: ", opts)
		rn = False
		if datasetId.isdigit():
			if connectionStr != "" and markerOutputFile != "":
				try:
					if verbose:
						print("Generating marker metadata file...")
					extract_marker_metadata.main(verbose, connectionStr, datasetId, markerOutputFile, allMeta, namesOnly, mapId, includeChrLen,displayMap)
				except Exception as e1:
					MDEUtility.printError("Error: %s" % (str(e1)))
					exitCode = 2
				rn = True
			if connectionStr != "" and sampleOutputFile != "":
				try:
					if verbose:
						print("Generating sample metadata file...")
					extract_sample_metadata.main(verbose, connectionStr, datasetId, sampleOutputFile, allMeta, namesOnly)
				except Exception as e:
					MDEUtility.printError("Error: %s" % str(e))
					exitCode = 3
				rn = True
			if connectionStr != "" and projectOutputFile != "":
				try:
					if verbose:
						print("Generating project metadata file...")
					extract_project_metadata.main(verbose, connectionStr, datasetId, projectOutputFile, allMeta)
				except Exception as e:
					MDEUtility.printError("Error: %s" % str(e))
					exitCode = 4
				rn = True
			if not rn:
				print("At least one of -m, -s, or -p is required for the extractor to run.")
				printUsageHelp()
		else:
			MDEUtility.printError("The supplied dataset ID is not valid.")
			exitCode = 5
		sys.exit(exitCode)
		#cleanup

def printUsageHelp():
	print ("gobii_mde.py -c <connectionString> -m <markerOutputFile> -s <sampleOutputFile> -p <projectOutputFile> -d <dataset_id> -M <map_id> -D <MapsetId for Display> -a -v -n")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-m or --markerOutputFile = The marker metadata output file. This should be an absolute path.")
	print ("\t-s or --sampleOutputFile = The sample metadata output file. This should be an absolute path.")
	print ("\t-p or --projectOutputFile = The project metadata output file. This should be an absolute path.")
	print ("\t-d or --datasetId = The dataset ID of which marker metadata will be extracted from. This should be a valid integer ID.")
	print ("\t-a or --all = Get all metadata information available, regardless if they are relevant to HMP, Flapjack, etc. formats.")
	print ("\t-v or --verbose = Print the status of the MDE in more detail.")
	print ("\t-n or --namesOnly = Generate only names metadata. This flag is ignored if -a / --all is set.")
	print ("\t-M or --map = Get only the markers in the specified map. This is useful if a dataset contains markers that belongs to multiple maps.")
	print ("\t-l or --includeChrLen = Generates a file that lists all the chromosomes (or any linkage groups) that appear on the markers list, along with their lengths. Filename is the same as the marker file but appended with .chr.")
	print ("\t-D or --displayMap = MapsetId for the mapset info to display,if marker exists in more than one mapset. Mapset file is the same as marker file appended  with .mapset.")
	sys.exit(1)

if __name__ == "__main__":
	main(sys.argv[1:])

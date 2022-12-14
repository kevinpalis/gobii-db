#!/usr/bin/env python

from __future__ import print_function
import sys
import os
import getopt
import load_ifile
import preprocess_ifile
import deduplicate_ifile
from util.ifl_utility import IFLUtility
from os.path import basename
from os.path import splitext

#exit codes used here: 1, 2, 3, 4
def main(argv):
		verbose = False
		flCheck = False
		connectionStr = ""
		iFile = ""
		inputDir = ""
		outputPath = ""
		exitCode = 0
		#print("Args count: ", len(argv))
		try:
			opts, args = getopt.getopt(argv, "hc:i:d:o:vl", ["connectionString=", "inputFile=", "inputDir=", "outputDir=", "verbose", "fileLengthCheck"])
			#print (opts, args)
			if len(args) < 3 and len(opts) < 3:
				printUsageHelp()
		except getopt.GetoptError:
			printUsageHelp()
		for opt, arg in opts:
			if opt == '-h':
				printUsageHelp()
			elif opt in ("-c", "--connectionString"):
				connectionStr = arg
			elif opt in ("-i", "--inputFile"):
				iFile = arg
			elif opt in ("-d", "--inputDir"):
				inputDir = arg
			elif opt in ("-o", "--outputDir"):
				outputPath = arg
			elif opt in ("-v", "--verbose"):
				verbose = True
			elif opt in ("-l", "--fileLengthCheck"):
				flCheck = True
		#if verbose:
		#print("Opts: ", opts)
		if connectionStr != "" and outputPath != "":
			if inputDir != "":
				#Directory iterative run
				for f in os.listdir(inputDir):
					try:
						if verbose:
							print("Processing file %s..." % f)
						tableName = splitext(basename(f))[1][1:]
						isProp = tableName.endswith('_prop')
						if isProp:
							longPropFilename = outputPath+"long_"+basename(f)
						#preprocessing happens here
						preprocessedFile, exitCode = preprocess_ifile.main(verbose, connectionStr, os.path.join(inputDir, f), outputPath)

						if exitCode != 0:
							sys.exit(exitCode)

						#use the input file vs ppd file for general cases
						if flCheck and not isProp:
							if not checkDataIntegrity(f, preprocessedFile, verbose):
								IFLUtility.printError("File length mismatch detected on %s. You either have duplicate entries in the table where the NMAP file maps to OR you're trying to load data to entities that do not exist, please fix it first. Loading will abort." % f)
								exitCode = 4
								sys.exit(exitCode)
						#use the long format file vs the ppd file for property data
						if flCheck and isProp:
							if not checkDataIntegrity(longPropFilename, preprocessedFile, verbose):
								IFLUtility.printError("File length mismatch detected on %s. You either have duplicate entries in the table where the NMAP file maps to OR you're trying to load data to entities that do not exist, please fix it first. Loading will abort." % f)
								exitCode = 5
								sys.exit(exitCode)

						if not isProp:
							dedupFile, exitCode = deduplicate_ifile.main(verbose, preprocessedFile, outputPath, tableName)
							loadFile, exitCode = load_ifile.main(verbose, connectionStr, dedupFile, outputPath)
						else:  # DO NOT DEDUPLICATE PROPERTY FILES AS YOU'LL REMOVE GOOD DATA, NO NEED FOR IT ANYWAY SINCE THIS WILL BE AN UPSERT OPERATION
							loadFile, exitCode = load_ifile.main(verbose, connectionStr, preprocessedFile, outputPath)
						if exitCode != 0:
							sys.exit(exitCode)
						'''
						In light of enhanced error logging, we decided that there is value to these files and so IFLs will not delete them.
						try:
							os.remove(preprocessedFile)
							os.remove(loadFile)
						except Exception as e:
							IFLUtility.printError("Failed to remove temporary files. Check file permissions. Error: %s" % str(e))
							exitCode = 2
						'''
					except Exception as e1:
						IFLUtility.printError("Failed to load file %s. Error: %s" % (f, str(e1)))
						exitCode = 3
						sys.exit(exitCode)
			elif iFile != "":
				#Per file run
				tableName = splitext(basename(iFile))[1][1:]
				isProp = tableName.endswith('_prop')
				if isProp:
					longPropFilename = outputPath+"long_"+basename(iFile)
				#preprocessing happens here
				preprocessedFile, exitCode = preprocess_ifile.main(verbose, connectionStr, iFile, outputPath)

				#terminate if there are any errors in preprocessing stage
				if exitCode != 0:
					sys.exit(exitCode)
				loadFile = None
				#use the input file vs ppd file for general cases
				if flCheck and not isProp:
					if not checkDataIntegrity(iFile, preprocessedFile, verbose):
						IFLUtility.printError("File length mismatch detected on %s. You either have duplicate entries in the table where the NMAP file maps to OR you're trying to load data to entities that do not exist, please fix it first. Loading will abort." % iFile)
						exitCode = 4
						sys.exit(exitCode)
				#use the long format file vs the ppd file for property data
				if flCheck and isProp:
					if not checkDataIntegrity(longPropFilename, preprocessedFile, verbose):
						IFLUtility.printError("File length mismatch detected on %s. You either have duplicate entries in the table where the NMAP file maps to OR you're trying to load data to entities that do not exist, please fix it first. Loading will abort." % iFile)
						exitCode = 5
						sys.exit(exitCode)
				if not isProp:
					dedupFile, exitCode = deduplicate_ifile.main(verbose, preprocessedFile, outputPath, tableName)
					loadFile, exitCode = load_ifile.main(verbose, connectionStr, dedupFile, outputPath)
				else:  # DO NOT DEDUPLICATE PROPERTY FILES AS YOU'LL REMOVE GOOD DATA, NO NEED FOR IT ANYWAY SINCE THIS WILL BE AN UPSERT OPERATION
					loadFile, exitCode = load_ifile.main(verbose, connectionStr, preprocessedFile, outputPath)

				if exitCode != 0:
						sys.exit(exitCode)
				'''
				In light of enhanced error logging, we decided that there is value to these files and so IFLs will not delete them.
				try:
					os.remove(preprocessedFile)
					os.remove(loadFile)
					print ("Temp files deleted.")
				except Exception as e:
					IFLUtility.printError("Failed to remove temporary files. Check file permissions. Error: %s" % str(e))
					exitCode = 0
				'''
			else:
				printUsageHelp()
		else:
			printUsageHelp()
		#return rowsLoaded
		sys.exit(exitCode)
		#cleanup

def checkDataIntegrity(iFile, pFile, verbose):
	iCount = IFLUtility.getFileLineCount(iFile)
	pCount = IFLUtility.getFileLineCount(pFile)
	#print ("Input file line count: %i" % iCount)
	#print ("Ppd file line count: %i" % pCount)
	if iCount == pCount:
		return True
	else:
		if verbose:
			print ("Mismatch: input_file=%s preprocessed_file=%s" % (iCount, pCount))
		return False

def printUsageHelp():
	print ("gobii_ifl.py -c <connectionString> -i <inputFile> -d <inputDir> -o <outputDirectory> -v")
	print ("\t-h = Usage help")
	print ("\t-c or --connectionString = Database connection string (RFC 3986 URI).\n\t\tFormat: postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]")
	print ("\t-i or --inputFile = The intermediate file. Expected format: freetext.tablename")
	print ("\t-d or --inputDir = The input directory. The IFL will load each file found in this directory. \n\t\tIn case both inputFile and inputDir is specified, inputDir will take precedence.")
	print ("\t-o or --outputDir = The output directory where preprocessed file and file for bulk loading (no duplicates) will be placed.\n\t\tEnsure that this path is writeable.")
	print ("\t-v or --verbose = Print the status of the IFL in more detail")
	print ("\t-l or --fileLengthCheck = This will check if the preprocessed file is of the same length as the input file. \n\t\tA mismatch indicates duplicate entries in the table where the NMAP file maps to.\n\t\tInput file should not be loaded in that case.")
	sys.exit(1)


if __name__ == "__main__":
	main(sys.argv[1:])

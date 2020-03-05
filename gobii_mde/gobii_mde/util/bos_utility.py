#!/usr/bin/env python
from __future__ import print_function
import sys

class ReturnCodes:
	"""
	This class provides all the return code constants.
	Note that these are values that will be passed to sys.exit, so it is safer to limit the codes under 100.
	"""
	SUCCESS = 0
	INCOMPLETE_PARAMETERS = 1
	ERROR_PARSING_PARAMETERS = 2
	INVALID_OPTIONS = 3
	ERROR_PARSING_JSON = 4
	NOT_ENTRY_VERTEX = 5
	NO_OUTPUT_PATH = 6
	OUTPUT_FILE_CREATION_FAILED = 7
	FEATURE_NOT_IMPLEMENTED = 8
	NO_PATH_FOUND = 9
	NO_FILTERS_APPLIED_TO_TARGET = 10
	MESSAGES = {
		SUCCESS: "Operation completed successfully.",
		INCOMPLETE_PARAMETERS: "There were fewer parameters passed than what is required. Please check the usage help (-h).",
		ERROR_PARSING_PARAMETERS: "The parameters given cannot be parsed. Please check your syntax.",
		INVALID_OPTIONS: "A given option/flag is invalid. Please check.",
		ERROR_PARSING_JSON: "An error occured while parsing a json parameter. Make sure it is of the proper format.",
		NOT_ENTRY_VERTEX: "A non-entry vertex was supplied without a sub-graph.",
		NO_OUTPUT_PATH: "No output file path was given.",
		OUTPUT_FILE_CREATION_FAILED: "Creating the output file failed.",
		FEATURE_NOT_IMPLEMENTED: "This feature is not implemented for this version of	BOS.",
		NO_PATH_FOUND: "No path can be derived between the two vertices given. Both direct descendants and common relative algorithms have been exhausted.",
		NO_FILTERS_APPLIED_TO_TARGET: "The filters selected did not reduce a non-entry vertex. Aborting to avoid a potentially huge query."
	}


class BOSException(Exception):
	def __init__(self, code):
		self.code = code
		self.message = ReturnCodes.MESSAGES[code]

class BOSUtility:
	"""
	This class provides general and common methods for all GQL classes or scripts.
	"""
	@staticmethod
	def printError(*args, **kwargs):
		print(*args, file=sys.stderr, **kwargs)

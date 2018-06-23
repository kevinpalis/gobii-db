#!/usr/bin/env python
from __future__ import print_function

class ReturnCodes:
	"""
	This class provides all the return code constants.
	Note that these are values that will be passed to sys.exit, so it is safer to limit the codes under 100.
	"""
	SUCCESS = 0
	INCOMPLETE_PARAMETERS = 1
	ERROR_PARSING_PARAMETERS = 2
	INVALID_OPTIONS = 3
	MESSAGES = {
		SUCCESS: "Operation completed successfully.",
		INCOMPLETE_PARAMETERS: "There were fewer parameters passed than what is required. Please check the usage help (-h).",
		ERROR_PARSING_PARAMETERS: "The parameters given cannot be parsed. Please check your syntax.",
		INVALID_OPTIONS: "A given option/flag is invalid. Please check."
	}


class GQLException(Exception):
	def __init__(self, code):
		self.code = code
		self.message = ReturnCodes.MESSAGES[code]


'''
try:
	raise GQLException(ReturnCodes.INCOMPLETE_PARAMETERS)
except GQLException as e:
	print e.message
	sys.exit(e.code)
'''

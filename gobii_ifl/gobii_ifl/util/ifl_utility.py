#!/usr/bin/env python
from __future__ import print_function
import string
import random

class IFLUtility:
	"""
	This class provides general and common methods for all IFL classes or scripts.
	"""
	@staticmethod
	def generateRandomString(length):
		"""
		This function generates a random alphanumeric string given of a given length.
		:args: length - the length of the random string to generate
		:returns: A connection object - This class also stores it as an instance variable for your convenience.
		"""
		chars = string.ascii_uppercase + string.digits
		return ''.join(random.choice(chars) for _ in range(length))

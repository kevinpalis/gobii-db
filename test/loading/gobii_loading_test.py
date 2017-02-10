#!/usr/bin/env python
'''
Tests/Steps:
1. Copy the data files (ie. codominant/data/*) to the target server's gobii_bundle file directory (ie. <bundle>/crops/<crop_name>/files/)
2. Modify the marker instruction file with the correct parameter values, then copy the file (ie. codominant/instruction/m_test.json) to the target server's gobii_bundle instruction dir (ie. <bundle>/crops/<cropname>/loader/instructions)
3. Wait for N minutes (where N=cron job interval)
4. Check the target server's gobii_bundle done directory (ie. <bundle>/crops/<cropname>/loader/done) if the instruction file has been moved
5. Run a query against the DB to check that the file really loaded
'''
from __future__ import print_function
import unittest
import xmlrunner
import sys

class GLoadingTest(unittest.TestCase):
	DB_CONN = 'postgresql://appuser:appuser@localhost:5432/test'
	FS_HOST = 'localhost'
	FS_USERNAME = 'gadm'
	FS_PASSWORD = 'dummypass'
	BUNDLE_PATH = '/storage1/gobii_bundle'
	MARKER_INPUT_FILE = 'codominant/data/codominant_markers.txt'
	MARKER_INSTRUCTION_FILE = 'codominant/instruction/m_test.json'
	SAMPLE_INPUT_FILE = 'codominant/data/codominant_samples.csv'
	SAMPLE_INSTRUCTION_FILE = 'codominant/instruction/s_test.json'
	CRONS_INTERVAL = '5'  # in minutes

	def test_create_marker_instruction_file(self):
		a = 'a'
		b = 'a'
		self.assertEqual(a, b)

	def test_upper(self):
		self.assertEqual('foo'.upper(), 'FOO')

	def test_isupper(self):
		self.assertTrue('FOO'.isupper())
		self.assertFalse('Foo'.isupper())

	def test_split(self):
		s = 'hello world'
		self.assertEqual(s.split(), ['hello', 'world'])
		# check that s.split fails when the separator is not a string
		with self.assertRaises(TypeError):
			s.split(2)


if __name__ == '__main__':
	if len(sys.argv) < 11:
		print("Please supply the parameters. \nUsage: gobii_loading_test <db_connection_string> <fs_host> <fs_username> <fs_password> <bundle_path> <marker_input_file> <marker_instruction_file> <sample_input_file> <sample_instruction_file> <crons_interval:minutes>")
		sys.exit(1)
	else:
		GLoadingTest.CRONS_INTERVAL = str(sys.argv.pop())
		GLoadingTest.SAMPLE_INSTRUCTION_FILE = str(sys.argv.pop())
		GLoadingTest.SAMPLE_INPUT_FILE = str(sys.argv.pop())
		GLoadingTest.MARKER_INSTRUCTION_FILE = str(sys.argv.pop())
		GLoadingTest.MARKER_INPUT_FILE = str(sys.argv.pop())
		GLoadingTest.BUNDLE_PATH = str(sys.argv.pop())
		GLoadingTest.FS_PASSWORD = str(sys.argv.pop())
		GLoadingTest.FS_USERNAME = str(sys.argv.pop())
		GLoadingTest.FS_HOST = str(sys.argv.pop())
		GLoadingTest.DB_CONN = str(sys.argv.pop())
		#print('\n '.join("%s: %s" % item for item in vars(GLoadingTest).items()))
	#unittest.main()
	#unittest.main(testRunner=xmlrunner.XMLTestRunner(output='test-reports'))
	with open('test-reports/loading_test_results.xml', 'wb') as output:
		unittest.main(testRunner=xmlrunner.XMLTestRunner(output=output))

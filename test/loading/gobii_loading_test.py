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
import subprocess
import time
from os.path import basename


class GLoadingTest(unittest.TestCase):
	DB_CONN = 'postgresql://appuser:appuser@localhost:5432/test'
	FS_HOST = 'localhost'
	FS_USERNAME = 'gadm'
	FS_PASSWORD = 'dummypass'
	CROP_PATH = '/storage1/gobii_sys_int/gobii_bundle/crops/dev'
	#LOADING_INSTRUCTION_PATH = '/storage1/gobii_sys_int/gobii_bundle/crops/dev/loader/instructions'
	MARKER_INPUT_FILE = 'codominant/data/codominant_markers.txt'
	MARKER_INSTRUCTION_FILE = 'codominant/instruction/m_test.json.template'
	SAMPLE_INPUT_FILE = 'codominant/data/codominant_samples.csv'
	SAMPLE_INSTRUCTION_FILE = 'codominant/instruction/s_test.json.template'
	MARKER_FILE_TARGET_DIR = ''
	MARKER_OUTPUT_TARGET_DIR = ''
	SAMPLE_FILE_TARGET_DIR = ''
	SAMPLE_OUTPUT_TARGET_DIR = ''
	CRONS_INTERVAL = '5'  # in minutes

	@classmethod
	def setUpClass(self):
		try:
			#print('ssh '+self.FS_USERNAME+'@'+self.FS_HOST+' mkdir -p '+self.MARKER_FILE_TARGET_DIR)
			retCode = subprocess.call('ssh '+self.FS_USERNAME+'@'+self.FS_HOST+' mkdir -p '+self.MARKER_FILE_TARGET_DIR+' '+self.SAMPLE_FILE_TARGET_DIR+' '+self.MARKER_OUTPUT_TARGET_DIR+' '+self.SAMPLE_OUTPUT_TARGET_DIR, shell=True)
		except OSError as e:
			print('Failed to create target directories in server. Retcode: %s Cause: %s' % (retCode, e))

	def test_1_create_marker_instruction_file(self):
		try:
			markerInstructionFile = self.MARKER_INSTRUCTION_FILE.replace('.template', '')
			with open(self.MARKER_INSTRUCTION_FILE, "r") as fin:
				with open(markerInstructionFile, "w") as fout:
					for line in fin:
						line = line.replace('SOURCE_replace_me_I_am_a_temporary_string', self.MARKER_FILE_TARGET_DIR)
						line = line.replace('DESTINATION_replace_me_I_am_a_temporary_string', self.MARKER_OUTPUT_TARGET_DIR)
						fout.write(line)
			self.assertTrue(True)
		except Exception:
			self.assertTrue(False)

	'''def test_create_target_path_in_gobii_server(self):
		try:
			#print('ssh '+self.FS_USERNAME+'@'+self.FS_HOST+' mkdir -p '+self.MARKER_FILE_TARGET_DIR)
			retCode = subprocess.call('ssh '+self.FS_USERNAME+'@'+self.FS_HOST+' mkdir -p '+self.MARKER_FILE_TARGET_DIR+' '+self.SAMPLE_FILE_TARGET_DIR+' '+self.MARKER_OUTPUT_TARGET_DIR+' '+self.SAMPLE_OUTPUT_TARGET_DIR, shell=True)
			self.assertEquals(retCode, 0)
		except OSError as e:
			self.fail('Failed to create target directories in server. Cause: %s' % e)'''

	def test_1_create_sample_instruction_file(self):
		try:
			sampleInstructionFile = self.SAMPLE_INSTRUCTION_FILE.replace('.template', '')
			with open(self.SAMPLE_INSTRUCTION_FILE, "r") as fin:
				with open(sampleInstructionFile, "w") as fout:
					for line in fin:
						line = line.replace('SOURCE_replace_me_I_am_a_temporary_string', self.SAMPLE_FILE_TARGET_DIR)
						line = line.replace('DESTINATION_replace_me_I_am_a_temporary_string', self.SAMPLE_OUTPUT_TARGET_DIR)
						fout.write(line)
			#self.assertTrue(True)
		except Exception:
			self.fail('Failed to create sample instruction file.')

	def test_2_upload_marker_data_file(self):
		try:
			retCode = subprocess.call('scp '+self.MARKER_INPUT_FILE+' '+self.FS_USERNAME+'@'+self.FS_HOST+':'+self.MARKER_FILE_TARGET_DIR, shell=True)
			self.assertEquals(retCode, 0)
		except OSError as e:
			self.fail('Failed to upload marker data file. Cause: %s' % e)

	def test_2_upload_sample_data_file(self):
		try:
			retCode = subprocess.call('scp '+self.SAMPLE_INPUT_FILE+' '+self.FS_USERNAME+'@'+self.FS_HOST+':'+self.SAMPLE_FILE_TARGET_DIR, shell=True)
			self.assertEquals(retCode, 0)
		except OSError as e:
			self.fail('Failed to upload sample data file. Cause: %s' % e)

	def test_3_upload_marker_instruction_file(self):
		try:
			retCode = subprocess.call('scp '+self.MARKER_INSTRUCTION_FILE.replace('.template', '')+' '+self.FS_USERNAME+'@'+self.FS_HOST+':'+self.CROP_PATH+'/loader/instructions', shell=True)
			self.assertEquals(retCode, 0)
		except OSError as e:
			self.fail('Failed to upload marker instruction file. Cause: %s' % e)

	def test_3_upload_sample_instruction_file(self):
		try:
			retCode = subprocess.call('scp '+self.SAMPLE_INSTRUCTION_FILE.replace('.template', '')+' '+self.FS_USERNAME+'@'+self.FS_HOST+':'+self.CROP_PATH+'/loader/instructions', shell=True)
			self.assertEquals(retCode, 0)
		except OSError as e:
			self.fail('Failed to upload sample instruction file. Cause: %s' % e)

	def test_4_check_if_digester_consumed_marker_file(self):
		try:
			#print('ssh '+self.FS_USERNAME+'@'+self.FS_HOST+' test -f '+self.CROP_PATH+'/loader/done/'+basename(self.MARKER_INSTRUCTION_FILE+'.new'))
			time.sleep(int(self.CRONS_INTERVAL) * 60 * 2.3)
			retCode = subprocess.call('ssh '+self.FS_USERNAME+'@'+self.FS_HOST+' test -f '+self.CROP_PATH+'/loader/done/'+basename(self.MARKER_INSTRUCTION_FILE.replace('.template', '')), shell=True)
			self.assertEquals(retCode, 0)
		except OSError as e:
			self.fail('Failed to check finished marker instruction file. Cause: %s' % e)

	def test_4_check_if_digester_consumed_sample_file(self):
		try:
			#time.sleep(int(self.CRONS_INTERVAL) * 2.3)
			retCode = subprocess.call('ssh '+self.FS_USERNAME+'@'+self.FS_HOST+' test -f '+self.CROP_PATH+'/loader/done/'+basename(self.SAMPLE_INSTRUCTION_FILE.replace('.template', '')), shell=True)
			self.assertEquals(retCode, 0)
		except OSError as e:
			self.fail('Failed to check finished sample instruction file. Cause: %s' % e)


if __name__ == '__main__':
	if len(sys.argv) < 11:
		print("Please supply the parameters. \nUsage: gobii_loading_test <db_connection_string> <fs_host> <fs_username> <fs_password> <crop_path> <marker_input_file> <marker_instruction_file> <sample_input_file> <sample_instruction_file> <marker_file_target_dir> <marker_output_target_dir> <sample_file_target_dir> <sample_output_target_dir> <crons_interval:minutes>")
		sys.exit(1)
	else:
		GLoadingTest.CRONS_INTERVAL = str(sys.argv.pop())
		GLoadingTest.SAMPLE_OUTPUT_TARGET_DIR = str(sys.argv.pop())
		GLoadingTest.SAMPLE_FILE_TARGET_DIR = str(sys.argv.pop())
		GLoadingTest.MARKER_OUTPUT_TARGET_DIR = str(sys.argv.pop())
		GLoadingTest.MARKER_FILE_TARGET_DIR = str(sys.argv.pop())
		GLoadingTest.SAMPLE_INSTRUCTION_FILE = str(sys.argv.pop())
		GLoadingTest.SAMPLE_INPUT_FILE = str(sys.argv.pop())
		GLoadingTest.MARKER_INSTRUCTION_FILE = str(sys.argv.pop())
		GLoadingTest.MARKER_INPUT_FILE = str(sys.argv.pop())
		GLoadingTest.CROP_PATH = str(sys.argv.pop())
		GLoadingTest.FS_PASSWORD = str(sys.argv.pop())
		GLoadingTest.FS_USERNAME = str(sys.argv.pop())
		GLoadingTest.FS_HOST = str(sys.argv.pop())
		GLoadingTest.DB_CONN = str(sys.argv.pop())
		#print('\n '.join("%s: %s" % item for item in vars(GLoadingTest).items()))
	#unittest.main()
	#unittest.main(testRunner=xmlrunner.XMLTestRunner(output='test-reports'))
	with open('test-reports/loading_test_results.xml', 'wb') as output:
		unittest.main(testRunner=xmlrunner.XMLTestRunner(output=output))

#!/usr/bin/env python
'''
Tests/Steps:
1. Copy the data files (ie. codominant/data/*) to the target server's gobii_bundle file directory (ie. <bundle>/crops/<crop_name>/files/)
2. Modify the marker instruction file with the correct parameter values, then copy the file (ie. codominant/instruction/m_test.json) to the target server's gobii_bundle instruction dir (ie. <bundle>/crops/<cropname>/loader/instructions)
3. Wait for N minutes (where N=cron job interval)
4. Check the target server's gobii_bundle done directory (ie. <bundle>/crops/<cropname>/loader/done) if the instruction file has been moved
5. Run a query against the DB to check that the file really loaded
'''
import unittest
import xmlrunner

class GLoadingTest(unittest.TestCase):
	def test(self):
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
	#unittest.main()
	#unittest.main(testRunner=xmlrunner.XMLTestRunner(output='test-reports'))
	with open('test-reports/loading_test_results.xml', 'wb') as output:
		unittest.main(testRunner=xmlrunner.XMLTestRunner(output=output))

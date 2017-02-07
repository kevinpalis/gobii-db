#!/usr/bin/env python

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

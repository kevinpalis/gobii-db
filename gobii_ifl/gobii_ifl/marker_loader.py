#!/usr/bin/env python
'''
	This script loads the marker intermediate file (Digester output) directly to the marker table in the GOBII schema.

	Prerequisites:

	Note(s):

	@author kpalis Kevin Palis <kdp44@cornell.edu>
'''
from __future__ import print_function
import sys
import csv
import traceback
from db.marker_module_manager import MarkerModuleManager

IS_VERBOSE = True

if len(sys.argv) < 3:
	print("Please supply the parameters. \nUsage: marker_loader project_name.marker output_path_for_id_map session_id")
	sys.exit()

markerFile = str(sys.argv[1])
if len(sys.argv) > 3:
	markerPropFile = str(sys.argv[3])
markerMgr = MarkerModuleManager()

if IS_VERBOSE:
	print("arguments: %s" % str(sys.argv))

markerModuleMgr = MarkerModuleManager()

try:
	with open(markerFile, 'r') as f1:
		reader = csv.reader(f1, delimiter='\t')
		for platform_id, variant_id, name, code, ref, alts, sequence, reference_name, primers, probsets, strand_name, status in reader:
			print("Processing marker: %s" % name)
	f1.close
	print("Marker metadata loaded successfully.")
except Exception as e:
	print('Failed to load marker metadata: %s' % str(e))
	traceback.print_exc()

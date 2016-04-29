#!/usr/bin/env python
'''
	This script loads marker metadata for the Illumina-Infinium6k platform.

	Sample Format Expected (column header):
		IlmnID,Name,IlmnStrand,SNP,AddressA_ID,AlleleA_ProbeSeq,AddressB_ID,AlleleB_ProbeSeq,GenomeBuild,Chr,MapInfo,Ploidy,Species,Source,SourceVersion,SourceStrand,SourceSeq,TopGenomicSeq,BeadSetID

	Prerequisites:
		1. Existing CVs for chromosomes and map_type
		2. Existing reference row - ex. Nipponbare IRGSP 1.0
		3. Existing CVs for the map_type (physical, genetic)
		4. Existing entry for the map table for the markers to link to (ex. Infinium 6k Map)
		5. Existing vendor entry in the Contacts table - ex. Illumina Inc.
		5. Existing Platform row - ex. Illumina

	Note(s):
		* For every row in the csv file, this will create a row in marker table, then a corresponding row in the marker_map table, then finally the marker properties.

	@author Kevin Palis <kdp44@cornell.edu>
'''
from __future__ import print_function
import sys
import csv
import traceback
from db import DBManager




if len(sys.argv) < 5:
    print("Please supply the parameters. \nUsage: load_marker_meta <marker_meta_file.csv> <platform_id> <reference_id> <mapset_id>")
    sys.exit()

input_file = str(sys.argv[1])
platform_id = str(sys.argv[2])
reference_id = str(sys.argv[3])
map_id = str(sys.argv[4])
print("arguments: %s" % str(sys.argv))

fMgr = DBManager()
conn = fMgr.connectToDatabase()
cur = conn.cursor()

dataRowStart = 10  #modify this to indicate the row where the actual data starts
countMissingInMap = 0
try:
	with open(input_file, 'r') as f1:
		for i in range(1, dataRowStart):
			next(f1)
		reader = csv.reader(f1, delimiter=',')
		for ilmnID, name, ilmnStrand, SNP, addressA_ID, alleleA_probeSeq, addressB_ID, alleleB_probeSeq, genomeBuild, chrom, mapInfo, ploidy, species, source, sourceVersion, sourceStrand, sourceSeq, topGenomicSeq, beadSetID in reader:
			print("Processing marker: %s" % name)
			#map csv fields to table columns
			marker_name = name
			#there's an intermediate table called snp_map which contains data from 4606SNPmap.txt (normalized ref_al and alt_al)
			alleles = fMgr.getAllelesFromSNPMap(name)  #list (al1, al2)
			#linkage_group_id = fMgr.getCvIdOfTerm("chr"+chrom)
			linkage_group_id = fMgr.getLinkageGroupID("chr"+chrom)
			if alleles is None:
				countMissingInMap += 1
				alleles = (SNP, '')  #if the marker is not mapped (not in snpmap table), for now just store the unmodified SNP value in the ref_allele column
			position = mapInfo
			strand = sourceStrand
			seq = sourceSeq
			#print "Derived: alleles=%s linkage_group_id=%s" % (alleles, linkage_group_id)
			alts_arr = '{\"'+alleles[1]+'\"}'  #postgresql text array
			#print alts_arr
			strand_id = fMgr.getCvIdOfTerm(strand)
			marker_id = fMgr.createMarker(platform_id, None, marker_name, "dummycode", alleles[0], alts_arr, seq, reference_id, None, None, strand_id, 1)
			if marker_id is not None:
				print("Created marker with ID: ", marker_id)
				fMgr.createMarkerMap(marker_id, None, position, linkage_group_id)
			else:
				print("Failed to create marker %s, please check source file. Rolling back and aborting..." % name)
				conn.rollback()
				break

			#get corresponding IDs for each property
			genomeBuildId = fMgr.getCvIdOfGroupAndTerm("marker property", "genome_build")
			speciesId = fMgr.getCvIdOfGroupAndTerm("marker property", "species")
			sourceId = fMgr.getCvIdOfGroupAndTerm("marker property", "source")
			beadSetIDId = fMgr.getCvIdOfGroupAndTerm("marker property", "beadset_id")
			jsonMarkerProp = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s"}' % (genomeBuildId, genomeBuild, speciesId, species, sourceId, source, beadSetIDId, beadSetID)
			#print "JSON Property String: ", jsonMarkerProp
			#get marker ID for this marker
			#marker_id = fMgr.getMarkerId(marker_name)
			#print "Got the marker id = ", marker_id
			fMgr.createMarkerProperty(marker_id, jsonMarkerProp)
			#!!!TODO: Implement a way to update existing entries, if any. This one just assumes that there is no property entry for the particular marker

			#temp
			#if ilmnID == "31684-3_T_F_2194305175":
			#	break
	f1.closed
	conn.commit()
	print("Marker metadata loaded successfully.")
	print("Markers not in map = ", countMissingInMap)
except Exception as e:
	conn.rollback()
	print('Failed to load marker metadata: %s' % str(e))
	traceback.print_exc()
conn.close()

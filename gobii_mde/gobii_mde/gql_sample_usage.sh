##########################################
##########################################
##   GQL SAMPLE USAGE AND SMOKE TESTS   ##
##########################################
##########################################


####################################################
# SMOKE TESTS on LOCALHOST
####################################################

#--------------------------------------
# PART 1: ENTRY VERTICES
#--------------------------------------
#columns to fetch explicitly specified
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d
#vs no columns to fetch passed = default
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t trial_name -v -d -u
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t germplasm_subspecies -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t dataset -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t marker_linkage_group -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t reference_sample -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t project -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t sampling_date -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t germplasm_type -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t dataset_type -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t analysis_type -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t mapset_type -v -d
#Limit Tests:
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t germplasm_subspecies -v -d -u -l 10
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d -l 10


#------------------------------------------------------------------------------------------------------------------
# PART 2: With Subgraphs (A list of SOURCE vertices) and a DIRECT PATH for each of them to the target vertex
#------------------------------------------------------------------------------------------------------------------

# Tests that respects the hierarchy of entities
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter2.out -g '{"principal_investigator":[67,69,70]}' -t project -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t division -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t experiment -f '["name"]' -v
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "division":["Sim_division","FQ_division"]}' -t experiment -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t dataset -v -d
#sample goal vertex marker with subgraph only containing vertices with relevance=3 (ie. relevant to both markers and dnarun)
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "dataset":[1,2,3,4,5]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "mapset_type":[1]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "dataset_type":[97, 98]}' -t marker -v -d

#sample goal vertex dnarun with subgraph only containing vertices with relevance=3 (ie. relevant to both markers and dnarun)
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "mapset_type":[60]}' -t dnarun -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "mapset_type":[60], "platform":[1,2,3]}' -t protocol -v -d
#sample non-entry vertex with subgraph but did not filter down the vertex = should error out
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"mapset_type":[60]}' -t dnarun -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{ "trial_name":["testtrial1"]}' -t marker -v -d
#sample entry vertex with subgraph that did not filter down the vertex = should proceed as if it's an entry vertex call
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"mapset_type":[60]}' -t analysis -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{ "division":["Sim_division","FQ_division"]}' -t mapset -v -d


# Props/KVP vertices in path TEST

#Get all divisions
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t division -v -d -u
#From the command above, add source vertex division with filters to more than just one division name
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{"principal_investigator":[67, 69, 70], "project":[3,25,30], "division":["cornell", "foo division", "codominant_testqc"]}' -t experiment -f '["name"]' -v


####################################################
# USAGE SIMULATION on LOCALHOST
####################################################

#-----------------------------------------------------
# CASE1: F1=PI, F2=Dataset_type, F3=Dataset, Submit
#-----------------------------------------------------
#-------------------F1--------------------------------
#User select PI for F1 - displays all PIs
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -v -d
#User selects PIs with IDs 67, 69, and 70 from the F1 selection box, marker and sample stats get generated 
#--> on my tests: markers=10080, dnaruns=4851
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1-markers.out -g '{"principal_investigator":[67,69,70]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1-dnaruns.out -g '{"principal_investigator":[67,69,70]}' -t dnarun -v -d

#-------------------F2--------------------------------
#User select Dataset_type for F2 - since PI and dataset_type vertices are not connected directly, dataset_type list is unaffected by selected PI filters
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter2.out -g '{"principal_investigator":[67,69,70]}' -t dataset_type -v -d
#User select dataset_types nucleotide_2_letter and iupac (ids 97,98) 
#NOTE: This actually takes a few seconds longer than the first stats queries despite having significantly less rows. The reason: filtering through tens of thousands of rows takes a few seconds. The first stats count takes about 1 sec.
#--> on my tests: markers=9442, dnaruns=990
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter2-markers.out -g '{"principal_investigator":[67,69,70], "dataset_type":[97, 98]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter2-dnaruns.out -g '{"principal_investigator":[67,69,70], "dataset_type":[97, 98]}' -t dnarun -v -d

#-------------------F3--------------------------------
#User select Dataset_type for F2 - since PI and dataset_type vertices are not connected directly, dataset_type list is unaffected by selected PI filters
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "dataset_type":[97, 98]}' -t dataset -v -d
#User select datasets: 33=debTestDS1_dartClone_2ltr_Gen, 29=IUPAC test, 51=DebTestEDS-IUPAC, 35=2letternuc, and 84=Deb_IUPAC_DS1  
#--> on my tests: markers=9435, dnaruns=990
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3-markers.out -g '{"principal_investigator":[67,69,70], "dataset_type":[97, 98], "dataset":[33,29,51,35,84]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3-dnaruns.out -g '{"principal_investigator":[67,69,70], "dataset_type":[97, 98], "dataset":[33,29,51,35,84]}' -t dnarun -v -d

#-------------------Submit--------------------------------
# 1. There is no call to GQL for this step. The last set of files (filter3-markers.out and filter3-dnaruns.out) are going to be passed to the MDEs
# 2. The markers and samples stats box remains at 9435 and 990 respectively
# 3. The MDEs will extract the genotype for those 9435 markers and 990 dnaruns -- 2 calls to the MDE (one for each), post-processing needs to be done to intersect the extract-by-markers output and the extract-by-samples output, effectively making an extract-by-markers-AND-samples.


#-----------------------------------------------------
# CASE2: F1=Mapset_type, F2=Sampling_date, F3=Germplasm_species, Submit
#-----------------------------------------------------
#-------------------F1--------------------------------
#User select mapset_type for F1 - displays all mapset_types. NOTE the -u flag as this is a kvp vertex.
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t mapset_type -v -d

#User selects PIs with IDs 67, 69, and 70 from the F1 selection box, marker and sample stats get generated 
#--> on my tests: markers=10080, dnaruns=4851
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1-markers.out -g '{"mapset_type":[60]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1-markers.out -g '{"mapset_type":[60]}' -t dnarun -v -d

############################################################################
# SAMPLE USAGE on FXN_TEST - dummy user creds need to be pre-provisioned
############################################################################

#Entry vertices:
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t trial_name -v -d -u
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t germplasm_subspecies -v -d -u
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t dataset -v -d
#this one should fail with a proper error message
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t marker_linkage_group -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t reference_sample -v -d -u
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t project -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t sampling_date -v -d -u
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t germplasm_type -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t dataset_type -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t analysis_type -v -d

#Limit Tests:
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t germplasm_subspecies -v -d -u -l 10
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d -l 10

#With Subgraphs/Vertices-to-visit:
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter2.out -g '{"principal_investigator":[19,3,4]}' -t project -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[19,14], "project":[20,14,17,21,12,22,23,15,27,18]}' -t division -v -d -u
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[19,14], "project":[20,14,17,21,12,22,23,15,27,18]}' -t marker -v -d

python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"division":["Sim_division","FQ_division"]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"division":["Sim_division","FQ_division"], "experiment":[1,5,7]}' -t marker -v -d

python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[19,3,4], "project":[1,10,20]}' -t experiment -f '["name"]' -v
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter4.out -g '{"principal_investigator":[19,3,4], "project":[1,10,20], "division":[25,30]}' -t experiment -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[19,3,4], "project":[1,10,20]}' -t dataset -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[19,3,4], "project":[1,10,20], "dataset":[1,2,3,4,5]}' -t marker -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@cbsugobii03.tc.cornell.edu:5433/gobii_dev -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[19,3,4], "project":[1,10,20]}' -t dataset_type -v -d

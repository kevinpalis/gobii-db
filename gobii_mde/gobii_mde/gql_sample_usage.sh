##########################################
##########################################
##   GQL SAMPLE USAGE AND SMOKE TESTS   ##
##########################################
##########################################

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


####################################################
# SMOKE TESTS on LOCALHOST
####################################################

#--------------------------------------
# PART 1: ENTRY VERTICES
#--------------------------------------
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d
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

#Limit Tests:
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t germplasm_subspecies -v -d -u -l 10
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t principal_investigator -f '["firstname","lastname"]' -v -d -l 10


#------------------------------------------------------------------------------------------------------------------
# PART 2: With Subgraphs (A list of SOURCE vertices) and a direct path for each of them to the target vertex
#------------------------------------------------------------------------------------------------------------------

python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter2.out -g '{"principal_investigator":[67,69,70]}' -t project -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t division -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t experiment -f '["name"]' -v
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "division":[25,30]}' -t experiment -f '["name"]' -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30]}' -t dataset -v -d
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter3.out -g '{"principal_investigator":[67,69,70], "project":[3,25,30], "dataset":[1,2,3,4,5]}' -t marker -v -d


# Props/KVP vertices in path TEST

#Get all divisions
python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter1.out -t division -v -d -u
#From the command above, add source vertex division with filters to more than just one division name
> python gobii_gql.py -c postgresql://dummyuser:helloworld@localhost:5432/flex_query_db2 -o /Users/KevinPalis/temp/filter4.out -g '{"principal_investigator":[67, 69, 70], "project":[3,25,30], "division":["cornell", "foo division", "codominant_testqc"]}' -t experiment -f '["name"]' -v




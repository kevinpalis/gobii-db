Sample Usage:

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
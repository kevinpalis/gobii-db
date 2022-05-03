--liquibase formatted sql

--changeset kpalis:create_marker_genotype_module context:general splitStatements:false runOnChange:false

CREATE  TABLE "public".marker_genotype ( 
	dataset_id           integer  NOT NULL  ,
	marker_id            integer  NOT NULL  ,
	genotype             jsonb  NOT NULL  ,
	gt                   text    ,
	quality              double precision    ,
	variant_type         text    ,
	metadata             jsonb    ,
	filter               text    ,
	props                jsonb    ,
	CONSTRAINT pk_marker_genotype PRIMARY KEY ( dataset_id, marker_id )
 );

ALTER TABLE "public".marker_genotype ADD CONSTRAINT fk_marker_genotype_marker FOREIGN KEY ( marker_id ) REFERENCES "public".marker( marker_id );

ALTER TABLE "public".marker_genotype ADD CONSTRAINT fk_marker_genotype_dataset FOREIGN KEY ( dataset_id ) REFERENCES "public".dataset( dataset_id );

COMMENT ON TABLE "public".marker_genotype IS 'This is the main table for unified genotypic data storage, ie. one solution for SNPs, polyploids, indels - of virtually any length. This can utilize the following: GiN index for jsonb, B-tree indices for the other columns, parallel index scans, partition by dataset or dataset range (as needed), and can be transposed (if needed). The columns were designed with both the VCF 4.2 standard and Intertek LGC datafiles in mind.';

COMMENT ON COLUMN "public".marker_genotype.dataset_id IS 'Foreign key to the dataset table.';

COMMENT ON COLUMN "public".marker_genotype.marker_id IS 'Foreign key to the marker table.';

COMMENT ON COLUMN "public".marker_genotype.genotype IS 'This is the main genotype column of the format: jsonb ( {dnarun_id:genotype_string,…} ) or alternatively  jsonb ( {dnarun_name:genotype_string,…} ) - whichever makes sense for this instance of the database. However, consistency should be maintained either by database triggers or on the ETL layer. \n\nExample values:\n{"10":"AC", "13":"TT", "14":"GG", "22":"-", "55":"AACTTTG", "101":"TT"}\nalternatively:\n{"sample1":"AC", "sample2":"TT"}';

COMMENT ON COLUMN "public".marker_genotype.gt IS 'This is an optional column and is a direct copy from the VCF’s GT column so we don’t have to encode back for extraction.';

COMMENT ON COLUMN "public".marker_genotype.quality IS 'From the VCF specs:\n\nQUAL - quality: Phred-scaled quality score for the assertion made in ALT. i.e. −10log10 prob(call in ALT is\nwrong). If ALT is ‘.’ (no variant) then this is −10log10 prob(variant), and if ALT is not ‘.’ this is −10log10\nprob(no variant). If unknown, the missing value should be specified.';

COMMENT ON COLUMN "public".marker_genotype.variant_type IS 'The type of variant, ex. SNP, MNP, indel, etc.';

COMMENT ON COLUMN "public".marker_genotype.metadata IS 'This is a genotype-level property, ie. attached to dataset-marker-dnarun combination. Format: jsonb {dnarunId:{ VCF_format_key:value},...}\n\nThis is a 2-level JSON for properties we don''t need to use as criteria for common use-cases.\nEx: read depth, genotype likelihood, other probabilities (the rest of the format field from the VCF)\n\nExample:\n{"10":\n  { "GQ":"48", "DP":"8", "HQ":"51,51" }\n}';

COMMENT ON COLUMN "public".marker_genotype.filter IS 'Filter status: PASS if this position has passed all filters, i.e., a call is made at this position. Otherwise, if the site has not passed all filters, a semicolon-separated list of codes for filters that fail. e.g. “q10;s50” might indicate that at this site the quality is below 10 and the number of samples with data is below 50% of the total number of samples. \n\nThe filter descriptions can be stored in the dataset table as a property.\nExample value: q10\n(indicating quality was below 10)';

COMMENT ON COLUMN "public".marker_genotype.props IS 'This is a marker-dataset level property.  This is a KVP property field. Option to “control” the keys as cv_ids or store as-is (for faster queries). For example:\n\nNS="Number of Samples With Data"\nDP="Total Depth"\nAF="Allele Frequency"\nAA="Ancestral Allele"\nDB="dbSNP membership, build 129">\nH2="HapMap2 membership"\n\n\nNOTE: For flags, the key-value pair will just have an empty string for value.';

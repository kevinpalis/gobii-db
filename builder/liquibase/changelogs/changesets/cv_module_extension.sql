--liquibase formatted sql

--### CV Table Change and Migration ###---
--## CVGroup ##--
--changeset kpalis:create_cv_group_table context:general splitStatements:false
CREATE TABLE cvgroup ( 
  cvgroup_id           serial  NOT NULL,
  name                 text  NOT NULL,
  definition           text  ,
  type_id              integer  ,
  props                jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT cv_pkey PRIMARY KEY ( cvgroup_id ),
  CONSTRAINT unique_cvgroup_name UNIQUE ( name ) 
 );

CREATE INDEX idx_cvgroup ON cvgroup ( type_id );

COMMENT ON TABLE cvgroup IS 'A controlled vocabulary or ontology. A cv is
composed of cvterms (AKA terms, classes, types, universals - relations
and properties are also stored in cvterm) and the relationships
between them.';

COMMENT ON COLUMN cvgroup.name IS 'The name of the group.';

COMMENT ON COLUMN cvgroup.definition IS 'A text description of the criteria for
membership of this group.';

COMMENT ON COLUMN cvgroup.type_id IS 'Determines if CV group is of type "System CV" or "Custom CV". This is extensible.';

ALTER TABLE cvgroup ADD CONSTRAINT cvgroup_typeid_fkey FOREIGN KEY ( type_id ) REFERENCES cv( cv_id );

--## CV ##--
--changeset kpalis:normalize_cv_group context:general splitStatements:false

ALTER TABLE cv ADD COLUMN cvgroup_id integer NOT NULL default 1;

ALTER TABLE cv ADD CONSTRAINT unique_cvterm_term_cvgroupid UNIQUE ( term, cvgroup_id );
ALTER TABLE cv ADD CONSTRAINT cv_cvgroupid_fkey FOREIGN KEY ( cvgroup_id ) REFERENCES cvgroup( cvgroup_id );
--migrate data: group name -> group id


CREATE INDEX idx_cv_cvgroupid ON cv ( cvgroup_id );
--drop freetext group column
ALTER TABLE cv DROP COLUMN "group";

--## DBXREF ##--
CREATE TABLE dbxref ( 
  dbxref_id            serial  NOT NULL,
  accession            text  NOT NULL default '',
  ver                  text  ,
  description          text  ,
  db_name              text  ,
  url                  text  ,
  props                jsonb  DEFAULT '{}'::jsonb,
  CONSTRAINT dbxref_pkey PRIMARY KEY ( dbxref_id ),
  CONSTRAINT unique_dbxref_accession_version UNIQUE ( accession, ver ) 
 );

CREATE INDEX idx_dbxref_accession ON dbxref ( accession );

CREATE INDEX idx_dbxref_ver ON dbxref ( ver );

COMMENT ON TABLE dbxref IS 'A unique, global, public, stable identifier. Not necessarily an external reference - can reference data items inside the particular chado instance being used. Typically a row in a table can be uniquely identified with a primary identifier (called dbxref_id); a table may also have secondary identifiers (in a linking table <T>_dbxref). A dbxref is generally written as <DB>:<ACCESSION> or as <DB>:<ACCESSION>:<VERSION>.';

COMMENT ON COLUMN dbxref.accession IS 'The local part of the identifier. Guaranteed by the db authority to be unique for that db.

In CIMMYT`s request will be: source_id';

COMMENT ON COLUMN dbxref.db_name IS 'source name, ex. EDAM Ontology

A database authority. Typical databases in
bioinformatics are FlyBase, GO, UniProt, NCBI, MGI, etc. The authority
is generally known by this shortened form, which is unique within the
bioinformatics and biomedical realm. ';


--## CV Extension ##--
--changeset kpalis:extend_cv_table context:general splitStatements:false
ALTER TABLE cv ADD COLUMN abbreviation text;
ALTER TABLE cv ADD COLUMN dbxref_id integer;
ALTER TABLE cv ADD COLUMN status integer DEFAULT 1 NOT NULL;
ALTER TABLE cv ADD COLUMN props jsonb DEFAULT '{}'::jsonb;

ALTER TABLE cv ADD CONSTRAINT cv_dbxrefid_fkey FOREIGN KEY ( dbxref_id ) REFERENCES dbxref( dbxref_id );
CREATE INDEX idx_cv_dbxrefid ON cv ( dbxref_id );
CREATE INDEX idx_cv_term ON cv ( term );
--changeset kpalis:add_doc_cv context:general splitStatements:false
COMMENT ON TABLE cv IS 'A term, class, universal or type within an
ontology or controlled vocabulary.  This table is also used for
relations and properties. cvterms constitute nodes in the graph
defined by the collection of cvterms and cvterm_relationships.';

COMMENT ON COLUMN cv.cvgroup_id IS 'The cv or ontology or namespace to which
this cvterm belongs.';

COMMENT ON COLUMN cv.term IS 'A concise human-readable name or
label for the cvterm. Uniquely identifies a cvterm within a cv.';

COMMENT ON COLUMN cv.definition IS 'A human-readable text
definition.';

COMMENT ON COLUMN cv.dbxref_id IS 'Primary identifier dbxref - The
unique global OBO identifier for this cvterm.  ';



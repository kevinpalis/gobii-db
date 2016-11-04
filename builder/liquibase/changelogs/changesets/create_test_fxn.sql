--liquibase formatted sql

--changeset	venice.juanillas:test_create_fxn	context:general	splitStatements:false
CREATE OR REPLACE FUNCTION testfxn(testId integer,testName text,testDate date, OUT id integer) 
RETURNS integer AS $$
BEGIN
	insert into test(test_id, test_name, test_date)
	values(testId, testName, testDate);
	select lastval() into id;
END;
$$ LANGUAGE plpgsql;

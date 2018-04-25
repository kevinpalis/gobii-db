--Timescope Application Functions

--changeset kpalis:createtimescoper_wbcrypt context:general splitStatements:false runOnChange:true
CREATE OR REPLACE FUNCTION createTimescoper(_firstname text, _lastname text, _username text, _password text, _email text, _role integer, OUT id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO timescoper(firstname, lastname, username, password, email, role)
  	VALUES (_firstname, _lastname, _username, crypt(_password, gen_salt('bf', 8)), _email, _role)
  	ON conflict (username) DO NOTHING;
    select lastval() into id;
  END;
$$;


--changeset kpalis:gettimescoper_wbcrypt context:general splitStatements:false runOnChange:true
CREATE OR REPLACE FUNCTION getTimescoper(_username text, _password text) RETURNS TABLE(firstname text, lastname text, username text, email text, role integer)
	LANGUAGE plpgsql
	AS $$
	BEGIN
		RETURN QUERY
		SELECT t.firstname, t.lastname, t.username, t.email, t.role FROM timescoper as t WHERE t.username = _username AND t.password = crypt(_password, t.password);
	END;
$$;
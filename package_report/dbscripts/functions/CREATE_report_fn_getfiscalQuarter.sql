-- Function: getfiscalquarter(date)

-- DROP FUNCTION getfiscalquarter(date);

CREATE OR REPLACE FUNCTION getfiscalquarter(date)
  RETURNS integer AS
$BODY$
DECLARE _result TEXT;
BEGIN
	SELECT
		period_quarter INTO _result
	FROM period
	WHERE ($1 between period_start AND period_end);
	
	RETURN _result;
	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getfiscalquarter(date) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION getfiscalquarter(date) TO "admin";
GRANT EXECUTE ON FUNCTION getfiscalquarter(date) TO public;
GRANT EXECUTE ON FUNCTION getfiscalquarter(date) TO xtrole;
COMMENT ON FUNCTION getfiscalquarter(date) IS 'used to convert a date to fiscal quarter';

-- Function: _report.getfiscalquarter(date)

-- DROP FUNCTION _report.getfiscalquarter(date);

CREATE OR REPLACE FUNCTION _report.getfiscalquarter(date)
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
ALTER FUNCTION _report.getfiscalquarter(date) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION _report.getfiscalquarter(date) TO "admin";
GRANT EXECUTE ON FUNCTION _report.getfiscalquarter(date) TO public;
GRANT EXECUTE ON FUNCTION _report.getfiscalquarter(date) TO xtrole;
COMMENT ON FUNCTION _report.getfiscalquarter(date) IS 'used to convert a date to fiscal quarter';

-- Function: _report.getfiscalmonth(date)

-- DROP FUNCTION _report.getfiscalmonth(date);

CREATE OR REPLACE FUNCTION _report.getfiscalmonth(date)
  RETURNS integer AS
$BODY$
DECLARE _result TEXT;
BEGIN
	SELECT
		period_number INTO _result
	FROM period
	WHERE ($1 between period_start AND period_end);
	
	RETURN _result;
	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION _report.getfiscalmonth(date) OWNER TO admin;
GRANT EXECUTE ON FUNCTION _report.getfiscalmonth(date) TO admin;
GRANT EXECUTE ON FUNCTION _report.getfiscalmonth(date) TO public;
COMMENT ON FUNCTION _report.getfiscalmonth(date) IS 'Used to convert a date to fiscal month';

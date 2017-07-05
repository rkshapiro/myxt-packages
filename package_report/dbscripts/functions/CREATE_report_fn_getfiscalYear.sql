-- Function: _report.getfiscalyear(date)

-- DROP FUNCTION _report.getfiscalyear(date);

CREATE OR REPLACE FUNCTION _report.getfiscalyear(date)
  RETURNS integer AS
$BODY$
DECLARE _result TEXT;
BEGIN
	SELECT
	EXTRACT(year FROM yearperiod_end) INTO _result
	FROM period,yearperiod
	WHERE (period_yearperiod_id=yearperiod_id)
	AND ($1 between period_start AND period_end);

	RETURN _result;
END $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION _report.getfiscalyear(date)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION _report.getfiscalyear(date) TO public;
GRANT EXECUTE ON FUNCTION _report.getfiscalyear(date) TO admin;
GRANT EXECUTE ON FUNCTION _report.getfiscalyear(date) TO xtrole;
COMMENT ON FUNCTION _report.getfiscalyear(date) IS 'used for returning fiscal year Jul 2014 is FY 2015 and School Year 2014-15';

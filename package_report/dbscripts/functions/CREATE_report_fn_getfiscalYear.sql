-- Function: getfiscalyear(date)

-- DROP FUNCTION getfiscalyear(date);

CREATE OR REPLACE FUNCTION getfiscalyear(date)
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
ALTER FUNCTION getfiscalyear(date)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION getfiscalyear(date) TO public;
GRANT EXECUTE ON FUNCTION getfiscalyear(date) TO admin;
GRANT EXECUTE ON FUNCTION getfiscalyear(date) TO xtrole;
COMMENT ON FUNCTION getfiscalyear(date) IS 'used for returning fiscal year Jul 2014 is FY 2015 and School Year 2014-15';

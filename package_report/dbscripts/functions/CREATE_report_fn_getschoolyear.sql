-- Function: _report.getschoolyear(date)

-- DROP FUNCTION _report.getschoolyear(date);

CREATE OR REPLACE FUNCTION _report.getschoolyear(date)
  RETURNS char(9) AS
$BODY$
	DECLARE
	pdate ALIAS FOR $1;
	_yearend INTEGER;
	_yearstart INTEGER;

	BEGIN
	-- get the starting and ending year for the provided date 
	IF (date_part('month',pdate) < 7) then
		SELECT date_part('year',pdate) - 1 INTO _yearstart;
		SELECT date_part('year',pdate) INTO _yearend;
	ELSE
		SELECT date_part('year',pdate) INTO _yearstart;
		SELECT date_part('year',pdate) + 1 INTO _yearend;
	END IF;

	RETURN to_char(_yearstart,'9999')||'-'||to_char(_yearend,'9999');
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION _report.getschoolyear(date) OWNER TO mfgadmin;

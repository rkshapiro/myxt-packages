-- Function: isfinalsalequote(integer)

-- DROP FUNCTION isfinalsalequote(integer);

CREATE OR REPLACE FUNCTION isfinalsalequote(integer)
  RETURNS boolean AS
$BODY$
DECLARE
  pquheadid ALIAS FOR $1;
BEGIN

PERFORM * FROM quhead
WHERE (UPPER(quhead_shipcomments) ~ 'SALE' OR UPPER(quhead_custponumber) ~ 'SALE')
AND quhead_id = pquheadid;

IF (FOUND) THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;

END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION isfinalsalequote(integer) OWNER TO "admin";
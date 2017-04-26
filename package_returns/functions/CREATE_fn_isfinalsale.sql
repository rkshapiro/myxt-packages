-- Function: isfinalsale(integer)

-- DROP FUNCTION isfinalsale(integer);

CREATE OR REPLACE FUNCTION isfinalsale(integer)
  RETURNS boolean AS
$BODY$
DECLARE
  pcoheadid ALIAS FOR $1;
BEGIN

PERFORM * FROM cohead
WHERE (upper(cohead_custponumber) ~ 'SALE' OR upper(cohead_shipcomments) ~ 'SALE') AND cohead_id = pcoheadid;

IF (FOUND) THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;

END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION isfinalsale(integer)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION _isfinalsale(integer) TO admin;
GRANT EXECUTE ON FUNCTION isfinalsale(integer) TO public;
COMMENT ON FUNCTION isfinalsale(integer) IS 'rule to identify final sale sales orders';

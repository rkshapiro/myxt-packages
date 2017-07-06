-- Function: getpriorrevid(text, integer, date)

-- DROP FUNCTION getpriorrevid(text, integer, date);

CREATE OR REPLACE FUNCTION getpriorrevid(
    text,
    integer,
    date)
  RETURNS integer AS
$BODY$
DECLARE
  pTargetType ALIAS FOR $1;
  pTargetid ALIAS FOR $2;
  pRevDate ALIAS FOR $3;
  _revid INTEGER;
  _activedate DATE;
  _inactivedate DATE;

BEGIN
  --See if revcontrol turned on
  IF (fetchmetricbool('RevControl')) THEN
  
    IF (pTargetType <> 'BOO' AND pTargetType <> 'BOM') THEN
	   RAISE EXCEPTION 'Invalid Revision Type';
    END IF;

    IF (pTargetType='BOM') THEN
	  SELECT rev_id INTO _revid
	  FROM rev
	  WHERE rev_target_type='BOM'
	      AND rev_target_id=pTargetid
	      AND rev_status = 'A'
		  AND pRevDate >= rev_effective;
		  
	  IF (NOT FOUND) THEN
		SELECT MAX(rev_id) INTO _revid
		FROM rev
		WHERE rev_target_type='BOM'
			AND rev_target_id=pTargetid
			AND rev_status = 'I'
			AND pRevDate >= rev_effective;
	  END IF;  
	END IF;

    IF (pTargetType='BOO') THEN
		  SELECT max(rev_id) INTO _revid
		  FROM rev
		  WHERE (
			  (rev_target_type='BOO')
			  AND (rev_target_id=pTargetid)
			  AND rev_status !='P'
			  AND rev_effective <= pRevDate      
		  );
    END IF;
  END IF;
  RETURN COALESCE(_revid,-1);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getpriorrevid(text, integer, date)
  OWNER TO mfgadmin;
GRANT EXECUTE ON FUNCTION getpriorrevid(text, integer, date) TO mfgadmin;
GRANT EXECUTE ON FUNCTION getpriorrevid(text, integer, date) TO public;

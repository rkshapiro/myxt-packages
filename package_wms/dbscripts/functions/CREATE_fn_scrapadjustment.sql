-- Function:  scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying)

-- DROP FUNCTION  scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION  scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying)
  RETURNS integer AS
$BODY$
DECLARE
pitemnumber		ALIAS FOR $1;
pwarehouscode 		ALIAS FOR $2;
pqty			ALIAS FOR $3;
pordernumber		ALIAS FOR $4; -- order number-line number
plpnumber		ALIAS FOR $5;
puser			ALIAS FOR $6;
_invhistid		INTEGER;
_invhistidNew		INTEGER;

-- 20140306:jjb the SI call to inventoryadjustment no longer sends over a negative quantity (it was found to be adding onto the QOH After column in the Inventory History screen)

BEGIN 

	SELECT  _wms.inventoryadjustment(pitemnumber, pwarehouscode, 'AD', pqty, pordernumber, plpnumber, puser, NULL) INTO _invhistid;
	SELECT  _wms.inventoryadjustment(pitemnumber, pwarehouscode, 'SI', pqty, pordernumber, plpnumber, puser, _invhistid) INTO _invhistidNew;
	RETURN _invhistidNew;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION  scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION  scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying) TO "admin";
GRANT EXECUTE ON FUNCTION  scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying) TO xtrole;

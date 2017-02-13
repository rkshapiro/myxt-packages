-- Function:  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer)

-- DROP FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer)
  RETURNS integer AS
$BODY$
DECLARE
pitemnumber		ALIAS FOR $1;
pwarehouscode 		ALIAS FOR $2;
ptrxtype		ALIAS FOR $3; -- [PU = +AD | SD = SI | CC = CC | PK = -AD | TT = -AD]
pqty			ALIAS FOR $4;
pordernumber		ALIAS FOR $5; -- order number-line number
plpnumber		ALIAS FOR $6;
puser			ALIAS FOR $7;
pinvhistid		ALIAS FOR $8;


BEGIN 

-- 20130823:rks	Warehouse Management System Integration function to record inventory adjustments
--				returns the invhist_id for the transaction 
-- 20120826:rks moved WMS detail to GL reference 
-- 20130911:jjb added support for scrap
-- 20130911:jjb made the comment change based on transaction type
-- 20130911:jjb changed input param from item_location_series to inventory_history_id
-- 20140421:jjb writes CC-specific comment for a CC adjustment
-- 20140422:jjb comment says 'at location' instead of 'on LP #' when it is a CC transaction
-- 20140627:jjb Split out  inventoryadjustment() to two functions. This one is now an empty shell that calls the  inventoryadjustment() function with 9 parameters. 


RETURN  _wms.inventoryadjustment(pitemnumber, pwarehouscode, ptrxtype, pqty, pordernumber, plpnumber, puser, pinvhistid, null);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer) TO "admin";
GRANT EXECUTE ON FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer) TO xtrole;

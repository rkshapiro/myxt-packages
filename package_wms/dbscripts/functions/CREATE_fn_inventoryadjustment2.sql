-- Function:  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer)

-- DROP FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer)
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
pitemlocseries		ALIAS FOR $9;
_itemlocSeries		INTEGER;
_r			RECORD;
_invhistidNew		INTEGER;
_result			BOOLEAN;
_comment		text;

BEGIN 

-- 20140627:jjb Split out  inventoryadjustment() to two functions. This one handles the pitemlocseries. 
--              If pitemlocseries isn't null, we ignore whatever was passed in as pinvhistid and use pitemlocseries directly.
              


-- get the itemsite_id
SELECT itemsite_id,costcat_asset_accnt_id,costcat_liability_accnt_id,item_number,item_id INTO _r
FROM itemsite
JOIN item ON itemsite_item_id = item_id
JOIN whsinfo ON itemsite_warehous_id = warehous_id
JOIN costcat ON itemsite_costcat_id = costcat_id
WHERE item_number = pitemnumber
AND warehous_code = pwarehouscode;

-- Determine the item location series.
IF (pitemlocseries IS NOT NULL) THEN
	_itemlocSeries = pitemlocseries;	
ELSE 
	-- We are going make a determination on what to do based on pinvhistid.
	IF (pinvhistid IS NOT NULL) THEN
		SELECT invhist_series INTO _itemlocSeries
		FROM invhist
		WHERE invhist_id=pinvhistid;
	ELSE
		SELECT NEXTVAL('itemloc_series_seq') INTO _itemlocSeries;
	END IF;
END IF;

-- construct the comment that will be used in postinvtrans
IF (ptrxtype='SI') THEN
	IF (pqty<0) THEN
		_comment = 'WMS Reverse Material Scrap';
	ELSE
		_comment = 'WMS Material Scrap';
	END IF;
ELSIF (ptrxtype='CC') THEN
        _comment = 'WMS Cycle Count';
ELSE
	_comment = 'WMS Adjustment';
END IF;

IF (ptrxtype='CC') THEN
	_comment = _comment || ' for item '||_r.item_number||' by '||puser||' at location '||plpnumber; 
ELSE
	_comment = _comment || ' for item '||_r.item_number||' by '||puser||' on LP#'||plpnumber;
END IF;


-- post the inventory transaction that will always be an Adjustment to Inventory Material
SELECT postinvtrans(
_r.itemsite_id,
ptrxtype::text,
pqty,
'I/M'::text,
ptrxtype::text,		-- OrderType 
pordernumber::text,
pordernumber::text,
_comment::text,
_r.costcat_asset_accnt_id,
_r.costcat_liability_accnt_id,
_itemlocSeries) INTO _invhistidNew;	

SELECT postitemlocseries(_itemlocSeries) INTO _result;

RETURN _invhistidNew;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer) TO "admin";
GRANT EXECUTE ON FUNCTION  inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer) TO xtrole;

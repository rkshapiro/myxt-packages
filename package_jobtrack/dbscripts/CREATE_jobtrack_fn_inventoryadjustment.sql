-- Function: _jobtrack.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer)

DROP FUNCTION IF EXISTS _jobtrack.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION _jobtrack.inventoryadjustment(pitemnumber character varying, pwarehouscode character varying, ptrxtype character varying, pqty numeric, pordernumber character varying, pjobnumber character varying, puser character varying,source character varying, pinvhistid integer, pitemlocseries integer DEFAULT NULL::integer)
  RETURNS integer AS
$BODY$
DECLARE
_itemlocSeries		INTEGER;
_r			RECORD;
_invhistidNew		INTEGER;
_result			BOOLEAN;
_comment		text;

BEGIN 

-- 20170117 inital version for _jobtrack integration
-- ptrxtype	values [+AD | SI | CC | -AD | -AD]
-- pordernumber	is order number-line number
-- TBD add location specifics
              
-- get the itemsite_id
SELECT itemsite_id,costcat_asset_accnt_id,costcat_adjustment_accnt_id,item_number,item_id INTO _r
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
		_comment = trim(both from source)||' Reverse Material Scrap';
	ELSE
		_comment = trim(both from source)||' Material Scrap';
	END IF;
ELSIF (ptrxtype='CC') THEN
        _comment = trim(both from source)||' Cycle Count';
ELSE
	_comment = trim(both from source)||' Adjustment';
END IF;

IF (ptrxtype='CC') THEN
	_comment = _comment || ' for item '||_r.item_number||' by '||puser||' at location '||pjobnumber; 
ELSE
	_comment = _comment || ' for item '||_r.item_number||' by '||puser||' on Job#'||pjobnumber;
END IF;


-- post the inventory transaction that will always be an Adjustment to Inventory Material
SELECT postinvtrans(
_r.itemsite_id,
ptrxtype::text, -- AD, CC, SI
pqty,
'I/M'::text,
ptrxtype::text,		-- OrderType 
pordernumber::text, -- order number
pordernumber::text, -- doc number
_comment::text,
_r.costcat_asset_accnt_id,
_r.costcat_adjustment_accnt_id,
_itemlocSeries) INTO _invhistidNew;	

SELECT postitemlocseries(_itemlocSeries) INTO _result; -- calls postinvhist that updates itemsite_qtyonhand

RETURN _invhistidNew;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION _jobtrack.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, integer, integer) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION _jobtrack.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION _jobtrack.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, integer, integer) TO "admin";
GRANT EXECUTE ON FUNCTION _jobtrack.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, integer, integer) TO xtrole;

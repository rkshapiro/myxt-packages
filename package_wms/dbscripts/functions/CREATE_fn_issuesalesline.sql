-- Function:  issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer)

-- DROP FUNCTION  issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION  issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer)
  RETURNS integer AS
$BODY$
DECLARE
_line_number		ALIAS FOR $1; 
_line_subnumber		ALIAS FOR $2; 
_warehouse_code		ALIAS FOR $3;
_quantity		ALIAS FOR $4;
_order_number		ALIAS FOR $5;
_license_plate_number	ALIAS FOR $6;
_user			ALIAS FOR $7; 
_inventory_history_id	ALIAS FOR $8; -- This will be NULL the first time we pass in a line that has previously not been recorded in the invhist table.
_itemlocSeries		INTEGER;
_r			RECORD;
_itemlocSeries_NEW	INTEGER;
_shiphead_number	CHARACTER VARYING;
_result			BOOLEAN;
_coitem_id		INTEGER;
_item_type		text;
_item_number		text;
_inventory_history_id_NEW		INTEGER;

BEGIN 

-- 20140708:rks changed postitemlocseries to pass in _itemlocseries_new instead of _inventory_history_id_new
-- 20140626:jjb Fixed a bug where we were passing the itemLocSeries to  inventoryadjustment() when it should have been inventory_history_id (the inputs on
--              that function had changed and this function wasn't updated to include that change)
-- 20140625:jjb Fixed a bug where you got a 'Transaction series must be provided' error or put dirty data in the database if you sent in a null for the last parameter.
-- 20140515:jjb Fixed a bug where it wasn't filling in the actual _item_number variable before calling inventoryadjustment().
-- 20140514:jjb Fixed a bug where it it was required to have a SELECT have an object to put something into.
-- 20140514:jjb Rege indicated that the positive inventoryadjustment() call needs to happen for ALL items, not just manufactured ones.
-- 20140513:jjb Incorporates WIP RAID Log #58 "Issue to Ship call from StepLogic needs modified" -- increments inventory if item_type is manufactured
-- 20140206:jjb Function now takes in line subnumber, which previously wasn't there
-- 20140130:jjb Function now takes in line number (not item number) and deals with it appropriately

-- Determine the coitem id based on the line number and order number.
SELECT coitem_id INTO _coitem_id
FROM coitem
WHERE coitem_linenumber=_line_number AND coitem_subnumber=_line_subnumber AND coitem_cohead_id=(SELECT cohead_id FROM cohead WHERE cohead_number=_order_number);


-- Call  inventoryadjustment(), which will be positive adjustment of the item in the xTuple ASSET1 site.
-- Normally, we'd get back the xTuple inventory history record ID, but we don't care about it in this instance.
-- Whatever inventory history record ID the caller passed into issuesalesline is the one we're going to go with.
-- First, get the item number, which we'll need to pass into inventoryadjustment().
SELECT item_number INTO _item_number
FROM cohead
JOIN coitem ON cohead_id=coitem_cohead_id
JOIN itemsite ON coitem_itemsite_id=itemsite_id
JOIN item ON itemsite_item_id=item_id
WHERE cohead_number=_order_number AND coitem_linenumber=_line_number AND coitem_subnumber=_line_subnumber;


SELECT  inventoryadjustment(
				_item_number::character varying(255),			-- item_number
				_warehouse_code,					-- warehouse_code
				'AD'::character varying(255),				-- transaction_type
				_quantity,						-- quantity 
				_order_number::character varying(255),			-- order_number
				_license_plate_number,					-- license_plate_number
				_user,							-- user
				_inventory_history_id					-- inventory_history_id
			       ) INTO _inventory_history_id_NEW;


-- Now get the itemlocSeries for whatever the new history ID is.
SELECT invhist_series INTO _itemlocSeries
FROM invhist
WHERE invhist_id=_inventory_history_id_NEW;


SELECT issuetoshipping(
'SO'::text,
_coitem_id::integer,
_quantity,
_itemlocSeries,
CURRENT_TIMESTAMP,
_inventory_history_id_NEW) INTO _itemlocSeries_NEW;

IF (_itemlocSeries_NEW>0) THEN
    -- issuetoshipping() executed correctly.
    SELECT postitemlocseries(_itemlocSeries_NEW) INTO _result;
    -- TODO: THROW EXCEPTION IF _result <> TRUE
ELSE
    -- TODO: THROW EXCEPTION
END IF;


-- Get the most recently-inserted shiphead record
SELECT shiphead_id, shiphead_number, shiphead_notes FROM shiphead
ORDER BY shiphead_id DESC LIMIT 1 INTO _r;

-- There is no log for shipping information so we're going to store our log info in the shiphead_notes field.
-- Note that we're doing a concatenation of what's already there just in case if something went horribly wrong
-- with issuetoshipping() and the most recently-inserted record we pull back isn't the correct record.
-- Then, at the very least, we won't overwrite anything that's already in the shiphead_notes field.

UPDATE shiphead
SET shiphead_notes='From WMS on ' || CURRENT_TIMESTAMP  || ' by ' || _user || ' from ' || _license_plate_number || '.' || E'\n' || _r.shiphead_notes
WHERE shiphead_id=_r.shiphead_id;

RETURN _r.shiphead_number;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION  issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION  issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer) TO "admin";
GRANT EXECUTE ON FUNCTION  issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer) TO xtrole;

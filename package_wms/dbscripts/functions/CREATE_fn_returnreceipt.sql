-- Function:  returnreceipt(character varying, integer, integer, character varying, character varying, numeric, character varying, character varying)

-- DROP FUNCTION  returnreceipt(character varying, integer, integer, character varying, character varying, numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION  returnreceipt(_ra_number character varying, _raline_number integer, _raline_subnumber integer, _asset_item_number character varying, 
					      _warehouse_code character varying, _qty_received numeric, _user character varying, _lp_number character varying)
  RETURNS integer AS
$BODY$

DECLARE
	_recv_id INTEGER;
	_retVal INTEGER;
	_item_location_series INTEGER;
	_invhist_id INTEGER;
	_r RECORD;
	_result BOOLEAN;

BEGIN
	-- 20130911:jjb calls postinvtrans 
	-- 20130911:jjb the call to wms inventoryadjustment sends the invhist_id not the item_location_series like before
	-- 20130913:jjb removed the unnecessary call to postinvtrans
	-- 20130913:jjb fixed the QOH Before value being wrong -- needed to call postitemlocseries

	-- get the itemsite_id
	SELECT itemsite_id,costcat_asset_accnt_id,costcat_liability_accnt_id,item_number,item_id INTO _r
	FROM itemsite
	JOIN item ON itemsite_item_id = item_id
	JOIN whsinfo ON itemsite_warehous_id = warehous_id
	JOIN costcat ON itemsite_costcat_id = costcat_id
	WHERE item_number = _asset_item_number
	AND warehous_code = _warehouse_code;

	-- Note that unlike the very similar function  purchasereceipt() we do not need to multiply the quantity by any sort of UOM
	-- On ASSETs side our UOM is always 1

	-- Call enterreceipt() to create the recv table record.
	SELECT enterreceipt(
	                    'RA',								-- pordertype
		            (SELECT raitem_id
			      FROM raitem 
				JOIN rahead ON raitem.raitem_rahead_id=rahead.rahead_id
			      WHERE rahead_number=_ra_number AND 
				    raitem_linenumber=_raline_number AND 
				    raitem_subnumber=_raline_subnumber
			    ),									-- porderitemid
			    _qty_received, 							-- pQty
			    0.0,								-- pFreight
			    'Receipt of RA #' || _ra_number || ' for LP ' || 
				_lp_number || ' by ' || _user,					-- pNotes    
			    _raline_number,							-- pcurrid
			    CAST(to_char(current_timestamp, 'MM/DD/YYYY') AS DATE)		-- precvdate	
			   ) 
	INTO _retVal;										-- returns recv_id

	-- Make sure we created a recv table record.
	IF _retVal <= 0 THEN 
		RETURN 0;	
	END IF;

	-- Call postreceipts(), which will read from the recv table and will call postInvTrans().
	SELECT postreceipts(
			    'RA',								-- pordertype
			      (SELECT rahead_id 
			       FROM rahead
			       WHERE rahead_number=_ra_number
			      ),								-- porderid
			    NULL								-- _itemlocSeries
			   )
	INTO _item_location_series;								-- returns _itemlocSeries
	
	-- Make sure we got back a legitimate record.
	IF _item_location_series <= 0 THEN 
		RETURN 0;	
	END IF;

	SELECT postitemlocseries(_item_location_series) INTO _result; -- Must do this, otherwise itemsite.itemsite_qtyonhand will not be correct.

	-- Call  inventoryadjustment(), which will be positive adjustment of the item in the xTuple ASSET1 site.
	SELECT  inventoryadjustment(
					(SELECT item_number::character varying(255)
					 FROM raitem 
					 JOIN itemsite ON raitem.raitem_itemsite_id=itemsite_id
						INNER JOIN item ON itemsite_item_id=item_id
					 JOIN rahead ON raitem.raitem_rahead_id=rahead.rahead_id
				         WHERE rahead_number=_ra_number AND 
 					       raitem_linenumber=_raline_number AND 
					       raitem_subnumber=_raline_subnumber						 
					),							-- item_number
					_warehouse_code,					-- warehouse_code
					'AD'::character varying(255),				-- transaction_type 
					-(_qty_received),					-- quantity
					_ra_number || '-' || _raline_number::character varying(255),	-- order_number
					_lp_number,						-- license_plate_number
					_user,							-- user
					null,							-- invhistid (we don't know what that value is within this function)
					_item_location_series					-- item_location_series
				       )
	INTO _retVal;										-- Returns xTuple Inventory History record ID

	-- Make sure we created a xTuple Inventory History record.
	IF _retVal <= 0 THEN 
		RETURN 0;	
	END IF;


	-- Success!
	RETURN _retVal;										
END;	

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION  returnreceipt(character varying, integer, integer, character varying, character varying, numeric, character varying, character varying) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  returnreceipt(character varying, integer, integer, character varying, character varying, numeric, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION  returnreceipt(character varying, integer, integer, character varying, character varying, numeric, character varying, character varying) TO "admin";
GRANT EXECUTE ON FUNCTION  returnreceipt(character varying, integer, integer, character varying, character varying, numeric, character varying, character varying) TO xtrole;

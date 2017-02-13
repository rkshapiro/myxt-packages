-- Function:  purchasereceipt(character varying, integer, character varying, character varying, numeric, character varying, character varying)

-- DROP FUNCTION  purchasereceipt(character varying, integer, character varying, character varying, numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION  purchasereceipt(_po_number character varying, _poline_number integer, _asset_item_number character varying, _warehouse_code character varying, _qty_received numeric, _user character varying, _lp_number character varying)
  RETURNS integer AS
$BODY$

DECLARE
	_recv_id INTEGER;
	_retVal INTEGER;
	_item_location_series INTEGER;
	_invhist_id INTEGER;
	_r RECORD;
	_result BOOLEAN;
	_poitem_invvenduomratio NUMERIC(16,9);

BEGIN
	-- 20130911:jjb calls postinvtrans 
	-- 20130911:jjb the call to wms inventoryadjustment sends the invhist_id not the item_location_series like before
	-- 20130912:jjb we now multiply the quantity by the poitem_invvenduomratio 
	-- 20130912:jjb fixed the QOH Before value being wrong -- needed to call postitemlocseries


	-- get the itemsite_id
	SELECT itemsite_id,costcat_asset_accnt_id,costcat_liability_accnt_id,item_number,item_id INTO _r
	FROM itemsite
	JOIN item ON itemsite_item_id = item_id
	JOIN whsinfo ON itemsite_warehous_id = warehous_id
	JOIN costcat ON itemsite_costcat_id = costcat_id
	WHERE item_number = _asset_item_number
	AND warehous_code = _warehouse_code;

	-- get _poitem_invvenduomratio
	-- TODO: Optimization: Take the stuff we are pulling from poitem into a record so we only call it once
	SELECT poitem_invvenduomratio INTO _poitem_invvenduomratio
	FROM poitem 
		JOIN pohead ON poitem.poitem_pohead_id=pohead.pohead_id
	WHERE poitem_linenumber=_poline_number AND pohead_number=_po_number;


	-- Call enterporeceipt() to create the recv table record.
	SELECT enterporeceipt(
			      (SELECT poitem_id
			       FROM poitem 
					JOIN pohead ON poitem.poitem_pohead_id=pohead.pohead_id
			       WHERE poitem_linenumber=_poline_number AND pohead_number=_po_number
			       ),								-- porderitemid
			      _qty_received, 							-- pQty
			      0.0,								-- pFreight
			      'Receipt of PO #' || _po_number || ' for LP ' || 
					_lp_number || ' by ' || _user,				-- pNotes    
			      _poline_number,							-- pcurrid
			      CAST(to_char(current_timestamp, 'MM/DD/YYYY') AS DATE)		-- precvdate	
			      ) 
	INTO _retVal;										-- Returns recv_id

	-- Make sure we created a recv table record.
	IF _retVal <= 0 THEN 
		RETURN 0;	
	END IF;

	-- Call postporeceipts(), which will read from the recv table and will call postInvTrans().
	SELECT postporeceipts(
			      (SELECT pohead_id 
			       FROM pohead
			       WHERE pohead_number=_po_number
			      )									-- porderid
			     )
	INTO _item_location_series;								-- _itemlocSeries
	
	-- Make sure we got back a legitimate record.
	IF _item_location_series <= 0 THEN 
		RETURN 0;	
	END IF;

	SELECT postitemlocseries(_item_location_series) INTO _result; -- Must do this, otherwise itemsite.itemsite_qtyonhand will not be correct.


	-- Call  inventoryadjustment(), which will be positive adjustment of the item in the xTuple ASSET1 site.
	SELECT  inventoryadjustment(
					(SELECT item_number::character varying(255)
					 FROM poitem 
					 JOIN itemsite ON poitem.poitem_itemsite_id=itemsite_id
						INNER JOIN item ON itemsite_item_id=item_id
					 JOIN pohead ON poitem.poitem_pohead_id=pohead.pohead_id
				         WHERE poitem_linenumber=_poline_number AND pohead_number=_po_number
					),							-- item_number
					_warehouse_code,					-- warehouse_code
					'AD'::character varying(255),				-- transaction_type
					-(_qty_received * _poitem_invvenduomratio),		-- quantity (We must multiply by the vendor uom ratio here)
					_po_number || '-' || _poline_number::character varying(255),	-- order_number
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
ALTER FUNCTION  purchasereceipt(character varying, integer, character varying, character varying, numeric, character varying, character varying) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  purchasereceipt(character varying, integer, character varying, character varying, numeric, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION  purchasereceipt(character varying, integer, character varying, character varying, numeric, character varying, character varying) TO "admin";
GRANT EXECUTE ON FUNCTION  purchasereceipt(character varying, integer, character varying, character varying, numeric, character varying, character varying) TO xtrole;
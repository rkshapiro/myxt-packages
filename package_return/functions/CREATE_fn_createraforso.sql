-- Function: createraforso(integer)

-- DROP FUNCTION createraforso(integer);

CREATE OR REPLACE FUNCTION createraforso(integer)
  RETURNS integer AS
$BODY$
DECLARE
 pSoheadid ALIAS FOR $1;
  _raheadid INTEGER;
  _raitemid INTEGER;
  --_incdtid INTEGER; removed FY2013
  _orderid INTEGER;
  _ordertype CHARACTER(1);
  _creditstatus	TEXT;
  _usespos BOOLEAN := false;
  _blanketpos BOOLEAN := true;
  _showConvertedQuote BOOLEAN := false;
  _prospectid	INTEGER;
  _r RECORD;
  _i RECORD;
  _raNum TEXT;
  _inNum INTEGER;
  _return_warehous_id INTEGER;
  _ralinenumber INTEGER;

  -- rks:20121016
  -- modified for FY2013 sales order processing
  -- removed incident creation and relationships
  -- added raitem_orig_coitem_id to relate RA to SO for reporting
  -- added rahead_new_cohead_id to allow the SO to be opened from the RA in the RA screen
BEGIN

--  Check to make sure that all of the so items have a valid DISASSEMBLY itemsite 
  SELECT coitem_id INTO _r
    FROM coitem 
    JOIN itemsite ON coitem_itemsite_id=itemsite_id
    join item on itemsite_item_id = item_id
	join costcat on itemsite_costcat_id = costcat_id
   WHERE coitem_cohead_id= pSoheadid
     AND item_id NOT in (
     select itemsite_item_id
     from itemsite
     join whsinfo on itemsite_warehous_id = warehous_id
     join item on itemsite_item_id = item_id
     where warehous_code = 'DISASSEMBLY'
     AND itemsite_active = true
     order by itemsite_item_id
     )and item_type <> 'K'
     and costcat_code = 'MODULES FOR LEASE' -- Modules for lease is ID 37
     -- and item_prodcat_id <> 51		-- training materials go to ASSET1
     AND coitem_status <> 'X';  -- include closed for FY2013 exclude canceled
     
  IF (FOUND) THEN
    INSERT INTO evntlog (evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                         evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number)
    SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
           'S', cohead_id, cohead_warehous_id, cohead_number
    FROM evntnot, evnttype, cohead
    WHERE ( (evntnot_evnttype_id=evnttype_id)
     AND (evntnot_warehous_id=cohead_warehous_id)
     AND (evnttype_name='CannotConvertSOtoRA')
     AND (cohead_id=pSoheadid) );

    RETURN -1;
  END IF;

  SELECT cust_creditstatus, cust_usespos, cust_blanketpos
    INTO _creditstatus, _usespos, _blanketpos
  FROM cohead, custinfo
  WHERE ((cohead_cust_id=cust_id)
    AND  (cohead_id=pSoheadid));
  
  PERFORM rahead_number, cohead_id 
  FROM rahead, cohead 
  WHERE cohead_id = pSoheadid
  AND cohead_number = rahead_number
  AND rahead_cust_id = cohead_cust_id;

-- Determine the RA number

  IF (FOUND) THEN
      INSERT INTO evntlog (evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                         evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number)
    SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
           'S', cohead_id, cohead_warehous_id, cohead_number
    FROM evntnot, evnttype, cohead
    WHERE ( (evntnot_evnttype_id=evnttype_id)
     AND (evntnot_warehous_id=cohead_warehous_id)
     AND (evnttype_name='DuplicateRANumber')
     AND (cohead_id=pSoheadid) );
    RETURN -99;
    -- Fail if an RA exists with the same number as the SO number
    -- SELECT fetchRaNumber() INTO _raNum;
  ELSE
    SELECT cohead_number INTO _raNum
    FROM cohead
    WHERE cohead_id = pSoheadid;
  END IF;

   -- return all leased product to the Disassembly site for FY2013
   SELECT warehous_id INTO _return_warehous_id
   FROM whsinfo
   WHERE warehous_code = 'DISASSEMBLY';

-- Create the RA header

  SELECT NEXTVAL('rahead_rahead_id_seq') INTO _raheadid;
  INSERT INTO rahead
  ( --rahead_incdt_id,  removed FY2013
    rahead_new_cohead_id,  --added FY2013  Adding cohead_id activates trigger that moves all SO lines to RA
    rahead_creditmethod, 
    rahead_timing, 
    rahead_disposition,
    rahead_headcredited, 
    rahead_printed, 
    rahead_id, 
    rahead_number, 
    rahead_cust_id,
    rahead_authdate, 
    rahead_expiredate,
    rahead_custponumber, 
    rahead_warehous_id, 
    rahead_cohead_warehous_id,
    rahead_billtoname, 
    rahead_billtoaddress1,
    rahead_billtoaddress2, 
    rahead_billtoaddress3,
    rahead_billtocity, 
    rahead_billtostate, 
    rahead_billtozip,
    rahead_billtocountry,
    rahead_shipto_id, 
    rahead_shipto_name, 
    rahead_shipto_address1,
    rahead_shipto_address2, 
    rahead_shipto_address3,
    rahead_shipto_city, 
    rahead_shipto_state, 
    rahead_shipto_zipcode,
    rahead_shipto_country,
    rahead_salesrep_id, 
    rahead_commission,
    rahead_notes, 
    rahead_freight, 
    rahead_misc, 
    rahead_misc_descrip,
    rahead_prj_id, 
    rahead_curr_id, 
    rahead_taxzone_id, 
    rahead_taxtype_id)

  SELECT pSoheadid, --_incdtid, changed FY2013
         'N',
         'I',
         'R',
         'f',
         'f',
         _raheadid, 
         _raNum, 
         cohead_cust_id,
         CURRENT_DATE,
         -- Base the expiration date on the return date on the order or 63 days from the scheduled date.
		 -- Base the expiration date on the return date on the item rental period from the scheduled date.
		( -- expiration date is end of fiscal year FY2013
		SELECT  distinct yearperiod_end
        FROM coitem,yearperiod
        WHERE (coitem_cohead_id=pSoheadid)
        AND (
		SELECT min(coitem_scheddate)
		FROM coitem
		WHERE (coitem_cohead_id=pSoheadid)
		AND (coitem_status <> 'X') ) between yearperiod_start and yearperiod_end
		),
	     cohead_custponumber,
         _return_warehous_id,
		cohead_warehous_id, 
         cohead_billtoname, 
         cohead_billtoaddress1,
         cohead_billtoaddress2, 
         cohead_billtoaddress3,
         cohead_billtocity, 
         cohead_billtostate, 
         cohead_billtozipcode,
         cohead_billtocountry,
         cohead_shipto_id, 
         cohead_shiptoname, 
         cohead_shiptoaddress1,
         cohead_shiptoaddress2, 
         cohead_shiptoaddress3,
         cohead_shiptocity, 
         cohead_shiptostate, 
         cohead_shiptozipcode,
         cohead_shiptocountry,
         cohead_salesrep_id, 
         cohead_commission,
         cohead_shipcomments,
         0, 
         0, 
         '',
         cohead_prj_id, 
         cohead_curr_id, 
         cohead_taxzone_id, 
         cohead_taxtype_id

FROM cohead 
JOIN custinfo ON (cust_id=cohead_cust_id)
WHERE (cohead_id = pSoheadid)
;

-- add the restriction on the item below
  _ralinenumber = 0;
  FOR _r IN SELECT coitem.*,
                   cohead_number, cohead_prj_id,
                   itemsite_item_id, itemsite_leadtime,
                   itemsite_createsopo, itemsite_createsopr,
                   item_type, item_id
            FROM cohead JOIN coitem ON (coitem_cohead_id=cohead_id)
                        JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
                        JOIN item ON (item_id=itemsite_item_id)
                        JOIN costcat ON (costcat_id = itemsite_costcat_id)
                        LEFT OUTER JOIN itemsrc ON ( (itemsrc_item_id=item_id) AND
                                                     (itemsrc_default) )
            WHERE (cohead_id=pSoheadid) 
                  AND (item_type <> 'K')  -- ignore kits on the ra lines
                  AND (costcat_code = 'MODULES FOR LEASE') -- Modules for lease is ID 37 FY2013
                  AND coitem_status <> 'X'  -- include closed lines for FY2013
            LOOP
    _ralinenumber = _ralinenumber + 1;
    SELECT NEXTVAL('raitem_raitem_id_seq') INTO _raitemid;
    INSERT INTO raitem
    ( raitem_disposition, raitem_rsncode_id,
      raitem_id, raitem_rahead_id, 
      raitem_linenumber, 
      raitem_itemsite_id,
      raitem_scheddate,
      raitem_unitprice, raitem_saleprice, 
      raitem_qtyauthorized, 
      raitem_qty_uom_id, raitem_qty_invuomratio,
      raitem_price_uom_id, raitem_price_invuomratio,
      raitem_unitcost, 
      raitem_notes, raitem_taxtype_id, 
	  raitem_orig_coitem_id)
    VALUES
    ( 'R',
	(SELECT rsncode_id
	FROM rsncode
	WHERE rsncode_code = 'END_OF_LEASE'),  -- Reason Code 5 End of lease  FY2012
      _raitemid, _raheadid, _ralinenumber, --_r.coitem_linenumber + _r.coitem_subnumber, 

      (
       SELECT itemsite_id FROM itemsite
       WHERE itemsite_item_id = _r.item_id
       AND itemsite_warehous_id = _return_warehous_id      
      ),
--
      _r.coitem_scheddate,
      0, 0,
      _r.coitem_qtyord, 
      _r.coitem_qty_uom_id, _r.coitem_qty_invuomratio,
      _r.coitem_price_uom_id, _r.coitem_price_invuomratio,
      stdcost(_r.itemsite_item_id),
      _r.coitem_memo, _r.coitem_taxtype_id,
		_r.coitem_id);

--     Insert Lines loop: END
  END LOOP;

  RETURN _raheadid;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION createraforso(integer) OWNER TO "admin";

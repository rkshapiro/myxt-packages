-- Function: itemsrcpupdate()

-- DROP FUNCTION itemsrcpupdate();

CREATE OR REPLACE FUNCTION itemsrcpupdate()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _x  RECORD;
  _match_itemsrcpupdate TEXT;
  _match_itemsrcp TEXT;
  _upd INTEGER := 0;
  _new INTEGER := 0;
 
 BEGIN
  
 FOR _r IN
 (
SELECT itemsrcpupdate_id, itemsrcpupdate_item_number, itemsrcpupdate_vend_number, 
       itemsrcpupdate_vend_item_number, itemsrcpupdate_effective, itemsrcpupdate_expires, 
       itemsrcpupdate_qtybreak, 
       CASE
        WHEN itemsrcpupdate_type = 'Discount' THEN 'D'
        ELSE 'N'::text
        END AS itemsrcpupdate_type, itemsrcpupdate_warehous_code, 
       itemsrcpupdate_dropship, itemsrcpupdate_price, 
       CASE WHEN itemsrcpupdate_curr IS NULL THEN basecurrid()
       ELSE getcurrid(itemsrcpupdate_curr)
       END AS _currid, 
       itemsrcpupdate_discntprcnt, itemsrcpupdate_fixedamtdiscount, 
       itemsrcpupdate_updated,item_id,vend_id,
       CASE
            WHEN itemsrcpupdate_warehous_code = 'All' THEN (-1)
            ELSE COALESCE(getwarehousid(itemsrcpupdate_warehous_code, 'ALL'), (-1))
        END AS warehous_id, itemsrc_id
  FROM xtupd.itemsrcpupdate
  JOIN item ON itemsrcpupdate_item_number = item_number
  JOIN vendinfo ON itemsrcpupdate_vend_number = vend_number
  JOIN itemsrc ON itemsrc_item_id = item_id AND itemsrc_vend_id = vend_id
  )
  
LOOP
    -- get the matching item source price row if existing
    SELECT itemsrcp_id, itemsrcp_itemsrc_id, itemsrcp_qtybreak, itemsrcp_price, 
       itemsrcp_updated, itemsrcp_curr_id, itemsrcp_dropship, itemsrcp_warehous_id, 
       itemsrcp_type, itemsrcp_discntprcnt, itemsrcp_fixedamtdiscount,
       itemsrc_item_id, itemsrc_vend_id, itemsrc_vend_item_number, 
       itemsrc_effective, itemsrc_expires INTO _x
    FROM itemsrcp
    JOIN itemsrc ON itemsrcp_itemsrc_id = _r.itemsrc_id
    WHERE trim(both from itemsrc_vend_item_number) = trim(both from _r.itemsrcpupdate_vend_item_number)
    AND itemsrc_expires > now();
    -- is this a new item source record?
    IF (NOT FOUND) THEN
    -- insert new record if all required fields are provided
      IF (_r.itemsrcpupdate_qtybreak IS NOT NULL
          AND _r.itemsrcpupdate_type IS NOT NULL
          AND _r.itemsrcpupdate_warehous_code IS NOT NULL
          AND _r.itemsrcpupdate_dropship IS NOT NULL) THEN
            INSERT INTO api.itemsourceprice
                (item_number, vendor, vendor_item_number, effective, expires, 
                qty_break, pricing_type, pricing_site, dropship_only, price_per_unit, 
                currency, discount_percent, discount_fixed_amount)
            VALUES (_r.itemsrcpupdate_item_number, _r.itemsrcpupdate_vend_number, 
            _r.itemsrcpupdate_vend_item_number, _r.itemsrcpupdate_effective, _r.itemsrcpupdate_expires, 
            _r.itemsrcpupdate_qtybreak, _r.itemsrcpupdate_type, _r.itemsrcpupdate_warehous_code, 
            _r.itemsrcpupdate_dropship, _r.itemsrcpupdate_price, _r.itemsrcpupdate_curr, 
            _r.itemsrcpupdate_discntprcnt, _r.itemsrcpupdate_fixedamtdiscount
            );
            _new := _new + 1;
       END IF;
    END IF;

    -- check for a change before updating
    _match_itemsrcpupdate = concat( 
       _r.itemsrcpupdate_vend_item_number, _r.itemsrcpupdate_effective, _r.itemsrcpupdate_expires, 
       _r.itemsrcpupdate_qtybreak, _r.itemsrcpupdate_type, _r.warehous_id, 
       _r.itemsrcpupdate_dropship, _r.itemsrcpupdate_price, _r._currid, 
       _r.itemsrcpupdate_discntprcnt, _r.itemsrcpupdate_fixedamtdiscount, 
       _r.item_id,_r.vend_id);
    _match_itemsrcp = concat(_x.itemsrc_vend_item_number, 
       _x.itemsrc_effective, _x.itemsrc_expires,
       _x.itemsrcp_qtybreak, _x.itemsrcp_type, _x.itemsrcp_warehous_id,
       _x.itemsrcp_dropship,_x.itemsrcp_price, _x.itemsrcp_curr_id,
       _x.itemsrcp_discntprcnt, _x.itemsrcp_fixedamtdiscount,
       _x.itemsrc_item_id, _x.itemsrc_vend_id);
    
    IF (_match_itemsrcpupdate <> _match_itemsrcp) THEN
      -- update item row
      UPDATE itemsrcp
       SET itemsrcp_qtybreak=coalesce(_r.itemsrcpupdate_qtybreak,_x.itemsrcp_qtybreak),
       itemsrcp_price=coalesce(_r.itemsrcpupdate_price,_x.itemsrcp_price),
       itemsrcp_updated=current_date, 
       itemsrcp_curr_id=coalesce(_r._currid,_x.itemsrcp_curr_id),
       itemsrcp_dropship=coalesce(_r.itemsrcpupdate_dropship,_x.itemsrcp_dropship),
       itemsrcp_warehous_id=coalesce(_r.warehous_id,_x.itemsrcp_warehous_id),
       itemsrcp_type=coalesce(_r.itemsrcpupdate_type,_x.itemsrcp_type),
       itemsrcp_discntprcnt=coalesce(_r.itemsrcpupdate_discntprcnt,_x.itemsrcp_discntprcnt),
       itemsrcp_fixedamtdiscount=coalesce(_r.itemsrcpupdate_fixedamtdiscount,_x.itemsrcp_fixedamtdiscount)
     WHERE itemsrcp_id = _x.itemsrcp_id;
      _upd := _upd + 1;
   END IF;
 
END LOOP;

   RETURN _upd||' rows updated '||_new||' rows created';
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION itemsrcpupdate()
  OWNER TO admin;
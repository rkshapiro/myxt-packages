-- Function: itemsrcupdate()

-- DROP FUNCTION itemsrcupdate();

CREATE OR REPLACE FUNCTION itemsrcupdate()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _x  RECORD;
  _match_itemsrcupdate TEXT;
  _match_itemsrc TEXT;
  _match_itemsrcpupdate TEXT;
  _match_itemsrcp TEXT;
  _upd INTEGER := 0;
  _new INTEGER := 0;
 
 BEGIN
  
 FOR _r IN
 (
  SELECT itemsrcupdate_id, itemsrcupdate_item_number, itemsrcupdate_vend_number, 
       itemsrcupdate_vend_item_number, itemsrcupdate_vend_item_descrip, 
       itemsrcupdate_comments, itemsrcupdate_vend_uom, itemsrcupdate_invvendoruomratio, 
       itemsrcupdate_minordqty, itemsrcupdate_multordqty, itemsrcupdate_leadtime, 
       itemsrcupdate_ranking, itemsrcupdate_active, itemsrcupdate_manuf_name, 
       itemsrcupdate_manuf_item_number, itemsrcupdate_manuf_item_descrip, 
       itemsrcupdate_default, itemsrcupdate_upccode, itemsrcupdate_contrct_number, 
       itemsrcupdate_effective, itemsrcupdate_expires,item_id,vend_id,
       itemsrcupdate_qtybreak, 
       itemsrcupdate_type,
       CASE
         WHEN itemsrcupdate_type = 'Discount' THEN 'D'
         ELSE 'N'::text
       END AS _type, 
       itemsrcupdate_pricing_site,
       CASE
         WHEN itemsrcupdate_pricing_site = 'All' THEN (-1)
         ELSE COALESCE(getwarehousid(itemsrcupdate_pricing_site, 'ALL'), (-1))
       END AS _warehous_id, 
       itemsrcupdate_dropship, itemsrcupdate_price, 
       itemsrcupdate_curr,
       CASE 
         WHEN itemsrcupdate_curr IS NULL THEN basecurrid()
         ELSE getcurrid(itemsrcupdate_curr)
       END AS _currid, 
       itemsrcupdate_discntprcnt, itemsrcupdate_fixedamtdiscount, 
       itemsrcupdate_updated,
       item_id, vend_id, itemsrc_id, itemsrcp_id
  FROM xtupd.itemsrcupdate
  JOIN item ON itemsrcupdate_item_number = item_number
  JOIN vendinfo ON itemsrcupdate_vend_number = vend_number
  LEFT JOIN itemsrc ON itemsrc_item_id = item_id AND itemsrc_vend_id = vend_id
  LEFT JOIN itemsrcp ON itemsrc_id = itemsrcp_itemsrc_id
  )
  
LOOP
    -- get the matching item source row if existing
    SELECT itemsrcupdate_item_number, itemsrcupdate_vend_number, itemsrcupdate_vend_item_number, 
       itemsrcupdate_active, itemsrcupdate_default, itemsrcupdate_vend_uom, 
       itemsrcupdate_invvendoruomratio, itemsrcupdate_minordqty, itemsrcupdate_multordqty, 
       itemsrcupdate_ranking, itemsrcupdate_leadtime, itemsrcupdate_comments, 
       itemsrcupdate_vend_item_descrip, itemsrcupdate_manuf_name, itemsrcupdate_manuf_item_number, 
       itemsrcupdate_manuf_item_descrip, itemsrcupdate_upccode, itemsrcupdate_contract_number, 
       itemsrcupdate_effective, itemsrcupdate_expires, itemsrcupdate_qtybreak, 
       itemsrcupdate_type, itemsrcupdate_pricing_site, itemsrcupdate_dropship, 
       itemsrcupdate_price, itemsrcupdate_curr, itemsrcupdate_discntprcnt, 
       itemsrcupdate_fixedamtdiscount, itemsrcupdate_itemsrcp_updated,
       item_id, vend_id, itemsrc_id, itemsrcp_id INTO _x
    FROM xtupd.itemsrcupdate_export
    JOIN item ON item_number = itemsrcupdate_item_number
    JOIN vendinfo ON vend_number = itemsrcupdate_vend_number
    LEFT JOIN itemsrc ON itemsrc_item_id = item_id
    LEFT JOIN itemsrc ON itemsrc_vend_id = vend_id
    LEFT JOIN itemsrcp ON itemsrcp_itemsrc_id = itemsrc_id;
    
    -- is this a new item source record?
    IF (itemsrc_id IS NULL) THEN
    -- insert new record if all required fields are provided
      IF (_r.itemsrcupdate_vend_item_number IS NOT NULL
          AND _r.itemsrcupdate_vend_uom IS NOT NULL
          AND _r.itemsrcupdate_invvendoruomratio IS NOT NULL) THEN
            INSERT INTO api.itemsource (item_number, vendor, vendor_item_number, 
            active,itemsrc_default,vendor_uom, inventory_vendor_uom_ratio, 
            minimum_order, order_multiple, 
            vendor_ranking, lead_time, notes, 
            vendor_description, manufacturer_name, 
            manufacturer_item_number, manufacturer_description, 
            bar_code,contract_number, effective_date,expires_date)
            VALUES (_r.itemsrcupdate_item_number, _r.itemsrcupdate_vend_number,_r.itemsrcupdate_vend_item_number,
            _r.itemsrcupdate_active,_r.itemsrcupdate_default, _r.itemsrcupdate_vend_uom,_r.itemsrcupdate_invvendoruomratio,
            _r.itemsrcupdate_minordqty, _r.itemsrcupdate_multordqty,
            _r.itemsrcupdate_ranking,_r.itemsrcupdate_leadtime,_r.itemsrcupdate_comments,
            _r.itemsrcupdate_vend_item_descrip, _r.itemsrcupdate_manuf_name,
            _r.itemsrcupdate_manuf_item_number,_r.itemsrcupdate_manuf_item_descrip, 
            _r.itemsrcupdate_upccode,_r.itemsrcupdate_contrct_number,_r.itemsrcupdate_effective, _r.itemsrcupdate_expires
            );
            _new := _new + 1;
        END IF;
     END IF; 

     -- check for a new pricing record
     If (itemsrcp_id IS NULL) THEN
     -- insert new record if all required fields are provided
       IF (_r.itemsrcpupdate_qtybreak IS NOT NULL
          AND _r.itemsrcupdate_pricing_site IS NOT NULL
          AND _r.itemsrcpupdate_dropship IS NOT NULL) THEN
            INSERT INTO api.itemsourceprice
            (item_number, vendor, vendor_item_number, effective, expires, 
            qty_break, pricing_type, pricing_site, dropship_only, price_per_unit, 
            currency, discount_percent, discount_fixed_amount)
            VALUES (_r.itemsrcupdate_item_number, _r.itemsrcupdate_vend_number, 
            _r.itemsrcupdate_vend_item_number, _r.itemsrcupdate_effective, _r.itemsrcupdate_expires, 
            _r.itemsrcupdate_qtybreak, _r.itemsrcupdate_type, _r.itemsrcupdate_pricing_site, 
            _r.itemsrcupdate_dropship, _r.itemsrcupdate_price, _r.itemsrcupdate_curr, 
            _r.itemsrcupdate_discntprcnt, _r.itemsrcupdate_fixedamtdiscount
            );
            _new := _new + 1;
       END IF;
     END IF;

    -- check for a change before updating
    IF (_x.itemsrc_id IS NOT NULL) THEN
        _match_itemsrcupdate = concat(_r.item_id, _r.vend_id, 
        _r.itemsrcupdate_vend_item_number, _r.itemsrcupdate_vend_item_descrip, 
        _r.itemsrcupdate_comments, _r.itemsrcupdate_vend_uom, _r.itemsrcupdate_invvendoruomratio, 
        _r.itemsrcupdate_minordqty, _r.itemsrcupdate_multordqty, _r.itemsrcupdate_leadtime, 
        _r.itemsrcupdate_ranking, _r.itemsrcupdate_active, _r.itemsrcupdate_manuf_name, 
        _r.itemsrcupdate_manuf_item_number, _r.itemsrcupdate_manuf_item_descrip, 
        _r.itemsrcupdate_upccode, _r.itemsrcupdate_contrct_number,
        _r.itemsrcupdate_effective, _r.itemsrcupdate_expires);
        _match_itemsrc = concat(_x.item_id, _x.itemsrcupdate_vend_id, _x.itemsrcupdate_vend_item_number, 
        _x.itemsrcupdate_vend_item_descrip, _x.itemsrcupdate_comments, _x.itemsrcupdate_vend_uom, 
        _x.itemsrcupdate_invvendoruomratio, _x.itemsrcupdate_minordqty, _x.itemsrcupdate_multordqty, 
        _x.itemsrcupdate_leadtime, _x.itemsrcupdate_ranking, _x.itemsrcupdate_active, _x.itemsrcupdate_manuf_name, 
        _x.itemsrcupdate_manuf_item_number, _x.itemsrcupdate_manuf_item_descrip, 
        _x.itemsrcupdate_upccode, _x.contrct_number, _x.itemsrcupdate_effective, _x.itemsrcupdate_expires);
    
        IF (_match_itemsrcupdate <> _match_itemsrc) THEN
      -- update item row
            UPDATE itemsrc
            SET  
            itemsrcupdate_vend_item_descrip=coalesce(_r.itemsrcupdate_vend_item_descrip,_x.itemsrcupdate_vend_item_descrip), 
            itemsrcupdate_comments=coalesce(_r.itemsrcupdate_comments,_x.itemsrcupdate_comments), 
            itemsrcupdate_minordqty=coalesce(_r.itemsrcupdate_minordqty,_x.itemsrcupdate_minordqty),
            itemsrcupdate_multordqty=coalesce(_r.itemsrcupdate_multordqty,_x.itemsrcupdate_multordqty),
            itemsrcupdate_leadtime=coalesce(_r.itemsrcupdate_leadtime,_x.itemsrcupdate_leadtime),
            itemsrcupdate_ranking=coalesce(_r.itemsrcupdate_ranking,_x.itemsrcupdate_ranking),
            itemsrcupdate_active=coalesce(_r.itemsrcupdate_active,_x.itemsrcupdate_active),
            itemsrcupdate_manuf_name=coalesce(_r.itemsrcupdate_manuf_name,_x.itemsrcupdate_manuf_name),
            itemsrcupdate_manuf_item_number=coalesce(_r.itemsrcupdate_manuf_item_number,_x.itemsrcupdate_manuf_item_number),
            itemsrcupdate_manuf_item_descrip=coalesce(_r.itemsrcupdate_manuf_item_descrip,_x.itemsrcupdate_vend_item_descrip),
            itemsrcupdate_default=coalesce(_r.itemsrcupdate_default,_x.itemsrcupdate_default),
            itemsrcupdate_upccode=coalesce(_r.itemsrcupdate_upccode,_x.itemsrcupdate_upccode),
            itemsrcupdate_effective=coalesce(_r.itemsrcupdate_effective,_x.itemsrcupdate_effective), 
            itemsrcupdate_expires=coalesce(_r.itemsrcupdate_expires,_x.itemsrcupdate_expires),
            itemsrcupdate_contrct_id=coalesce(getcontrctid(_r.itemsrcupdate_contrct_number),getcontrctid(_x.itemsrcupdate_contract_number))
            WHERE itemsrc_id = _x.itemsrc_id;
          _upd := _upd + 1;
       END IF;
    END IF;
    
    -- check for a change before updating
    IF (_x.itemsrcp_id IS NOT NULL) THEN
       _match_itemsrcpupdate = concat( 
       _r.itemsrcpupdate_vend_item_number, _r.itemsrcpupdate_effective, _r.itemsrcpupdate_expires, 
       _r.itemsrcpupdate_qtybreak, _r.itemsrcpupdate_type, _r.warehous_id, 
       _r.itemsrcpupdate_dropship, _r.itemsrcpupdate_price, _r._currid, 
       _r.itemsrcpupdate_discntprcnt, _r.itemsrcpupdate_fixedamtdiscount, 
       _r.item_id,_r.vend_id);
        _match_itemsrcp = concat(_x.itemsrc_vend_item_number, 
       _x.itemsrc_effective, _x.itemsrc_expires,
       _x.itemsrcupdate_qtybreak, _x.itemsrcupdate_type, _x.itemsrcupdate_warehous_id,
       _x.itemsrcupdate_dropship,_x.itemsrcupdate_price, _x.itemsrcupdate_curr_id,
       _x.itemsrcupdate_discntprcnt, _x.itemsrcupdate_fixedamtdiscount,
       _x.itemsrc_item_id, _x.itemsrc_vend_id);
    
        IF (_match_itemsrcpupdate <> _match_itemsrcp) THEN
          -- update item row
          UPDATE itemsrcp
           SET itemsrcupdate_qtybreak=coalesce(_r.itemsrcpupdate_qtybreak,_x.itemsrcupdate_qtybreak),
           itemsrcupdate_price=coalesce(_r.itemsrcpupdate_price,_x.itemsrcupdate_price),
           itemsrcupdate_updated=current_date, 
           itemsrcupdate_curr_id=coalesce(_r._currid,_x.itemsrcupdate_curr_id),
           itemsrcupdate_dropship=coalesce(_r.itemsrcpupdate_dropship,_x.itemsrcupdate_dropship),
           itemsrcupdate_warehous_id=coalesce(_r.warehous_id,_x.itemsrcupdate_warehous_id),
           itemsrcupdate_type=coalesce(_r.itemsrcpupdate_type,_x.itemsrcupdate_type),
           itemsrcupdate_discntprcnt=coalesce(_r.itemsrcpupdate_discntprcnt,_x.itemsrcupdate_discntprcnt),
           itemsrcupdate_fixedamtdiscount=coalesce(_r.itemsrcpupdate_fixedamtdiscount,_x.itemsrcupdate_fixedamtdiscount)
         WHERE itemsrcp_id = _x.itemsrcp_id;
          _upd := _upd + 1;
       END IF;
   END IF;
 
END LOOP;

   RETURN _upd||' rows updated '||_new||' rows created';
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION itemsrcupdate()
  OWNER TO admin;
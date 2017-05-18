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
       itemsrcupdate_effective, itemsrcupdate_expires,item_id,vend_id
  FROM xtupd.itemsrcupdate
  JOIN item ON itemsrcupdate_item_number = item_number
  JOIN vendinfo ON itemsrcupdate_vend_number = vend_number
  )
  
LOOP
    -- get the matching item source row if existing
    SELECT itemsrc_id, itemsrc_item_id, itemsrc_vend_id, itemsrc_vend_item_number, 
       itemsrc_vend_item_descrip, itemsrc_comments, itemsrc_vend_uom, 
       itemsrc_invvendoruomratio, itemsrc_minordqty, itemsrc_multordqty, 
       itemsrc_leadtime, itemsrc_ranking, itemsrc_active, itemsrc_manuf_name, 
       itemsrc_manuf_item_number, itemsrc_manuf_item_descrip, itemsrc_default, 
       itemsrc_upccode, itemsrc_effective, itemsrc_expires, contrct_number INTO _x
    FROM itemsrc
    LEFT JOIN contrct ON itemsrc_contrct_id = contrct_id
    WHERE itemsrc_item_id = _r.item_id
    AND itemsrc_vend_id = _r.vend_id
    AND trim(both from itemsrc_vend_item_number) = trim(both from _r.itemsrcupdate_vend_item_number)
    AND trim(both from itemsrc_vend_uom) = trim(both from _r.itemsrcupdate_vend_uom)
    AND itemsrc_invvendoruomratio = _r.itemsrcupdate_invvendoruomratio
    AND itemsrc_expires > now();
    -- is this a new item source record?
    IF (NOT FOUND) THEN
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

    -- check for a change before updating
    _match_itemsrcupdate = concat(_r.item_id, _r.vend_id, 
    _r.itemsrcupdate_vend_item_number, _r.itemsrcupdate_vend_item_descrip, 
    _r.itemsrcupdate_comments, _r.itemsrcupdate_vend_uom, _r.itemsrcupdate_invvendoruomratio, 
    _r.itemsrcupdate_minordqty, _r.itemsrcupdate_multordqty, _r.itemsrcupdate_leadtime, 
    _r.itemsrcupdate_ranking, _r.itemsrcupdate_active, _r.itemsrcupdate_manuf_name, 
    _r.itemsrcupdate_manuf_item_number, _r.itemsrcupdate_manuf_item_descrip, 
    _r.itemsrcupdate_upccode, _r.itemsrcupdate_contrct_number,
    _r.itemsrcupdate_effective, _r.itemsrcupdate_expires);
    _match_itemsrc = concat(_x.itemsrc_item_id, _x.itemsrc_vend_id, _x.itemsrc_vend_item_number, 
    _x.itemsrc_vend_item_descrip, _x.itemsrc_comments, _x.itemsrc_vend_uom, 
    _x.itemsrc_invvendoruomratio, _x.itemsrc_minordqty, _x.itemsrc_multordqty, 
    _x.itemsrc_leadtime, _x.itemsrc_ranking, _x.itemsrc_active, _x.itemsrc_manuf_name, 
    _x.itemsrc_manuf_item_number, _x.itemsrc_manuf_item_descrip, 
    _x.itemsrc_upccode, _x.contrct_number, _x.itemsrc_effective, _x.itemsrc_expires);
    
    IF (_match_itemsrcupdate <> _match_itemsrc) THEN
      -- update item row
      UPDATE itemsrc
        SET  
        itemsrc_vend_item_descrip=coalesce(_r.itemsrcupdate_vend_item_descrip,_x.itemsrc_vend_item_descrip), 
        itemsrc_comments=coalesce(_r.itemsrcupdate_comments,_x.itemsrc_comments), 
        itemsrc_minordqty=coalesce(_r.itemsrcupdate_minordqty,_x.itemsrc_minordqty),
        itemsrc_multordqty=coalesce(_r.itemsrcupdate_multordqty,_x.itemsrc_multordqty),
        itemsrc_leadtime=coalesce(_r.itemsrcupdate_leadtime,_x.itemsrc_leadtime),
        itemsrc_ranking=coalesce(_r.itemsrcupdate_ranking,_x.itemsrc_ranking),
        itemsrc_active=coalesce(_r.itemsrcupdate_active,_x.itemsrc_active),
        itemsrc_manuf_name=coalesce(_r.itemsrcupdate_manuf_name,_x.itemsrc_manuf_name),
        itemsrc_manuf_item_number=coalesce(_r.itemsrcupdate_manuf_item_number,_x.itemsrc_manuf_item_number),
        itemsrc_manuf_item_descrip=coalesce(_r.itemsrcupdate_manuf_item_descrip,_x.itemsrc_vend_item_descrip),
        itemsrc_default=coalesce(_r.itemsrcupdate_default,_x.itemsrc_default),
        itemsrc_upccode=coalesce(_r.itemsrcupdate_upccode,_x.itemsrc_upccode),
        itemsrc_effective=coalesce(_r.itemsrcupdate_effective,_x.itemsrc_effective), 
        itemsrc_expires=coalesce(_r.itemsrcupdate_expires,_x.itemsrc_expires),
        itemsrc_contrct_id=coalesce(getcontrctid(_r.itemsrcupdate_contrct_number),getcontrctid(_x.contrct_number))
        WHERE itemsrc_id = _x.itemsrc_id;
      _upd := _upd + 1;
   END IF;
 
END LOOP;

   RETURN _upd||' rows updated '||_new||' rows created';
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION itemsrcupdate()
  OWNER TO admin;
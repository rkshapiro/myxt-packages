-- Function: copyitem(integer, text)

-- DROP FUNCTION copyitem(integer, text);

CREATE OR REPLACE FUNCTION copyitem(
    integer,
    text)
  RETURNS integer AS
$BODY$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE

-- 20161101:rks initial version public function extended to copy ecommerce settings

  pSItemid ALIAS FOR $1;
  pTItemNumber ALIAS FOR $2;
  _itemid INTEGER;
  _r RECORD;
  _id INTEGER;

BEGIN
  -- copy the item with ecommerce settings
  SELECT NEXTVAL('item_item_id_seq') INTO _itemid;
  INSERT INTO item(
            item_id, item_number, item_descrip1, item_descrip2, item_classcode_id, 
            item_picklist, item_comments, item_sold, item_fractional, item_active, 
            item_type, item_prodweight, item_packweight, item_prodcat_id, 
            item_exclusive, item_listprice, item_config, item_extdescrip, 
            item_upccode, item_maxcost, item_inv_uom_id, item_price_uom_id, 
            item_warrdays, item_freightclass_id, item_tax_recoverable, item_listcost, 
            item_length, item_width, item_height, item_phy_uom_id, item_pack_length, 
            item_pack_width, item_pack_height, item_pack_phy_uom_id, item_mrkt_title, 
            item_mrkt_subtitle, item_mrkt_teaser, item_mrkt_descrip, item_mrkt_seokey, 
            item_mrkt_seotitle)
    SELECT _itemid, pTItemNumber, item_descrip1, item_descrip2, item_classcode_id, 
       item_picklist, item_comments, item_sold, item_fractional, item_active, 
       item_type, item_prodweight, item_packweight, item_prodcat_id, 
       item_exclusive, item_listprice, item_config, item_extdescrip, 
       item_upccode, item_maxcost, item_inv_uom_id, item_price_uom_id, 
       item_warrdays, item_freightclass_id, item_tax_recoverable, item_listcost, 
       item_length, item_width, item_height, item_phy_uom_id, item_pack_length, 
       item_pack_width, item_pack_height, item_pack_phy_uom_id, item_mrkt_title, 
       item_mrkt_subtitle, item_mrkt_teaser, item_mrkt_descrip, item_mrkt_seokey, 
       item_mrkt_seotitle
	FROM item
    WHERE (item_id=pSItemid);
	
	PERFORM * FROM itemgrpitem WHERE (itemgrpitem_item_id=pSItemid);
	IF (FOUND) THEN
		-- put the new new item into the item group of the old item
		INSERT INTO itemgrpitem(
				itemgrpitem_itemgrp_id, itemgrpitem_item_id, 
				itemgrpitem_item_type)
		SELECT itemgrpitem_itemgrp_id, _itemid, 
		   itemgrpitem_item_type
		FROM itemgrpitem
		WHERE (itemgrpitem_item_id=pSItemid);
		-- remove the old item from the item group
		DELETE FROM itemgrpitem
		WHERE (itemgrpitem_item_id=pSItemid);
	END IF;
	
	-- publish the new item to ecommerce	
	PERFORM * FROM xdruple.xd_commerce_product_data WHERE (item_id=pSItemid);
	IF (FOUND) THEN
		INSERT INTO xdruple.xd_commerce_product_data(
				item_id, type, language, uid, status, created, changed, data)
		SELECT _itemid, type, language, uid, status, created, changed, data
		FROM xdruple.xd_commerce_product_data
		WHERE (item_id=pSItemid);
		-- unpublish the old item
		DELETE FROM xdruple.xd_commerce_product_data
		WHERE (item_id=pSItemid);
	END IF;	

  INSERT INTO imageass
  (imageass_source_id, imageass_source, imageass_image_id, imageass_purpose)
  SELECT _itemid, 'I', imageass_image_id, imageass_purpose
  FROM imageass
  WHERE ((imageass_source_id=pSItemid)
  AND (imageass_source='I'));

  INSERT INTO url
  (url_source_id, url_source, url_title, url_url)
  SELECT _itemid, 'I', url_title, url_url
  FROM url
  WHERE ((url_source_id=pSItemid)
  AND (url_source='I'));

  INSERT INTO itemtax
        (itemtax_item_id, itemtax_taxzone_id, itemtax_taxtype_id)
  SELECT _itemid, itemtax_taxzone_id, itemtax_taxtype_id
    FROM itemtax
   WHERE(itemtax_item_id=pSItemid);

  INSERT INTO charass
  ( charass_target_type, charass_target_id,
    charass_char_id, charass_value )
  SELECT 'I', _itemid, charass_char_id, charass_value
  FROM charass
  WHERE ( (charass_target_type='I')
   AND (charass_target_id=pSItemid) );

  FOR _r IN SELECT itemuomconv_id,
                   itemuomconv_from_uom_id,
                   itemuomconv_from_value,
                   itemuomconv_to_uom_id,
                   itemuomconv_to_value,
                   itemuomconv_fractional
              FROM itemuomconv
             WHERE(itemuomconv_item_id=pSItemid) LOOP
    SELECT nextval('itemuomconv_itemuomconv_id_seq') INTO _id;
    INSERT INTO itemuomconv
          (itemuomconv_id, itemuomconv_item_id,
           itemuomconv_from_uom_id, itemuomconv_from_value,
           itemuomconv_to_uom_id, itemuomconv_to_value,
           itemuomconv_fractional)
    VALUES(_id, _itemid,
           _r.itemuomconv_from_uom_id, _r.itemuomconv_from_value,
           _r.itemuomconv_to_uom_id, _r.itemuomconv_to_value,
           _r.itemuomconv_fractional);

    INSERT INTO itemuom
          (itemuom_itemuomconv_id, itemuom_uomtype_id)
    SELECT _id, itemuom_uomtype_id
      FROM itemuom
     WHERE(itemuom_itemuomconv_id=_r.itemuomconv_id);
  END LOOP;

  RETURN _itemid;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION copyitem(integer, text)
  OWNER TO mfgadmin;

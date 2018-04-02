-- Function: xtimp.xpitemattributesimport()

-- DROP FUNCTION xtimp.xpitemattributesimport();

CREATE OR REPLACE FUNCTION xtimp.xpitemattributesimport()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD;
  _result INTEGER;
  _id INTEGER;

BEGIN 
-- update item with attribute details
  FOR _r IN
	  (SELECT *,item_id,i.chargetype_code AS amountbasis,f.chargetype_code AS freightbasis
	  FROM xtimp.xpitemattributes 
	  JOIN item ON xpitemattributes_itemnumber = item_number
      LEFT JOIN chargetype i ON i.chargetype_code = xpitemattributes_amountbasis
      LEFT JOIN chargetype f ON f.chargetype_code = xpitemattributes_addfreightbasis
	   WHERE xpitemattributes_id >0
	   AND xpitemattributes_imported='f' 
	   AND xpitemattributes_checked='t'   
	   )
 -- Update Item attributes
  LOOP
	UPDATE item
	SET 
       item_web_published=_r.xpitemattributes_publishtowebsite, 
	   item_web_exclusive_public=_r.xpitemattributes_publicviewexclusive, 
	   item_web_accept_backorder=_r.xpitemattributes_acceptbackorders, 
       item_web_out_of_stock_message=_r.xpitemattributes_backordermessage, 
	   item_length=_r.xpitemattributes_productlength, 
	   item_width=_r.xpitemattributes_productwidth, 
       item_height=_r.xpitemattributes_productheight, 
	   item_phy_uom_id=getuomid(_r.xpitemattributes_productuom), 
	   item_pack_length=_r.xpitemattributes_packagelength, 
	   item_pack_width=_r.xpitemattributes_packagewidth, 
       item_pack_height=_r.xpitemattributes_packageheight, 
	   item_pack_phy_uom_id=getuomid(_r.xpitemattributes_packageuom), 
	   item_ship_separately=_r.xpitemattributes_shipseparately, 
       item_quote_freight_by_volume=_r.xpitemattributes_quotefreightbyvolume, 
	   item_require_freight_insurance=_r.xpitemattributes_requirefreightinsurance, 
       item_freight_insurance_amount=_r.xpitemattributes_insuranceamount, 
	   item_freight_insurance_chargetype_id=_r.amountbasis, 
       item_additional_freight_amount=_r.xpitemattributes_additionalfreightfee, 
	   item_additional_freight_chargetype_id=_r.freightbasis
	WHERE item_id = _r.item_id;

  END LOOP;
  
  UPDATE xtimp.xpitemattributes
  SET xpitemattributes_imported = true
  WHERE xpitemattributes_import_error = '';
  
  RAISE NOTICE  'extimp Item Attribute import completed';
  RETURN(TRUE);
  END; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpitemattributesimport()
  OWNER TO admin;
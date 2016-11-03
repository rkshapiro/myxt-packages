-- Function: createnewitem(text, integer)

-- DROP FUNCTION createnewitem(text, integer);

CREATE OR REPLACE FUNCTION createnewitem(
    text,
    integer)
  RETURNS integer AS
$BODY$
DECLARE

-- 20161014:rks initial version
-- 20161101:rks changed to use copyitem function from package
-- 20161103:rks changed to trap missing disassembly site on kits - create default site?

pnewnumberk ALIAS FOR $1;
pkitid ALIAS FOR $2;
_kitnumber TEXT;
_newnumberc TEXT;
_newnumberd TEXT;
_newnumberid integer;
_result integer;
_warehousid integer;

BEGIN

	-- verify the item is an active kit
	SELECT item_number INTO _kitnumber
	FROM item
	WHERE item_id = pkitid
	AND item_type = 'K'
	AND item_active;

	IF (NOT FOUND) THEN
	  RAISE EXCEPTION 'Item % is not an active kit',_kitnumber;
	  RETURN 'Stop';
	END IF;

	-- create the new version of the kit 
	SELECT _bom2boo.copyitem(pkitid,pnewnumberk) INTO _newnumberid;
	IF (_newnumberid = NULL OR _newnumberid < 1) THEN
		RAISE EXCEPTION 'Error copying kit item %',pnewnumberk;
		RETURN 'Stop';
	END IF;
	-- reset the kit class code for development only
	UPDATE item
	SET item_classcode_id = getclasscodeid('BOM2BOO')
	WHERE item_id = _newnumberid;
	
	SELECT copyitemsite(getitemsiteid('ASSET1',_kitnumber),getwarehousid('ASSET1','ALL'),_newnumberid) INTO _result;
	IF (_result = NULL OR _result < 1) THEN
		RAISE EXCEPTION 'Error copying kit ASSET1 itemsite %',pnewnumberk;
		RETURN 'Stop';
	END IF;
	-- check that the kit has a disassembly site defined
	SELECT itemsite_warehous_id INTO _warehousid
	FROM itemsite
	WHERE itemsite_item_id = getitemid(_kitnumber)
	AND itemsite_warehous_id = getwarehousid('DISASSEMBLY','ALL');
	
	IF (NOT FOUND) THEN
	  RAISE EXCEPTION 'Disassembly Site for % Not Found',_kitnumber;
	  RETURN 'Stop';
	END IF;
	-- COPY DISASSEMBLY SITE
	SELECT copyitemsite(getitemsiteid('DISASSEMBLY',_kitnumber),_warehousid,_newnumberid) INTO _result;
	IF (_result = NULL OR _result < 1) THEN
		RAISE EXCEPTION 'Error copying kit DISASSEMBLY itemsite %',pnewnumberk;
		RETURN 'Stop';
	END IF;
	  
	-- create the consumable mfg item
	_newnumberc := pnewnumberk||'C';
	SELECT NEXTVAL('item_item_id_seq') INTO _newnumberid;
	
	INSERT INTO item(item_id,
			item_number, item_descrip1, item_descrip2, item_classcode_id, 
			item_picklist, item_comments, item_sold, item_fractional, item_active, 
			item_type, item_prodweight, item_packweight, item_prodcat_id, 
			item_exclusive, item_listprice, item_config, item_extdescrip, 
			item_upccode, item_maxcost, item_inv_uom_id, item_price_uom_id, 
			item_warrdays, item_freightclass_id, item_tax_recoverable, item_listcost, 
			item_length, item_width, item_height, item_phy_uom_id, item_pack_length, 
			item_pack_width, item_pack_height, item_pack_phy_uom_id)
	SELECT _newnumberid,_newnumberc, item_descrip1||' CONSUMABLES', item_descrip2, getclasscodeid('BOM2BOO'), 
	   item_picklist, item_comments, item_sold, item_fractional, item_active, 
	   'M', 0, 0, getprodcatid('CONSUMABLE'), 
	   item_exclusive, item_listprice, item_config, item_extdescrip, 
	   item_upccode, item_maxcost, item_inv_uom_id, item_price_uom_id, 
	   item_warrdays, getfreightclassid('BOX'), item_tax_recoverable, item_listcost, 
	   item_length, item_width, item_height, item_phy_uom_id, item_pack_length, 
	   item_pack_width, item_pack_height, item_pack_phy_uom_id
	FROM item
	WHERE item_id = pkitid;
    
	SELECT copyitemsite(getitemsiteid('ASSET1',_kitnumber),getwarehousid('ASSET1','ALL'),_newnumberid) INTO _result;
	IF (_result = NULL OR _result < 1) THEN
		RAISE EXCEPTION 'Error copying kit ASSET1 itemsite %',pnewnumberk;
		RETURN 'Stop';
	END IF;

	-- set parameters for the manufactured item
	UPDATE itemsite
	SET itemsite_wosupply = true, itemsite_controlmethod = 'R'
	WHERE itemsite_id = _result;
	
	-- create the durable mfg item
	_newnumberd := pnewnumberk||'D';
	SELECT NEXTVAL('item_item_id_seq') INTO _newnumberid;
	
	INSERT INTO item(item_id,
			item_number, item_descrip1, item_descrip2, item_classcode_id, 
			item_picklist, item_comments, item_sold, item_fractional, item_active, 
			item_type, item_prodweight, item_packweight, item_prodcat_id, 
			item_exclusive, item_listprice, item_config, item_extdescrip, 
			item_upccode, item_maxcost, item_inv_uom_id, item_price_uom_id, 
			item_warrdays, item_freightclass_id, item_tax_recoverable, item_listcost, 
			item_length, item_width, item_height, item_phy_uom_id, item_pack_length, 
			item_pack_width, item_pack_height, item_pack_phy_uom_id)
	SELECT _newnumberid,_newnumberd, item_descrip1||' DURABLES', item_descrip2, getclasscodeid('BOM2BOO'), 
	   item_picklist, item_comments, item_sold, item_fractional, item_active, 
	   'M', 0, 0, getprodcatid('DURABLE'), 
	   item_exclusive, item_listprice, item_config, item_extdescrip, 
	   item_upccode, item_maxcost, item_inv_uom_id, item_price_uom_id, 
	   item_warrdays, getfreightclassid('MODULE'), item_tax_recoverable, item_listcost, 
	   item_length, item_width, item_height, item_phy_uom_id, item_pack_length, 
	   item_pack_width, item_pack_height, item_pack_phy_uom_id
	FROM item
	WHERE item_id = pkitid;
    
	SELECT copyitemsite(getitemsiteid('ASSET1',_kitnumber),getwarehousid('ASSET1','ALL'),_newnumberid) INTO _result;
	IF (_result = NULL OR _result < 1) THEN
		RAISE EXCEPTION 'Error copying kit ASSET1 itemsite %',pnewnumberk;
		RETURN 'Stop';
	END IF;
	-- set parameters for the manufactured item
	UPDATE itemsite
	SET itemsite_wosupply = true, itemsite_controlmethod = 'R'
	WHERE itemsite_id = _result;
	
	SELECT copyitemsite(getitemsiteid('DISASSEMBLY',_kitnumber),_warehousid,_newnumberid) INTO _result;
	IF (_result = NULL OR _result < 1) THEN
		RAISE EXCEPTION 'Error copying kit DISASSEMBLY itemsite %',pnewnumberk;
		RETURN 'Stop';
	END IF;
	-- set parameters for the manufactured item
	UPDATE itemsite
	SET itemsite_wosupply = true, itemsite_controlmethod = 'R'
	WHERE itemsite_id = _result;
	
	-- copy the return date and rental period characteristics for the DURABLE item
	INSERT INTO charass
	( charass_target_type, charass_target_id,
    charass_char_id, charass_value )
	SELECT 'I', _newnumberid, charass_char_id, charass_value
	FROM charass
	WHERE ( (charass_target_type='I')
	AND (charass_target_id=pkitid) );
	
	RETURN getitemid(pnewnumberk);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION createnewitem(text, integer)
  OWNER TO admin;

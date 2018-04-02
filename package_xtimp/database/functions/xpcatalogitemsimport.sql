-- Function: xtimp.xpcatalogitemsimport()

-- DROP FUNCTION xtimp.xpcatalogitemsimport();

CREATE OR REPLACE FUNCTION xtimp.xpcatalogitemsimport()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD;
  _result INTEGER;
  _groupnameid INTEGER;

BEGIN 
  
  FOR _r IN
  -- select all of the group items and get the id of ones already imported
   (
     SELECT *,item_id,itemgrp_id
	 FROM xtimp.xpcatalogitems
	 JOIN item ON TRIM(both xpcatalogitems_itemnumber) = item_number
	 JOIN itemgrp ON TRIM(both xpcatalogitems_groupname) = itemgrp_name
	 WHERE xpcatalogitems_id >0
     AND xpcatalogitems_checked='t'
	 AND xpcatalogitems_imported='f'
   ) 
   LOOP

	INSERT INTO itemgrpitem(itemgrpitem_itemgrp_id, itemgrpitem_item_id,itemgrpitem_item_type)
	VALUES (_r.itemgrp_id,_r.item_id,'I');
    
  END LOOP;
  
  UPDATE xtimp.xpcatalogitems
  SET xpcatalogitems_imported = true
  WHERE xpcatalogitems_import_error = '';
  
  RAISE NOTICE  'extimp catalog group import completed';
  RETURN(TRUE);
  END; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpcatalogitemsimport()
  OWNER TO admin;
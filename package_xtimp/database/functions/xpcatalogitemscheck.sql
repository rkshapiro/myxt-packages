-- Function: xtimp.xpcatalogitemscheck()

-- DROP FUNCTION xtimp.xpcatalogitemscheck();

CREATE OR REPLACE FUNCTION xtimp.xpcatalogitemscheck()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';  

 BEGIN
 FOR _r IN
  -- select all of the items and the group
   (
     SELECT *,item_id,itemgrp_id
	 FROM xtimp.xpcatalogitems
	 LEFT OUTER JOIN item ON TRIM(both xpcatalogitems_itemnumber) = item_number
	 LEFT OUTER JOIN itemgrp ON TRIM(both xpcatalogitems_groupname) = itemgrp_name
	 WHERE xpcatalogitems_id >0
   ) 
   LOOP
	-- check for undefined item
		IF _r.item_id IS NULL THEN
			_error := _r.xpcatalogitems_import_error||' '||'Item undefined;';
		END IF;
	-- check for undefined group		
		IF _r.itemgrp_id IS NULL THEN
			_error := _r.xpcatalogitems_import_error || ' ' || 'Catalog group unknown;';
		END IF;
	-- check if the item is already in this group
		PERFORM itemgrpitem_id 
		FROM itemgrpitem 
		WHERE itemgrpitem_item_id = _r.item_id
		AND itemgrpitem_itemgrp_id = _r.itemgrp_id;
		
		IF FOUND THEN
			_error := _r.xpcatalogitems_import_error || ' ' || 'Item already in group;';
		END IF;
       
	    UPDATE xtimp.xpcatalogitems SET xpcatalogitems_import_error = _error WHERE xpcatalogitems_id = _r.xpcatalogitems_id;
	    _error := '';
    END LOOP;
	
    UPDATE xtimp.xpcatalogitems SET xpcatalogitems_checked=TRUE WHERE xpcatalogitems_import_error= '' ;         
        
   RETURN TRUE;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpcatalogitemscheck()
  OWNER TO admin;

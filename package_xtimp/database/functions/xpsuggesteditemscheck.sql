-- Function: xtimp.xpsuggesteditemscheck()

-- DROP FUNCTION xtimp.xpsuggesteditemscheck();

CREATE OR REPLACE FUNCTION xtimp.xpsuggesteditemscheck()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';  

 BEGIN
 FOR _r IN
 (SELECT *, s.item_id AS source_itemid, ss.item_id AS suggested_itemid  
 FROM xtimp.xpsuggesteditems
  LEFT OUTER JOIN item s ON (xpsuggesteditems_itemnumber = s.item_number)
  LEFT OUTER JOIN item ss ON (xpsuggesteditems_itemnumber = ss.item_number)
 )
 
    LOOP
		-- Check that items are defined
		IF _r.source_itemid IS NULL THEN
			_error := _error || 'Item is undefined;'; 
		END IF;		

		IF _r.suggested_itemid IS NULL THEN
			_error := _error || 'Suggested Item is undefined;'; 
		END IF;	
		
		-- check that the quantity is greater than zero
		IF _r.xpsuggesteditems_quantity <= 0 OR _r.xpsuggesteditems_quantity IS NULL THEN
			_error := _error || 'Quantity invalid;';
		END IF;
		
		UPDATE xtimp.xpsuggesteditems SET xpsuggesteditems_import_error = _error WHERE xpsuggesteditems_id = _r.xpsuggesteditems_id;
        
        _error = '';
       
    END LOOP;
	
    UPDATE xtimp.xpsuggesteditems SET xpsuggesteditems_checked=TRUE WHERE xpsuggesteditems_import_error= '' ;         
        
   RETURN TRUE;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpsuggesteditemscheck()
  OWNER TO admin;

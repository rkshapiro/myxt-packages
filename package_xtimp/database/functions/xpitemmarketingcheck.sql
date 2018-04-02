-- Function: xtimp.xpitemmarketingcheck()

-- DROP FUNCTION xtimp.xpitemmarketingcheck();

CREATE OR REPLACE FUNCTION xtimp.xpitemmarketingcheck()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';  

 BEGIN
 FOR _r IN
 (SELECT *, item_id  
 FROM xtimp.xpitemmarketing
  LEFT OUTER JOIN item ON (xpitemmarketing_itemnumber = item_number)
 )
 -- not sure what needs to be checked
    LOOP	
		IF _r.item_id IS NULL THEN
			_error := _r.xpitemmarketing_import_error ||' '|| 'Item unknown;';
		END IF;

        UPDATE xtimp.xpitemmarketing SET xpitemmarketing_import_error = _error WHERE xpitemmarketing_id = _r.xpitemmarketing_id;
			
        _error = '';
       
    END LOOP;
	
    UPDATE xtimp.xpitemmarketing SET xpitemmarketing_checked=TRUE WHERE xpitemmarketing_import_error= '' ;         
        
   RETURN TRUE;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpitemmarketingcheck()
  OWNER TO admin;

-- Function: xtimp.xpitemattributescheck()

-- DROP FUNCTION xtimp.xpitemattributescheck();

CREATE OR REPLACE FUNCTION xtimp.xpitemattributescheck()
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
 FROM xtimp.xpitemattributes
  LEFT OUTER JOIN item ON (xpitemattributes_itemnumber = item_number)
 )
 -- not sure what needs to be checked
    LOOP
		IF _r.item_id IS NULL THEN
			_error := _r.xpitemattributes_import_error ||' '|| 'Item unknown;';
		END IF;

        UPDATE xtimp.xpitemattributes SET xpitemattributes_import_error = _error WHERE xpitemattributes_id = _r.xpitemattributes_id;
			
        _error = '';
       
    END LOOP;
	
    UPDATE xtimp.xpitemattributes SET xpitemattributes_checked=TRUE WHERE xpitemattributes_import_error= '' ;         
        
   RETURN TRUE;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpitemattributescheck()
  OWNER TO admin;

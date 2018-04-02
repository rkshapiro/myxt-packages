-- Function: xtimp.xpdocumentscheck()

-- DROP FUNCTION xtimp.xpdocumentscheck();

CREATE OR REPLACE FUNCTION xtimp.xpdocumentscheck()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';
 
 BEGIN
 FOR _r IN
 (
  SELECT *, item_id  
 FROM xtimp.xpdocuments
  LEFT OUTER JOIN item ON (xpdocuments_itemnumber = item_number)
 )

	LOOP
		IF _r.item_id IS NULL THEN
			_error := _r.xpitemattributes_import_error ||' '|| 'Item unknown;';
		END IF;

        UPDATE xtimp.xpitemattributes SET xpitemattributes_import_error = _error WHERE xpitemattributes_id = _r.xpitemattributes_id;
			
        _error = '';
         
    END LOOP;

	UPDATE xtimp.xpitemattributes SET xpitemattributes_checked=TRUE WHERE xpitemattributes_import_error= '' ;    
		
   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpdocumentscheck()
  OWNER TO admin;
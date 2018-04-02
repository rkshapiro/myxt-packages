-- Function: xtimp.xpdocumentsfix()

-- DROP FUNCTION xtimp.xpdocumentsfix();

CREATE OR REPLACE FUNCTION xtimp.xpdocumentsfix()
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
  LEFT OUTER JOIN item s ON (xpdocuments_itemnumber = item_number)
 )

	LOOP
 -- Not sure what can be fixed
            
    END LOOP;

   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpdocumentsfix()
  OWNER TO admin;
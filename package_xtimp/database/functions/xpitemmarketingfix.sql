-- Function: xtimp.xpitemmarketingfix()

-- DROP FUNCTION xtimp.xpitemmarketingfix();

CREATE OR REPLACE FUNCTION xtimp.xpitemmarketingfix()
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
  SELECT *,item_id
  FROM xtimp.xpitemmarketing
  LEFT OUTER JOIN item ON (xpitemmarketing_itemnumber = item_number)
 )
 
	LOOP
	
	-- not sure what can be fixed
		
    END LOOP;

   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpitemmarketingfix()
  OWNER TO admin;
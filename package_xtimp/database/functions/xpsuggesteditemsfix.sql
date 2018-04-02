-- Function: xtimp.xpsuggesteditemsfix()

-- DROP FUNCTION xtimp.xpsuggesteditemsfix();

CREATE OR REPLACE FUNCTION xtimp.xpsuggesteditemsfix()
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
  SELECT *, s.item_id AS source_itemid, ss.item_id AS suggested_itemid  
 FROM xtimp.xpsuggesteditems
  LEFT OUTER JOIN item s ON (xpsuggesteditems_itemnumber = s.item_number)
  LEFT OUTER JOIN item ss ON (xpsuggesteditems_itemnumber = ss.item_number) 
 )

	LOOP
 -- Not sure what can be fixed
            
    END LOOP;

   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpsuggesteditemsfix()
  OWNER TO admin;
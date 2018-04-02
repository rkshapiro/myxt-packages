-- Function: xtimp.xpcatalogitemsfix()

-- DROP FUNCTION xtimp.xpcatalogitemsfix();

CREATE OR REPLACE FUNCTION xtimp.xpcatalogitemsfix()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';
 
 BEGIN
    FOR _r IN
  -- select all of the group items and get the id of ones already imported
   (
     SELECT *,itemgrp_id
	 FROM xtimp.xpcatalogitems
	 LEFT OUTER JOIN itemgrp ON xpcatalogitems_groupname = itemgrp_name
	 WHERE xpcatalogitems_id >0
     AND xpcatalogitems_itemnumber IS NOT NULL
   ) 
   LOOP
   
    -- Check for the group and create if not found
    IF _r.itemgrp_id IS NULL THEN
		INSERT INTO itemgrp(itemgrp_name, itemgrp_catalog)
		VALUES (trim(both _r.xpcatalogitems_groupname), false);
	END IF;	
   END LOOP;  
   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpcatalogitemsfix()
  OWNER TO admin;
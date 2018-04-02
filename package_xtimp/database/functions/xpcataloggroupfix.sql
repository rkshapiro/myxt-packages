-- Function: xtimp.xpcataloggroupfix()

-- DROP FUNCTION xtimp.xpcataloggroupfix();

CREATE OR REPLACE FUNCTION xtimp.xpcataloggroupfix()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';
 
 BEGIN
       
       -- Check for catalog group and create if not found
      /*  PERFORM itemgrp_id FROM itemgrp WHERE itemgrp_catalog;
        IF NOT FOUND THEN
            INSERT INTO itemgrp(itemgrp_name, itemgrp_catalog)
            VALUES ('Catalog', TRUE);
	END IF;	*/ -- donot do this for the Import data utility. require it be defined
        
   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpcataloggroupfix()
  OWNER TO admin;
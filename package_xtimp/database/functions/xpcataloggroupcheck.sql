-- Function: xtimp.xpcataloggroupcheck()

-- DROP FUNCTION xtimp.xpcataloggroupcheck();

CREATE OR REPLACE FUNCTION xtimp.xpcataloggroupcheck()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';  
  _catalogid integer;

 BEGIN
 FOR _r IN
 (SELECT *,itemgrp_id  
 FROM xtimp.xpcataloggroup
  LEFT OUTER JOIN itemgrp ON (xpcataloggroup_groupitemname = itemgrp_name)
 )
 
    LOOP

	--Check that a catalog root group is defined create if not there
		SELECT itemgrp_id INTO _catalogid FROM itemgrp WHERE itemgrp_catalog;
		IF _catalogid IS NULL THEN
			_error := _r.xpcataloggroup_import_error || ' ' || 'Catalog not defined;';
		END IF;
       
	    UPDATE xtimp.xpcataloggroup SET xpcataloggroup_import_error = _error WHERE xpcataloggroup_id = _r.xpcataloggroup_id;
	    _error := '';
    END LOOP;
	
    UPDATE xtimp.xpcataloggroup SET xpcataloggroup_checked=TRUE WHERE xpcataloggroup_import_error= '' ;         
        
   RETURN TRUE;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpcataloggroupcheck()
  OWNER TO admin;

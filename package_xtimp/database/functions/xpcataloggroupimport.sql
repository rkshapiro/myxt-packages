-- Function: xtimp.xpcataloggroupimport()

-- DROP FUNCTION xtimp.xpcataloggroupimport();

CREATE OR REPLACE FUNCTION xtimp.xpcataloggroupimport()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD;
  _result INTEGER;
  _catalogid INTEGER;
  _childid INTEGER;
  _parentid INTEGER;

BEGIN 
-- get the id for the catalog group
  --SELECT itemgrp_id INTO _catalogid FROM itemgrp WHERE itemgrp_catalog;
  
  FOR _r IN
  -- select all of the group items and get the id of ones already imported
   (
     SELECT *,c.itemgrp_id as child, p.itemgrp_id as parent
	 FROM xtimp.xpcataloggroup
     LEFT OUTER JOIN itemgrp p ON xpcataloggroup_parentgroupname = p.itemgrp_name
	 LEFT OUTER JOIN itemgrp c ON xpcataloggroup_groupitemname = c.itemgrp_name
	 WHERE xpcataloggroup_id >0
     AND xpcataloggroup_checked='t'
   ) 
   LOOP
	IF _r.parent IS NULL THEN
        -- has this group been seen before
        SELECT itemgrp_id INTO _parentid FROM itemgrp WHERE _r.xpcataloggroup_parentgroupname = itemgrp_name;
        IF NOT FOUND THEN
            INSERT INTO itemgrp(itemgrp_name)
            VALUES (_r.xpcataloggroup_parentgroupname)
            RETURNING itemgrp_id INTO _parentid;
        END IF;
	END IF;
    IF _r.child IS NULL THEN
        -- has this group been seen before
        SELECT itemgrp_id INTO _childid FROM itemgrp WHERE _r.xpcataloggroup_groupitemname = itemgrp_name;
        IF NOT FOUND THEN
            INSERT INTO itemgrp(itemgrp_name)
            VALUES (_r.xpcataloggroup_groupitemname)
            RETURNING itemgrp_id INTO _childid;
        END IF;
	END IF;

	INSERT INTO itemgrpitem(itemgrpitem_itemgrp_id, itemgrpitem_item_id,itemgrpitem_item_type)
	VALUES (COALESCE(_r.parent,_parentid),COALESCE(_r.child,_childid),'G');
    
  END LOOP;
  
  UPDATE xtimp.xpcataloggroup
  SET xpcataloggroup_imported = true
  WHERE xpcataloggroup_import_error = '';
    
  RAISE NOTICE  'xtimp catalog group import completed';
  RETURN(TRUE);
  END; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpcataloggroupimport()
  OWNER TO admin;
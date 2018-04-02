-- Function: xtimp.xpsuggesteditemsimport()

-- DROP FUNCTION xtimp.xpsuggesteditemsimport();

CREATE OR REPLACE FUNCTION xtimp.xpsuggesteditemsimport()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD;
  _result INTEGER;
  _id INTEGER;

BEGIN 
 FOR _r IN
  (SELECT *, s.item_id AS source_itemid, ss.item_id AS suggested_itemid 
   FROM xtimp.xpsuggesteditems
   JOIN item s ON xpsuggesteditems_itemnumber = s.item_number
   JOIN item ss ON xpsuggesteditems_sugesteditemnumber = ss.item_number
   WHERE xpsuggesteditems_id >0
   AND xpsuggesteditems_imported='f' 
   AND xpsuggesteditems_checked='t'   )
 -- Import Items
 LOOP
	INSERT INTO xdruple.xd_itemsuggest(
            itemsuggest_suggested_id, itemsuggest_descrip, 
            itemsuggest_mandatory, itemsuggest_suggested_qty, itemsuggest_source_id, 
            itemsuggest_source_type, itemsuggest_type)
    VALUES (_r.suggested_itemid, _r.xpsuggesteditems_reason, 
            _r.xpsuggesteditems_mandatory, _r.xpsuggesteditems_quantity, _r.source_itemid, 
            'I', 'S');

  END LOOP;
  
  UPDATE xtimp.xpsuggesteditems
  SET xpsuggesteditems_imported = true
  WHERE xpsuggesteditems_import_error = '';
  
  RAISE NOTICE  'extimp Suggested Item import completed';
  RETURN(TRUE);
  END; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpsuggesteditemsimport()
  OWNER TO admin;
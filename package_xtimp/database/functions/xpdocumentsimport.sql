-- Function: xtimp.xpdocumentsimport()

-- DROP FUNCTION xtimp.xpdocumentsimport();

CREATE OR REPLACE FUNCTION xtimp.xpdocumentsimport()
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
  (SELECT *, item_id
  FROM xtimp.xpdocuments
  JOIN item ON xpdocuments_itemnumber = item_number
   WHERE xpdocuments_id >0
   AND xpdocuments_imported='f' 
   AND xpdocuments_checked='t'   )
	
	LOOP
	-- Create URL 
		INSERT INTO urlinfo(url_title, url_url, url_published, url_content_type, url_weight)
		VALUES(_r.xpdocuments_documentname,_r.xpdocuments_url,_r.xpdocuments_published,'',_r.xpdocuments_weight)
		RETURNING url_id INTO _id;

	-- Add reference to URL to documents
		INSERT INTO docass(
					docass_source_id, docass_source_type, docass_target_id, 
					docass_target_type, docass_purpose)
		VALUES(_r.item_id,'I',_id,'URL','S');
 
	END LOOP;
    
  UPDATE xtimp.xpdocuments
  SET xpdocuments_imported = true
  WHERE xpdocuments_import_error = '';
  
  RAISE NOTICE  'extimp Item import completed';
  RETURN(TRUE);
  END; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpdocumentsimport()
  OWNER TO admin;
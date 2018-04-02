-- Function: xtimp.xpitemmarketingimport()

-- DROP FUNCTION xtimp.xpitemmarketingimport();

CREATE OR REPLACE FUNCTION xtimp.xpitemmarketingimport()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD;
  _result INTEGER;
  _id INTEGER;

BEGIN 
-- update item with marketing details
  FOR _r IN
	  (SELECT *,item_id
	  FROM xtimp.xpitemmarketing 
	  JOIN item ON xpitemmarketing_itemnumber = item_number
	   WHERE xpitemmarketing_id >0
	   AND xpitemmarketing_imported='f' 
	   AND xpitemmarketing_checked='t'   
	   )

  LOOP
	UPDATE item
	SET 
	   item_mrkt_title=_r.xpitemmarketing_title, 
       item_mrkt_subtitle=_r.xpitemmarketing_subtitle, 
	   item_mrkt_teaser=_r.xpitemmarketing_teaser, 
	   item_mrkt_descrip=_r.xpitemmarketing_descrip, 
       item_mrkt_seokey=_r.xpitemmarketing_seokey, 
	   item_mrkt_seotitle=_r.xpitemmarketing_seotitle 
	WHERE item_id = _r.item_id;

  END LOOP;
  RAISE NOTICE  'extimp Item Marketing import completed';
  RETURN(TRUE);
  END; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpitemmarketingimport()
  OWNER TO admin;
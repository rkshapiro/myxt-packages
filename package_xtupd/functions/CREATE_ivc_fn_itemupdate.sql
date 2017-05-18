-- Function: itemupdate()

-- DROP FUNCTION itemupdate();

CREATE OR REPLACE FUNCTION itemupdate()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _classcode_id INTEGER;
  _comments TEXT;
  _prodcat_id INTEGER;
  _match_itemupdate TEXT;
  _match_item TEXT;
  _count INTEGER := 0;
 
 BEGIN
  
 FOR _r IN
 (
  SELECT itemupdate_number, itemupdate_descrip1, itemupdate_descrip2, 
       itemupdate_classcode_code, trim(both from itemupdate_comments) AS itemupdate_comments, 
       CASE 
       WHEN upper(itemupdate_sold) = 'YES' OR upper(itemupdate_sold) = 'TRUE' THEN 't'
       WHEN upper(itemupdate_sold) = 'NO' OR upper(itemupdate_sold) = 'FALSE' THEN 'f'
       ELSE itemupdate_sold
       END AS _sold, 
       itemupdate_prodweight, itemupdate_packweight, coalesce(itemupdate_prodcat_code,'-1') AS itemupdate_prodcat_code, 
       itemupdate_listprice, itemupdate_listcost, trim(both from itemupdate_extdescrip) AS itemupdate_extdescrip, itemupdate_maxcost, 
       itemupdate_lastupdated,item_id,
       item_descrip1, item_descrip2, 
       item_classcode_id, trim(both from item_comments) AS item_comments, item_sold, 
       item_prodweight, item_packweight, item_prodcat_id, 
       item_listprice, item_listcost,trim(both from item_extdescrip) AS item_extdescrip, item_maxcost
  FROM xtupd.itemupdate
  JOIN item ON itemupdate_number = item_number
  )
  
LOOP
  
    -- check for the classcode id
    IF (_r.itemupdate_classcode_code IS NOT NULL) THEN
      SELECT coalesce(classcode_id,_r.item_classcode_id) INTO _classcode_id FROM classcode WHERE classcode_code = _r.itemupdate_classcode_code;
    ELSE
      _classcode_id := _r.item_classcode_id;
    END IF;
    -- check for the comments
    IF (_r.itemupdate_comments IS NOT NULL) THEN
      -- append this to the existing comment
      IF (length(_r.item_comments) > 0 AND _r.itemupdate_comments <> _r.item_comments) THEN
        _comments := _r.item_comments||', '||_r.itemupdate_comments;
      ELSE
        _comments := _r.itemupdate_comments;
      END IF;
    ELSE
      _comments := _r.item_comments;
    END IF;
    -- check for the prodcat id
    IF (_r.itemupdate_prodcat_code = '-1') THEN
      _prodcat_id := _r.item_prodcat_id;
    ELSE
        SELECT coalesce(prodcat_id,_r.item_prodcat_id) INTO _prodcat_id FROM prodcat WHERE prodcat_code = _r.itemupdate_prodcat_code;
    END IF;
    
    -- check for a change before updating
    _match_itemupdate := concat(trim(both from _r.itemupdate_descrip1),trim(both from _r.itemupdate_descrip2),_classcode_id,_comments,_r._sold,_r.itemupdate_prodweight,_r.itemupdate_packweight,_prodcat_id,_r.itemupdate_listprice,_r.itemupdate_listcost,trim(both from _r.itemupdate_extdescrip),_r.itemupdate_maxcost);
    _match_item := concat(trim(both from _r.item_descrip1),trim(both from _r.item_descrip2),_r.item_classcode_id,_r.item_comments,_r.item_sold,_r.item_prodweight,_r.item_packweight,_r.item_prodcat_id,_r.item_listprice,_r.item_listcost,trim(both from _r.item_extdescrip),_r.item_maxcost);
    
    IF (_match_itemupdate <> _match_item) THEN
      -- update item row
      UPDATE item
        SET 
        item_descrip1=COALESCE(_r.itemupdate_descrip1,_r.item_descrip1), 
        item_descrip2=COALESCE(_r.itemupdate_descrip2,_r.item_descrip2), 
        item_classcode_id=_classcode_id, 
        item_comments=_comments, 
        item_sold=COALESCE(_r._sold::boolean,_r.item_sold), 
        item_prodweight=COALESCE(_r.itemupdate_prodweight,_r.item_prodweight), 
        item_packweight=COALESCE(_r.itemupdate_packweight,_r.item_packweight), 
        item_prodcat_id=_prodcat_id, 
        item_listprice=COALESCE(_r.itemupdate_listprice,_r.item_listprice), 
        item_listcost=COALESCE(_r.itemupdate_listcost,_r.item_listcost),
        item_extdescrip=COALESCE(_r.itemupdate_extdescrip,_r.item_extdescrip),
        item_maxcost=COALESCE(_r.itemupdate_maxcost,_r.item_maxcost),  
        item_lastupdated=current_date 
      WHERE item_id = _r.item_id;
      _count := _count + 1;
   END IF;
 
END LOOP;

   RETURN _count||' rows updated ';
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION itemupdate()
  OWNER TO admin;
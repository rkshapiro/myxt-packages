-- Function: xtimp.xpitemattributesfix()

-- DROP FUNCTION xtimp.xpitemattributesfix();

CREATE OR REPLACE FUNCTION xtimp.xpitemattributesfix()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _error text :='';
  _classcode text :='';
  _prodcat text :='';
  _clean_num text :='';
  _iuom_name text:='';
  _puom_name text:='';
 
 BEGIN
 FOR _r IN
 (
  SELECT *,item_id,uom_id
  FROM xtimp.xpitemattributes
  LEFT OUTER JOIN item ON (xpitemattributes_itemnumber = item_number)
  LEFT OUTER JOIN uom ON (xpitemattributes_productuom = uom_name)
 )
 
 
LOOP
--Fix item spaces
        
		-- Check Product UOM and create if not found
		IF _r.uom_id IS NULL THEN
            SELECT uom_name INTO _iuom_name 
            FROM uom 
            WHERE (_r.xpitemattributes_productuom = uom_name);
        
            -- has this code been seen before?
            IF NOT FOUND THEN
                INSERT INTO uom(uom_name, uom_descrip)
                VALUES (_r.xpitemattributes_productuom, 'Import');		
            END IF;
        END IF;
        
        -- remove comma from weights
        _clean_num := regexp_replace(_r.xpitemattributes_productlength,E'[$,]','','g');
        IF _clean_num <> _r.xpitemattributes_productlength THEN
            UPDATE xtimp.xpitemattributes
            SET xpitemattributes_productlength = _clean_num
            WHERE xpitemattributes_id = _r.xpitemattributes_id;
        END IF;
        _clean_num := regexp_replace(_r.xpitemattributes_productwidth,E'[$,]','','g');
        IF _clean_num <> _r.xpitemattributes_productwidth THEN
            UPDATE xtimp.xpitemattributes
            SET xpitemattributes_productwidth = _clean_num
            WHERE xpitemattributes_id = _r.xpitemattributes_id;
        END IF;
       _clean_num := regexp_replace(_r.xpitemattributes_productheight,E'[$,]','','g');
        IF _clean_num <> _r.xpitemattributes_productheight THEN
            UPDATE xtimp.xpitemattributes
            SET xpitemattributes_productheight = _clean_num
            WHERE xpitemattributes_id = _r.xpitemattributes_id;
        END IF;
        _clean_num := regexp_replace(_r.xpitemattributes_packagelength,E'[$,]','','g');
        IF _clean_num <> _r.xpitemattributes_packagelength THEN
            UPDATE xtimp.xpitemattributes
            SET xpitemattributes_packagelength = _clean_num
            WHERE xpitemattributes_id = _r.xpitemattributes_id;
        END IF;
		_clean_num := regexp_replace(_r.xpitemattributes_packagewidth,E'[$,]','','g');
        IF _clean_num <> _r.xpitemattributes_packagewidth THEN
            UPDATE xtimp.xpitemattributes
            SET xpitemattributes_packagewidth = _clean_num
            WHERE xpitemattributes_id = _r.xpitemattributes_id;
        END IF;
        _clean_num := regexp_replace(_r.xpitemattributes_packageheight,E'[$,]','','g');
        IF _clean_num <> _r.xpitemattributes_packageheight THEN
            UPDATE xtimp.xpitemattributes
            SET xpitemattributes_packageheight = _clean_num
            WHERE xpitemattributes_id = _r.xpitemattributes_id;
        END IF;
		
    END LOOP;

   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpitemattributesfix()
  OWNER TO admin;
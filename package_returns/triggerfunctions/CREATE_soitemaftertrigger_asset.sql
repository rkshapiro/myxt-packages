-- Function: _return._soitemaftertrigger_asset()

-- DROP FUNCTION _return._soitemaftertrigger_asset();

CREATE OR REPLACE FUNCTION _return._soitemaftertrigger_asset()
  RETURNS trigger AS
$BODY$
-- 2060104:rks created custom trigger to manage return dates and kit sub-line copies
DECLARE
  
  _comment RECORD;  --ASSET changed from TEXT 20150210
  _kit BOOLEAN;
  _leased BOOLEAN;
  _coitemid INTEGER;
  
BEGIN

  --Determine if this is a kit for later processing
  SELECT 
  CASE WHEN item_type = 'K' THEN
    true
  ELSE
    false
  END INTO _kit
  FROM item
  JOIN itemsite ON itemsite_item_id = item_id
  WHERE((itemsite_id = NEW.coitem_itemsite_id));

  -- is this leased product
  SELECT 
  CASE WHEN prodcat_code = 'MSC:LEASED' THEN
    true
  ELSE 
    false
  END INTO _leased
  FROM coitem
  JOIN itemsite ON coitem_itemsite_id = itemsite_id
  JOIN item ON itemsite_item_id = item_id
  JOIN prodcat ON item_prodcat_id = prodcat_id
  WHERE coitem_id = NEW.coitem_id;
  
  --RAISE NOTICE 'TG_OP % new.coitem_id % _kit % _leased %',TG_OP,NEW.coitem_id,_kit,_leased;
  
  IF (_leased) THEN
  
    IF (_kit) THEN
      -- copy RETURN DATE OVERRIDE comment from kit to line items
      PERFORM * FROM _return.salesline_return_date_override WHERE comment_coitem_id = NEW.coitem_id;
      IF (FOUND) THEN
        SELECT * INTO _comment 
        FROM COMMENT 
        WHERE comment_source_id = NEW.coitem_id 
        AND comment_cmnttype_id = (SELECT cmnttype_id FROM cmnttype WHERE cmnttype_name = 'RETURN DATE Override');
        FOR _coitemid IN
          SELECT coitem_id
          FROM coitem
          JOIN _return.salesline_rental_period ON salesline_coitem_id = coitem_id
          WHERE ((coitem_cohead_id=NEW.coitem_cohead_id)
          AND   (coitem_linenumber=NEW.coitem_linenumber)
          AND   (coitem_subnumber > 0) )
        LOOP 
          PERFORM postcomment(_comment.comment_cmnttype_id,'SI',_coitemid,_comment.comment_text); 
        END LOOP;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION _return._soitemaftertrigger_asset()
  OWNER TO mfgadmin;

DROP TRIGGER IF EXISTS soitemaftertrigger_asset ON public.coitem;

CREATE TRIGGER soitemaftertrigger_asset
  AFTER INSERT OR UPDATE
  ON public.coitem
  FOR EACH ROW
  EXECUTE PROCEDURE _return._soitemaftertrigger_asset();

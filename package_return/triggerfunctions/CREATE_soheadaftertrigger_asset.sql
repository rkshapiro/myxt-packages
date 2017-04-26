-- Function: _return._soheadaftertrigger_asset()

-- DROP FUNCTION _return._soheadaftertrigger_asset();

CREATE OR REPLACE FUNCTION _return._soheadaftertrigger_asset()
  RETURNS trigger AS
$BODY$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
-- ASSET 4.9.2 custom trigger to set set the return date for leased items.

DECLARE
 _lineitem  RECORD;
 _coitemid  INTEGER;
 _returndate DATE;
 _newreturndate DATE;
 _charassid INTEGER;
 
BEGIN
  
  -- loop through the leased items on this and set the return date
  FOR _coitemid IN
    SELECT coitem_id
	FROM coitem
	JOIN cohead ON coitem_cohead_id = cohead_id
	JOIN itemsite ON coitem_itemsite_id = itemsite_id
	JOIN item ON itemsite_item_id = item_id
	JOIN prodcat ON item_prodcat_id = prodcat_id
	WHERE cohead_id = NEW.cohead_id
	AND prodcat_code = 'MSC:LEASED'
  LOOP
	SELECT * INTO _lineitem
	FROM coitem
	WHERE coitem_id = _coitemid;
		
	SELECT _return.getreturndate(_coitemid,_lineitem.coitem_scheddate) INTO _newreturndate;
	-- check for an existing characteristic or create one
	SELECT charass_id, charass_value INTO _charassid, _returndate
	FROM charass
	JOIN char ON charass_char_id = char_id
	WHERE charass_target_id = _coitemid
	AND char_name = 'RETURN DATE';
	  
	--RAISE NOTICE 'NEW.coitem_id % _charassid %',_coitemid,_charassid;
	  
    IF (FOUND) THEN
	  UPDATE charass
	  SET charass_value = _newreturndate
	  WHERE charass_id = _charassid;

	ELSE
      INSERT INTO charass(charass_target_type, charass_target_id, charass_char_id, charass_value)
      VALUES ('SI',_coitemid,(SELECT char_id FROM char WHERE char_name ='RETURN DATE'),_newreturndate);
	END IF;

  END LOOP;
  
  RETURN NEW; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION _return._soheadaftertrigger_asset()
  OWNER TO mfgadmin;
  
DROP TRIGGER IF EXISTS soheadaftertrigger_asset ON public.cohead;

CREATE TRIGGER soheadaftertrigger_asset
  AFTER INSERT OR UPDATE
  ON public.cohead
  FOR EACH ROW
  EXECUTE PROCEDURE _return._soheadaftertrigger_asset();

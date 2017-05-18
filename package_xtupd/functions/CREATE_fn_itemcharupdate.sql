-- Function: xtupd.itemcharupdate()

-- DROP FUNCTION xtupd.itemcharupdate();

CREATE OR REPLACE FUNCTION xtupd.itemcharupdate()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _eccnid INTEGER;
  _exportbanid INTEGER;
  _originid INTEGER;
  _stcodeid INTEGER;
  _tariffcodeid INTEGER;
  _xreviewedid INTEGER;
  _cleanvalue TEXT;
 
 BEGIN
 -- capture the char ids
  SELECT char_id INTO _eccnid FROM char WHERE char_name = 'ECCN';
  SELECT char_id INTO _exportbanid FROM char WHERE char_name = 'EXPORTBAN';
  SELECT char_id INTO _originid FROM char WHERE char_name = 'ORIGIN';
  SELECT char_id INTO _stcodeid FROM char WHERE char_name = 'STCODE';
  SELECT char_id INTO _tariffcodeid FROM char WHERE char_name = 'TARIFFCODE';
  SELECT char_id INTO _xreviewedid FROM char WHERE char_name = 'XREVIEWED';
 
 FOR _r IN
 (
  SELECT itemcharupdate_id, itemnumber, description, classcode, uom, trim(both from eccn) AS eccn, 
       trim(both from exportban) AS exportban, trim(both from origin) AS origin, trim(both from stcode) AS stcode, trim(both from tariffcode) AS tariffcode, trim(both from xreviewed) AS xreviewed, item_id
  FROM xtupd.itemcharupdate
  JOIN item ON (itemnumber = item_number)
  )
  
LOOP
    -- check for the eccn characteristic
    IF (_r.eccn IS NOT NULL) THEN
      _cleanvalue = trim(both from replace(itemcharvalue(_r.item_id,'ECCN'),E'\n',''));
      IF (_cleanvalue = '') THEN
        -- insert characteristic
        INSERT INTO charass(
                charass_target_type, charass_target_id, charass_char_id, 
                charass_value, charass_default)
        VALUES ('I',_r.item_id,_eccnid,_r.eccn,FALSE);
        
        PERFORM postComment('ChangeLog', 'I', _r.item_id, 'ECCN Created');

      ELSE IF (_cleanvalue <> _r.eccn) THEN
            -- update the value if it is different
            
            PERFORM postComment('ChangeLog', 'I', _r.item_id, 'ECCN',
                   _cleanvalue, _r.eccn);
            
            UPDATE charass
            SET  charass_value = _r.eccn
            WHERE charass_target_id = _r.item_id
            AND charass_target_type = 'I'
            AND charass_char_id = _eccnid;
            
         END IF;
      END IF;
    END IF;
    -- check for the exportban characteristic
    IF (_r.exportban IS NOT NULL) THEN
      _cleanvalue = trim(both from replace(itemcharvalue(_r.item_id,'EXPORTBAN'),E'\n',''));
      IF (_cleanvalue = '') THEN     
        -- insert characteristic
        INSERT INTO charass(
                charass_target_type, charass_target_id, charass_char_id, 
                charass_value, charass_default)
        VALUES ('I',_r.item_id,_exportbanid,_r.exportban,FALSE);
        
        PERFORM postComment('ChangeLog', 'I', _r.item_id, 'EXPORTBAN Created');
        
      ELSE IF (_cleanvalue <> _r.exportban) THEN
              -- update the value if it is different
              
            PERFORM postComment('ChangeLog', 'I', _r.item_id, 'EXPORTBAN',
                   _cleanvalue, _r.exportban);
                  
            UPDATE charass
            SET  charass_value = _r.exportban
            WHERE charass_target_id = _r.item_id
            AND charass_target_type = 'I'
            AND charass_char_id = _exportbanid;
                       
         END IF;
      END IF;
    END IF;
    -- check for the origin characteristic
    IF (_r.origin IS NOT NULL) THEN
      _cleanvalue = trim(both from replace(itemcharvalue(_r.item_id,'ORIGIN'),E'\n',''));
      IF (_cleanvalue = '') THEN
        -- insert characteristic
        INSERT INTO charass(
                charass_target_type, charass_target_id, charass_char_id, 
                charass_value, charass_default)
        VALUES ('I',_r.item_id,_originid,_r.origin,FALSE);
        
        PERFORM postComment('ChangeLog', 'I', _r.item_id, 'ORIGIN Created');   
        
      ELSE IF (_cleanvalue <> _r.origin) THEN
              -- update the value if it is different
              
            PERFORM postComment('ChangeLog', 'I', _r.item_id, 'ORIGIN',
                   _cleanvalue, _r.origin);
                   
            UPDATE charass
            SET  charass_value = _r.origin
            WHERE charass_target_id = _r.item_id
            AND charass_target_type = 'I'
            AND charass_char_id = _originid;
            
         END IF;
      END IF;
    END IF;
    -- check for the stcode characteristic
    IF (_r.stcode IS NOT NULL) THEN
      _cleanvalue = trim(both from replace(itemcharvalue(_r.item_id,'STCODE'),E'\n',''));
      IF (_cleanvalue = '') THEN
        -- insert characteristic
        INSERT INTO charass(
                charass_target_type, charass_target_id, charass_char_id, 
                charass_value, charass_default)
        VALUES ('I',_r.item_id,_stcodeid,_r.stcode,FALSE);
        
        PERFORM postComment('ChangeLog', 'I', _r.item_id, 'STCODE Created');  
        
      ELSE IF (_cleanvalue <> _r.stcode) THEN
            -- update the value if it is different
        
            PERFORM postComment('ChangeLog', 'I', _r.item_id, 'STCODE',
                   _cleanvalue, _r.stcode);
                   
            UPDATE charass
            SET  charass_value = _r.stcode
            WHERE charass_target_id = _r.item_id
            AND charass_target_type = 'I'
            AND charass_char_id = _stcodeid;
 
         END IF;
      END IF;
    END IF;
    -- check for the tariffcode characteristic
    IF (_r.tariffcode IS NOT NULL) THEN
      _cleanvalue = trim(both from replace(itemcharvalue(_r.item_id,'TARIFFCODE'),E'\n',''));
      IF (_cleanvalue = '') THEN
        -- insert characteristic
        INSERT INTO charass(
                charass_target_type, charass_target_id, charass_char_id, 
                charass_value, charass_default)
        VALUES ('I',_r.item_id,_tariffcodeid,_r.tariffcode,FALSE);
        
        PERFORM postComment('ChangeLog', 'I', _r.item_id, 'TARIFFCODE Created');
        
      ELSE IF (_cleanvalue <> _r.tariffcode) THEN
              -- update the value if it is different
              
            PERFORM postComment('ChangeLog', 'I', _r.item_id, 'TARIFFCODE',
                   _cleanvalue, _r.tariffcode);
                   
            UPDATE charass
            SET  charass_value = _r.tariffcode
            WHERE charass_target_id = _r.item_id
            AND charass_target_type = 'I'
            AND charass_char_id = _tariffcodeid;

         END IF;
      END IF;
    END IF;
    -- check for the xreviewed characteristic
    IF (_r.xreviewed IS NOT NULL) THEN
      _cleanvalue = trim(both from replace(itemcharvalue(_r.item_id,'XREVIEWED'),E'\n',''));
      IF (_cleanvalue = '') THEN
        -- insert characteristic
        INSERT INTO charass(
                charass_target_type, charass_target_id, charass_char_id, 
                charass_value, charass_default)
        VALUES ('I',_r.item_id,_xreviewedid,_r.xreviewed,FALSE);
        
        PERFORM postComment('ChangeLog', 'I', _r.item_id, 'XREVIEWED Created');
        
      ELSE IF (_cleanvalue <> _r.xreviewed) THEN
            -- update the value if it is different
            
            PERFORM postComment('ChangeLog', 'I', _r.item_id, 'XREVIEWED',
                   _cleanvalue, _r.xreviewed);
                   
            UPDATE charass
            SET  charass_value = _r.xreviewed
            WHERE charass_target_id = _r.item_id
            AND charass_target_type = 'I'
            AND charass_char_id = _xreviewedid;
           
         END IF;
      END IF;
    END IF;
       
END LOOP;

   RETURN 0;
   END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtupd.itemcharupdate()
  OWNER TO admin;

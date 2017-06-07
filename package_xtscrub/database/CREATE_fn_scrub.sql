-- Function: scrub()

-- DROP FUNCTION scrub();

CREATE OR REPLACE FUNCTION scrub()
  RETURNS text AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD; 
  _stmt RECORD;
  _cleanvalue TEXT;
  _count INTEGER;
  _err INTEGER;

 BEGIN
 _count = 0;
 _err = 0;
--create the query string
 FOR _stmt IN
 
    SELECT  schema,tablename,tablepkey,field,
    format('SELECT %s AS id, %s AS field FROM %s.%s',tablepkey,field,schema,tablename) AS qry
    FROM scrublist
 
 LOOP
 
 FOR _r IN
 
  EXECUTE _stmt.qry
  
  LOOP
-- in the replace function below the flag g specifies replacement of each matching substring rather than only the first one  
    _cleanvalue = regexp_replace(trim(both from _r.field),E'[\n\r\t]',' ','g');
    IF (_cleanvalue <> _r.field) THEN
      BEGIN
        EXECUTE 'UPDATE '||_stmt.schema||'.'||_stmt.tablename::regclass
                ||' SET '||_stmt.field||' = '||quote_literal(_cleanvalue)
                ||'WHERE '||_stmt.tablepkey||' = '||_r.id;
        _count = _count + 1;
      EXCEPTION WHEN sqlstate 'XX000' THEN
        _err = _err + 1;
      END;
    END IF;
                 
  END LOOP;
 END LOOP;

 RETURN _count||' updates '||_err||' errors';
 END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION scrub()
  OWNER TO admin;
-- Function: ivc.scrub()

-- DROP FUNCTION ivc.scrub();

CREATE OR REPLACE FUNCTION ivc.scrub()
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
    FROM ivc.scrublist
 
 LOOP
 
 FOR _r IN
 
  EXECUTE _stmt.qry
  
  LOOP
    _cleanvalue = trim(both from replace(_r.field,'\n\t',''));
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
ALTER FUNCTION ivc.scrub()
  OWNER TO admin;
CREATE OR REPLACE FUNCTION ivc.scrub() RETURNS INTEGER AS
$BODY$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _count      INTEGER := 0;
  _fields     TEXT[];
  _i          INTEGER := 0;
  _s          RECORD;
  _stmtcount  INTEGER := 0;
 
BEGIN

  FOR _s IN SELECT schema, tablename, tablepkey, field FROM ivc.scrublist LOOP

    _fields := string_to_array(_s.field, ' ');
    FOR _i IN array_length(_fields, 1) LOOP
      -- or replace(trim(), '\n\t', '') if that's the right thing to do
      _fields[_i] := _fields[_i] || ' = trim(' + _fields[_i] + ')';
    END LOOP:

    EXECUTE format('UPDATE %L.%L SET %s;', _s.tablepkey, _s.field, array_to_string(_fields, ', '));
    GET DIAGNOSTICS _stmtcount = ROW_COUNT;
    _count := _count + _stmtcount;
  END LOOP;

  RETURN _count;

END;
$BODY$ LANGUAGE plpgsql;

ALTER FUNCTION ivc.scrub() OWNER TO admin;
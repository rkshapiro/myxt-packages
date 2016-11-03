CREATE OR REPLACE FUNCTION autocreatels(integer)
  RETURNS integer AS
$BODY$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/EULA for the full text of the software license.
DECLARE
  pItemlocdistId ALIAS FOR $1;
  _i INTEGER;
  _itemlocseries INTEGER;
  _r RECORD;
  _rows INTEGER;
  _lsNumber TEXT;
BEGIN

  -- Fetch data for processing
  SELECT itemlocdist_qty, itemsite_controlmethod, 
    itemsite_perishable, itemsite_warrpurc, itemsite_lsseq_id, 
    invhist_ordtype, invhist_ordnumber, lsseq_number, invhist_transtype
  INTO _r
  FROM itemlocdist
    JOIN itemsite ON (itemlocdist_itemsite_id=itemsite_id)
    JOIN invhist ON (itemlocdist_invhist_id=invhist_id)
    JOIN lsseq ON (itemsite_lsseq_id=lsseq_id)
  WHERE (itemlocdist_id=pItemlocdistId);

    -- Validate
  GET DIAGNOSTICS _rows = ROW_COUNT;
  IF (_rows = 0) THEN
    RAISE NOTICE 'Itemlocdist record does not exist for id %', pItemlocdistId;
    RETURN -1;
  ELSIF (_r.itemsite_controlmethod NOT IN ('L','S')) THEN
    RAISE NOTICE 'Auto create for lot/serial can only be used on lot or serial controlled items';
    RETURN -1;
  ELSIF (_r.itemsite_perishable) THEN
    RAISE NOTICE 'Auto create for lot/serial can not be used on perishable items sites';
    RETURN -1;
  ELSIF (_r.itemsite_warrpurc) THEN
    RAISE NOTICE 'Auto create for lot/serial can not be used on items sites with purchase warranty';
    RETURN -1;
  ELSIF (_r.itemsite_lsseq_id IS NULL) THEN
    RAISE NOTICE 'Auto create for lot/serial requires a lot/serial sequence id';
    RETURN -1;
  END IF;

  _itemlocseries := NEXTVAL('itemloc_series_seq');

  -- Prepare Lot/Serial #
  IF (_r.itemsite_controlmethod = 'L' AND _r.lsseq_number = 'WO' AND _r.invhist_ordtype = 'WO' AND _r.invhist_transtype = 'RM') THEN
    _lsNumber := _r.invhist_ordnumber;  -- Allurion request for whole WO number
--	_lsNumber := split_part(_r.invhist_ordnumber, '-', 1);
  ELSE 
    _lsNumber := fetchlsnumber(_r.itemsite_lsseq_id);
  END IF;

  -- Process
  IF (_r.itemsite_controlmethod = 'L') THEN
    -- Create lot number
    PERFORM createlotserial(itemlocdist_itemsite_id, _lsNumber,
                           _itemlocseries, 'I', NULL,itemlocdist_id, itemlocdist_qty, 
                           startOfTime(), NULL)
    FROM itemlocdist 
    WHERE (itemlocdist_id=pItemlocdistId);
  ELSE
    -- Create serial number for each one
    FOR _i IN 1.._r.itemlocdist_qty::integer
    LOOP
      PERFORM createlotserial(itemlocdist_itemsite_id,fetchlsnumber(_r.itemsite_lsseq_id),
                             _itemlocseries, 'I', NULL,itemlocdist_id, 1, 
                             startOfTime(), NULL)
      FROM itemlocdist 
      WHERE (itemlocdist_id=pItemlocdistId);
    END LOOP;
  END IF;

  RETURN _itemlocseries;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION autocreatels(integer)
  OWNER TO admin;

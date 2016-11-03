CREATE OR REPLACE FUNCTION convertbom2boo (integer,integer,text)
  RETURNS text AS
$BODY$
DECLARE

-- 20161014:rks initial version
-- 20161103:rks fixed SAI issue

pnewid ALIAS FOR $1; -- new consumable or durable mfg item
pkitid ALIAS FOR $2; -- original kit being converted
pclasscode_pattern ALIAS FOR $3; -- class code pattern to identify components
_newitemid INTEGER := pnewid;
_newitemnumber TEXT;
_newboohead INTEGER;
_newbomhead INTEGER;
_r RECORD;
_revision TEXT := 'R1';
_effective DATE := current_date;
_workctr TEXT := 'PACK';
_booitemseqid INTEGER;
_booitemid INTEGER;
_stdopn TEXT := ' ';
_booitemseqnum INTEGER;

BEGIN

-- check permissions
IF (NOT checkPrivilege('MaintainBOMs') AND NOT checkPrivilege('MaintainBOOs')) THEN
  RAISE EXCEPTION 'User has insufficient permissions for this operation';
  RETURN 'Stop';
END IF;

SELECT item_number INTO _newitemnumber FROM item WHERE item_id = pnewid;

--SELECT createNewItem(_newitemnumber,pkitid) INTO _newitemid;

-- create the boohead for the new item
INSERT INTO xtmfg.api_boo
(item_number, revision, revision_date, final_warehouse)
SELECT item_number,_revision,_effective,'ASSET1'
FROM item
WHERE item_id = _newitemid;

-- create the bomhead for the new item
INSERT INTO api.bom (item_number, revision, revision_date, batch_size)
SELECT item_number,_revision,_effective,1
FROM item
WHERE item_id = _newitemid; 

SELECT boohead_id INTO _newboohead FROM xtmfg.boohead WHERE boohead_item_id = _newitemid;
SELECT bomhead_id INTO _newbomhead FROM bomhead WHERE bomhead_item_id = _newitemid;

-- loop through levels 0,1,2 and get the component and assembly items by box
_booitemid := 0;
_booitemseqnum := 0;

FOR _r IN SELECT bomdata_item_number,bomdata_item_id,bomitem_qtyper, bomitem_scrap, bomitem_effective, 
            bomitem_expires, bomitem_createwo, bomitem_issuemethod, bomitem_schedatwooper, 
            bomitem_ecn, bomitem_moddate, bomitem_subtype, bomitem_uom_id, 
            bomitem_rev_id, bomitem_booitem_seq_id, bomitem_char_id, bomitem_value, 
            bomitem_notes, bomitem_ref, bomitem_qtyfxd, bomitem_issuewo,classcode_code,bomdata_bomwork_level,bomdata_seq_ord
from indentedbom(pkitid,getactiverevid('BOM',pkitid),365,365) bom
join bomitem ON bomitem_id = bom.bomdata_bomitem_id
join item ON bomitem_item_id = item_id 
join classcode ON classcode_id = item_classcode_id
where item_active
and bomdata_bomwork_level = 1
order by bomdata_seq_ord

LOOP
	-- create the booitem for the ship as is for any items at level 1
	IF (_r.classcode_code ~ pclasscode_pattern) THEN
	  -- CREATE THE SAI OPERATION
	  IF (_booitemid = 0) THEN
		_booitemseqnum := _booitemseqnum + 10;
		INSERT INTO xtmfg.api_booitem
		(boo_item_number, boo_revision, sequence_number,execution_day, effective, expires, standard_oper,work_center)
		VALUES (_newitemnumber,_revision,_booitemseqnum,1,_effective,'2100-01-01','SAI',_workctr);
	  
		SELECT booitem_seq_id INTO _booitemseqid FROM xtmfg.booitem WHERE booitem_item_id = _newitemid AND booitem_seqnumber = _booitemseqnum;
	  END IF;
	  -- create the bomitems
	  INSERT INTO bomitem(
				bomitem_parent_item_id, bomitem_item_id, 
				bomitem_qtyper, bomitem_scrap, bomitem_effective, 
				bomitem_expires, bomitem_createwo, bomitem_issuemethod, bomitem_schedatwooper, 
				bomitem_ecn, bomitem_moddate, bomitem_subtype, bomitem_uom_id, 
				bomitem_rev_id, bomitem_booitem_seq_id, bomitem_char_id, bomitem_value, 
				bomitem_notes, bomitem_ref, bomitem_qtyfxd, bomitem_issuewo)
	  VALUES (_newitemid,_r.bomdata_item_id,
				_r.bomitem_qtyper, _r.bomitem_scrap, _r.bomitem_effective, 
				_r.bomitem_expires, _r.bomitem_createwo, _r.bomitem_issuemethod, _r.bomitem_schedatwooper, 
				_r.bomitem_ecn, _r.bomitem_moddate, _r.bomitem_subtype, _r.bomitem_uom_id, 
				getactiverevid('BOM',_newitemid),_booitemseqid, _r.bomitem_char_id, _r.bomitem_value, 
				_r.bomitem_notes, _r.bomitem_ref, _r.bomitem_qtyfxd, _r.bomitem_issuewo);
	END IF;
END LOOP;

-- create the abox operations
FOR _r IN SELECT c.item_number,c.item_id as itemid,bomitem_qtyper, bomitem_scrap, bomitem_effective, 
            bomitem_expires, bomitem_createwo, bomitem_issuemethod, bomitem_schedatwooper, 
            bomitem_ecn, bomitem_moddate, bomitem_subtype, bomitem_uom_id, 
            bomitem_rev_id, bomitem_booitem_seq_id, bomitem_char_id, bomitem_value, 
            bomitem_notes, bomitem_ref, bomitem_qtyfxd, bomitem_issuewo,pc.classcode_code AS pclasscode,
			cc.classcode_code AS cclasscode,p.item_number AS pitemnumber,bomitem_parent_item_id,bomitem_seqnumber
from bomitem 
join item c ON bomitem_item_id = c.item_id 
join item p ON bomitem_parent_item_id = p.item_id 
join classcode pc ON pc.classcode_id = p.item_classcode_id 
join classcode cc ON cc.classcode_id = c.item_classcode_id
where bomitem_parent_item_id in (
SELECT bomdata_item_id
from indentedbom(pkitid,getactiverevid('BOM',pkitid),365,365) bom
where bomdata_bomwork_level = 1)
and bomitem_rev_id = getactiverevid('BOM',bomitem_parent_item_id)
and p.item_active
order by bomitem_parent_item_id,bomitem_seqnumber
LOOP

	IF (_r.pclasscode = 'FG') AND(substring(_r.pitemnumber from 'A[0-9]{1,2}$') <> _stdopn) THEN
	  -- CREATE AN ABOX OPERATION
		_stdopn = substring(_r.pitemnumber from 'A[0-9]{1,2}$');
		_booitemseqnum := _booitemseqnum + 10;
		INSERT INTO xtmfg.api_booitem
		  (boo_item_number, boo_revision, sequence_number, execution_day, effective, expires, standard_oper,work_center)
		  VALUES (_newitemnumber,_revision,_booitemseqnum,1,_effective,'2100-01-01',_stdopn,_workctr); 

		SELECT booitem_seq_id INTO _booitemseqid FROM xtmfg.booitem WHERE booitem_item_id = _newitemid AND booitem_seqnumber = _booitemseqnum;
		
	END IF;

	IF (_r.cclasscode ~ pclasscode_pattern) THEN
	-- CREATE THE BOM ITEM FOR THE NEW ITEM
	  INSERT INTO bomitem(
				bomitem_parent_item_id, bomitem_item_id, 
				bomitem_qtyper, bomitem_scrap, bomitem_effective, 
				bomitem_expires, bomitem_createwo, bomitem_issuemethod, bomitem_schedatwooper, 
				bomitem_ecn, bomitem_moddate, bomitem_subtype, bomitem_uom_id, 
				bomitem_rev_id, bomitem_booitem_seq_id, bomitem_char_id, bomitem_value, 
				bomitem_notes, bomitem_ref, bomitem_qtyfxd, bomitem_issuewo)
	  VALUES (_newitemid,_r.itemid,
				_r.bomitem_qtyper, _r.bomitem_scrap, _r.bomitem_effective, 
				_r.bomitem_expires, _r.bomitem_createwo, _r.bomitem_issuemethod, _r.bomitem_schedatwooper, 
				_r.bomitem_ecn, _r.bomitem_moddate, _r.bomitem_subtype, _r.bomitem_uom_id, 
				getactiverevid('BOM',_newitemid),_booitemseqid, _r.bomitem_char_id, _r.bomitem_value, 
				_r.bomitem_notes, _r.bomitem_ref, _r.bomitem_qtyfxd, _r.bomitem_issuewo);
	END IF;
END LOOP; -- FOR
RETURN _newitemnumber;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION convertbom2boo(integer,integer,text)
  OWNER TO admin;
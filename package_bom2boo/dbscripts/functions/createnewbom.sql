CREATE OR REPLACE FUNCTION createnewbom (text,text,text)
  RETURNS text AS
$BODY$
DECLARE

-- 20161014:rks initial version

pnewnumber ALIAS FOR $1;
pconsumablenumber ALIAS FOR $2;
pdurablenumber ALIAS FOR $3;

BEGIN

-- check permissions
IF (NOT checkPrivilege('MaintainBOMs') AND NOT checkPrivilege('MaintainBOOs')) THEN
  RAISE EXCEPTION 'User has insufficient permissions for this operation';
  RETURN 'Stop';
END IF;

-- create BOM head for the new kit
INSERT INTO api.bom (item_number, revision, revision_date, batch_size)
VALUES (pnewnumber,'R1',current_date,1); 

-- create a bomitem for the consumables
INSERT INTO api.bomitem (bom_item_number, bom_revision, sequence_number, item_number, 
       effective, expires, qty_per, issue_uom, scrap, create_child_wo, 
       issue_method, used_at, schedule_at_wo_operation, ecn_number, 
       notes, reference, substitutions)
VALUES (pnewnumber,'R1','10',pconsumablenumber,
        current_date,'2100-01-01',1,'EA',0,false,
		'Mixed',NULL,false,'',
		'','','Item-Defined');

-- create a bomitem for the durables
INSERT INTO api.bomitem (bom_item_number, bom_revision, sequence_number, item_number, 
       effective, expires, qty_per, issue_uom, scrap, create_child_wo, 
       issue_method, used_at, schedule_at_wo_operation, ecn_number, 
       notes, reference, substitutions)
VALUES (pnewnumber,'R1','20',pdurablenumber,
        current_date,'2100-01-01',1,'EA',0,false,
		'Mixed',NULL,false,'',
		'','','Item-Defined');
		
RETURN 'BOM Created';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION createnewbom (text,text,text)
  OWNER TO admin;
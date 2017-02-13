-- Function:  importinventory()

-- DROP FUNCTION  importinventory();

CREATE OR REPLACE FUNCTION  importinventory()
  RETURNS integer AS
$BODY$
DECLARE
  _x RECORD;
  _i integer;

BEGIN
	_i=0;

	FOR _x IN
		SELECT 
			invimport_location,
			invimport_sku,
			invimport_uom_desc,
			invimport_qty,
			invimport_site_id
		FROM  invimport
	LOOP
		INSERT INTO cntslip(
			cntslip_cnttag_id, 
			cntslip_entered,
			cntslip_posted,
			cntslip_number,
			cntslip_qty,
			cntslip_comments,
			cntslip_location_id,
			cntslip_username)
		VALUES(
			(SELECT invcnt_id 
			 FROM invcnt 
			 JOIN itemsite ON invcnt_itemsite_id=itemsite_id 
			 JOIN item ON itemsite_item_id = item_id 
			 JOIN whsinfo ON itemsite_warehous_id=warehous_id 
			 WHERE warehous_code=_x.invimport_site_id
			 AND item_number=_x.invimport_sku
			 LIMIT 1
			),
			CURRENT_TIMESTAMP,
			false,
			(SELECT to_char(nextval('cntslip_cntslip_id_seq'),'FM999999999999999')),
			_x.invimport_qty,
			'WMS Bulk Import'::text,
			(SELECT location_id FROM location WHERE location_descrip=trim(_x.invimport_location)),
			'admin'::text
		);
	
		_i=_i+1;
	END LOOP;

	RETURN _i;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION  importinventory() OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  importinventory() TO "admin";

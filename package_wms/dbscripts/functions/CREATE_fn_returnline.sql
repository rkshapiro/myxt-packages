-- Function:  returnline(date)

-- DROP FUNCTION  returnline(date);

CREATE OR REPLACE FUNCTION  returnline(IN _authdate_cutoff date, OUT _ra_number character varying, OUT _raline_number integer, OUT _raline_subnumber integer, OUT _raline_status character, OUT _raline_item_number character varying, OUT _raline_uom character varying, OUT _so_number character varying, OUT _soline_number integer, OUT _soline_subnumber integer, OUT _soline_item_number character varying, OUT _soline_shipped_qty numeric, OUT _warehouse_code character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
  _x RECORD;
  _y RECORD;
  _cohead_id INTEGER;
  _cohead_number TEXT;
  _rahead_id INTEGER;
  __warehouse_code character varying;

BEGIN
	-- 20140310:jjb added _warehouse_code as an output parameter
	-- 20130904:rks added filter to exclude canceled sales lines
	-- 20130904:jjb Test version where it does not rely on a custom type for a return value
	-- 20130905:jjb Function now takes the authdate cutoff as the only IN parameter and grabs everything from that auth date on 
	-- 20130906:jjb Cleaned up the input params for consistencys sake
	-- 20130911:jjb Replaced the concatenated RA and PO lines with integer RA and PO line numbers and new fields for line subnumbers 

	FOR _y IN
		SELECT DISTINCT rahead_number as __ra_number
		FROM rahead
		WHERE rahead_authdate > _authdate_cutoff
	LOOP	
		-- We must find the SO number for this RA number
		-- While as of this writing they are the same number that could change in the future
		-- So we need to work through the database starting at the RA and get the official real number
		-- If we feed in a nonexistent RA number but the equivalent SO number exists nothing is returned
		-- We are not making the assumption that the RA number and SO number are the same number
		-- And when there is no RA number it is impossible to look at it and find out the SO number

		SELECT COALESCE(rahead_new_cohead_id, rahead_orig_cohead_id) INTO _cohead_id
		FROM rahead
		WHERE rahead_number=(SELECT _y.__ra_number);

		SELECT rahead_id INTO _rahead_id
		FROM rahead
		WHERE rahead_number=(SELECT _y.__ra_number);

		SELECT warehous_code INTO __warehouse_code
		FROM rahead
		LEFT JOIN whsinfo ON rahead_warehous_id=warehous_id
		WHERE rahead_number=(SELECT _y.__ra_number);


		FOR _x IN
			SELECT	COALESCE(coitem_raitem.rahead_number, (SELECT _y.__ra_number))::character varying(255) AS ___ra_number, 
			        raitem_linenumber AS __raline_number,
			        raitem_subnumber AS __raline_subnumber,
				raitem_status AS __raline_status,
				 coitem_raitem.item_number::character varying(255) AS __raline_item_number,
				(SELECT uom_name::character varying(255)
				 FROM uom
				 WHERE raitem_qty_uom_id=uom_id) AS __raline_uom,
				cohead_number::character varying(255) AS __so_number, 
				(SELECT coitem_linenumber FROM coitem WHERE coitem_id=c.coitem_id) as __soline_number,
				(SELECT coitem_subnumber FROM coitem WHERE coitem_id=c.coitem_id) as __soline_subnumber,			
				si.item_number::character varying(255) AS __soline_item_number,
				coitem_qtyshipped AS __soline_shipped_qty
				
			FROM cohead

				JOIN coitem c ON coitem_cohead_id = cohead_id
				LEFT OUTER JOIN _wms.coitem_raitem ON coitem_id = coitem_raitem_coitem_id
					AND  coitem_raitem.rahead_number=(SELECT _y.__ra_number)	
				JOIN itemsite sis ON c.coitem_itemsite_id=sis.itemsite_id
				JOIN item si ON sis.itemsite_item_id=si.item_id
				JOIN classcode scc ON si.item_classcode_id=scc.classcode_id
				LEFT OUTER JOIN itemsite ris ON  coitem_raitem.raitem_itemsite_id=ris.itemsite_id
				LEFT OUTER JOIN item ri ON ris.itemsite_item_id=ri.item_id
					AND ri.item_type<>'K'
				LEFT OUTER JOIN classcode rcc ON ri.item_classcode_id=rcc.classcode_id
					AND rcc.classcode_code<>'DROPSHIP'
			WHERE 
				si.item_type<>'K'
				AND scc.classcode_code<>'DROPSHIP'
				AND cohead.cohead_id=_cohead_id	
				AND c.coitem_status <> 'X'
			ORDER BY 1,2

		LOOP
			RETURN QUERY SELECT 
				_x.___ra_number,
				_x.__raline_number,
				_x.__raline_subnumber,
				_x.__raline_status,
				_x.__raline_item_number,
				_x.__raline_uom,		
				_x.__so_number,
				_x.__soline_number,
				_x.__soline_subnumber,
				_x.__soline_item_number, 
				_x.__soline_shipped_qty,
				__warehouse_code;
		END LOOP;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 1000
  ROWS 100;
ALTER FUNCTION  returnline(date) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  returnline(date) TO public;
GRANT EXECUTE ON FUNCTION  returnline(date) TO "admin";
GRANT EXECUTE ON FUNCTION  returnline(date) TO xtrole;

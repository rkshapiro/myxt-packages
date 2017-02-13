-- Function:  insertwavebatch(character varying, character varying, integer, character varying, integer)

-- DROP FUNCTION  insertwavebatch(character varying, character varying, integer, character varying, integer);

CREATE OR REPLACE FUNCTION  insertwavebatch(character varying, character varying, integer, character varying, integer DEFAULT 0)
  RETURNS integer AS
$BODY$
DECLARE
_item_number		ALIAS FOR $1;
_license_plate_number 	ALIAS FOR $2;
_wave_number		ALIAS FOR $3; 
_sales_order_number	ALIAS FOR $4;
_wavebatch_id		INTEGER;
_wavebatch_so_linenumber	ALIAS FOR $5;

BEGIN 

SELECT NEXTVAL(' wavebatch_wavebatch_id_seq') INTO _wavebatch_id;

INSERT INTO  wavebatch(
	wavebatch_id, 
	wavebatch_item_number, 
	wavebatch_license_plate_number, 
	wavebatch_wave_number, 
	wavebatch_sales_order_number,
	wavebatch_so_linenumber -- 20140912 rek added Orbit 596
	)
VALUES(
	_wavebatch_id,
	_item_number::text,
	_license_plate_number::text,
	_wave_number,
	_sales_order_number::text,
	_wavebatch_so_linenumber  -- 20140912 rek added Orbit 596
);

RETURN _wavebatch_id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION  insertwavebatch(character varying, character varying, integer, character varying, integer) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  insertwavebatch(character varying, character varying, integer, character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION  insertwavebatch(character varying, character varying, integer, character varying, integer) TO "admin";
GRANT EXECUTE ON FUNCTION  insertwavebatch(character varying, character varying, integer, character varying, integer) TO xtrole;

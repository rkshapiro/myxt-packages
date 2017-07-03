-- Function: getreturndate(integer, date)

-- DROP FUNCTION getreturndate(integer, date);

CREATE OR REPLACE FUNCTION getreturndate(integer, date)
  RETURNS date AS
$BODY$
-- 20130425:rks ASSET added in new rental period names
-- 20130522:rks added schema to isfinalsale reference
	DECLARE
	pcoitem_id ALIAS FOR $1;
	pScheddate ALIAS FOR $2;
	_rentalDays INTEGER;
	_scheddate date;
	_period TEXT;
	_override_date date;

	BEGIN
	-- check for a final sale where a return date is not needed
	IF (SELECT _return.isfinalsale(coitem_cohead_id) from coitem where coitem_id = pcoitem_id) THEN 
		RETURN null;
	END IF;
	
	-- get the rental period on the sales order line
	SELECT charass_value INTO _period
	FROM charass
	JOIN public.char ON charass_char_id = char_id
	WHERE charass_target_id = pcoitem_id
	AND char_name = 'RENTAL PERIOD'
	AND charass_target_type = 'SI';

	IF (FOUND) THEN 
	-- check for override
	    SELECT override_date INTO _override_date from salesline_return_date_override where comment_coitem_id = pcoitem_id;
		IF (FOUND) THEN
			_scheddate = _override_date;
		ELSE
	-- calculate the return date
			IF _period = 'QTR' OR _period = '9 weeks' THEN _rentalDays = 9 * 7;
			ELSIF _period = 'TRI' OR _period = '12 weeks' THEN _rentalDays = 12 * 7;
			ELSIF _period = 'SEM' OR _period = '18 weeks' THEN _rentalDays = 18 * 7;
			ELSIF _period = 'YEAR' OR _period = '40 weeks' THEN _rentalDays = 40 * 7;
			END IF;
			_scheddate = pScheddate + _rentalDays;
		END IF;
		RETURN _scheddate;
	ELSE
		RETURN NULL;
	END IF;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getreturndate(integer, date) OWNER TO mfgadmin;

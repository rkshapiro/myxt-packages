-- Function: _report.pd_statement_balance(integer, date)

-- DROP FUNCTION _report.pd_statement_balance(integer, date);

CREATE OR REPLACE FUNCTION _report.pd_statement_balance(
    integer,
    date)
  RETURNS SETOF _report.prepay_pd_statement_type AS
$BODY$

DECLARE _cust ALIAS FOR $1;
DECLARE _dateEnd ALIAS FOR $2;
DECLARE _dateStart DATE;

BEGIN   


SELECT yearperiod_end  into _dateEnd
FROM public.yearperiod
WHERE current_date BETWEEN yearperiod_start AND yearperiod_end;

SELECT yearperiod_start  into _dateStart
FROM public.yearperiod
WHERE current_date BETWEEN yearperiod_start AND yearperiod_end;


RETURN QUERY 

SELECT * FROM _report.prepay_revenue_detail
WHERE cust_id = _cust AND doc_date >= _dateStart AND doc_date <= _dateEnd
   


GROUP BY 
    doc_id,
    doc_number,
    cust_id,
    cust_number,
    cust_name,
    doc_date,
    registered,
    doc_type,
    amount,
    ord,
    description,
    prj_id,
    prj_number	
ORDER BY doc_date;

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION _report.pd_statement_balance(integer, date)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION _report.pd_statement_balance(integer, date) TO public;
GRANT EXECUTE ON FUNCTION _report.pd_statement_balance(integer, date) TO admin;
GRANT EXECUTE ON FUNCTION _report.pd_statement_balance(integer, date) TO xtrole;

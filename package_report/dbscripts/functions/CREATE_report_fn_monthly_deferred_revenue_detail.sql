-- Function: _report.monthly_deferred_revenue_detail(date, date)

-- DROP FUNCTION _report.monthly_deferred_revenue_detail(date, date);

CREATE OR REPLACE FUNCTION _report.monthly_deferred_revenue_detail(
    _bopd date,
    _eopd date)
  RETURNS SETOF _report.deferred_revenue_detail_type AS
$BODY$

DECLARE _bopd ALIAS FOR $1;
DECLARE _eopd ALIAS FOR $2;   
DECLARE _bofy DATE; 


BEGIN

SELECT yearperiod_start  into _bofy
FROM public.yearperiod
WHERE _bopd BETWEEN yearperiod_start AND yearperiod_end;

RETURN QUERY 



SELECT detail.*
FROM

(SELECT '1 StartCash' AS Source, prepay_revenue_detail.*  
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND 
doc_date < _bopd AND
registered = 0  

 UNION



SELECT '2 PriorPD' ,prepay_revenue_detail.*  
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND 
doc_date < _bopd AND 
registered NOT IN (0) 
 
UNION



SELECT '3 PeriodCash',prepay_revenue_detail.*  
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bopd AND  doc_date <= _eopd AND
registered = 0 
  UNION



SELECT '4 PeriodPD',prepay_revenue_detail.*  
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bopd AND  doc_date <= _eopd AND
registered NOT IN (0) 
  UNION

-- TO DO :
-- Add period credits, period discounts if any



SELECT '5 EndCash', prepay_revenue_detail.*  
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND  doc_date <= _eopd AND  
registered = 0 
 UNION




SELECT '6 EndPD',prepay_revenue_detail.*  
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND  doc_date <= _eopd AND  
registered NOT IN (0) 


) detail


ORDER BY cust_number,source;




 
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION _report.monthly_deferred_revenue_detail(date, date)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION _report.monthly_deferred_revenue_detail(date, date) TO admin;
GRANT EXECUTE ON FUNCTION _report.monthly_deferred_revenue_detail(date, date) TO public;
GRANT EXECUTE ON FUNCTION _report.monthly_deferred_revenue_detail(date, date) TO xtrole;

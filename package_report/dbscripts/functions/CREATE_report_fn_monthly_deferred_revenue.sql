-- Function: _report.monthly_deferred_revenue(date, date)

-- DROP FUNCTION _report.monthly_deferred_revenue(date, date);

CREATE OR REPLACE FUNCTION _report.monthly_deferred_revenue(
    _bopd date,
    _eopd date)
  RETURNS SETOF _report.deferred_revenue_summary_type AS
$BODY$

DECLARE _bopd ALIAS FOR $1;
DECLARE _eopd ALIAS FOR $2;   
DECLARE _bofy DATE; 


BEGIN

SELECT yearperiod_start  into _bofy
FROM public.yearperiod
WHERE _bopd BETWEEN yearperiod_start AND yearperiod_end;

RETURN QUERY 



SELECT DISTINCT prepay_revenue_detail.cust_id, 
prepay_revenue_detail.cust_number,
prepay_revenue_detail.cust_name,
COALESCE(StartCash.TotalAmount,0) + COALESCE(PriorPD.TotalAmount,0) AS StartBalance,
COALESCE(PeriodCashMEMPPD.TotalAmount, 0) AS PeriodCashMEMPPD,
COALESCE(PeriodCashPPD.TotalAmount, 0) AS PeriodCashPPD,
COALESCE(PeriodPD.TotalAmount, 0) AS PeriodRegistrations,
COALESCE(EndCash.TotalAmount,0) + COALESCE(EndPD.TotalAmount,0) AS EndBalance
FROM
_report.prepay_revenue_detail LEFT OUTER JOIN 

(SELECT cust_id,SUM(COALESCE(amount, 0))AS TotalAmount
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND 
doc_date < _bopd AND
registered = 0  
GROUP BY cust_id) AS StartCash ON _report.prepay_revenue_detail.cust_id = StartCash.cust_id LEFT OUTER JOIN



(SELECT cust_id,SUM(COALESCE(amount, 0)) AS TotalAmount
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND 
doc_date < _bopd AND 
registered NOT IN (0) 
AND (prj_id =26 OR prj_id IS NULL) 
GROUP BY cust_id) AS PriorPD ON prepay_revenue_detail.cust_id = PriorPD.cust_id LEFT OUTER JOIN



(SELECT cust_id,SUM(COALESCE(amount, 0)) AS TotalAmount
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bopd AND  doc_date <= _eopd AND item_number = 'MEM-PPD' AND
registered = 0 
GROUP BY cust_id,cust_number) AS PeriodCashMEMPPD ON  prepay_revenue_detail.cust_id = PeriodCashMEMPPD.cust_id  LEFT OUTER JOIN

(SELECT cust_id,SUM(COALESCE(amount, 0)) AS TotalAmount
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bopd AND  doc_date <= _eopd AND item_number = 'PPD' AND
registered = 0 
GROUP BY cust_id,cust_number) AS PeriodCashPPD ON  prepay_revenue_detail.cust_id = PeriodCashPPD.cust_id  LEFT OUTER JOIN



(SELECT cust_id,SUM(COALESCE(amount, 0))AS TotalAmount
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bopd AND  doc_date <= _eopd AND
registered NOT IN (0) 
AND (prj_id =26 OR prj_id IS NULL)
GROUP BY cust_id,cust_number) AS PeriodPD ON prepay_revenue_detail.cust_id = PeriodPD.cust_id LEFT OUTER JOIN

-- TO DO :
-- Add period credits, period discounts if any



(SELECT cust_id,SUM(COALESCE(amount, 0)) AS TotalAmount
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND  doc_date <= _eopd AND  
registered = 0 
GROUP BY cust_id,cust_number) AS EndCash ON prepay_revenue_detail.cust_id = EndCash.cust_id LEFT OUTER JOIN




(SELECT cust_id,SUM(COALESCE(amount, 0)) AS TotalAmount
FROM _report.prepay_revenue_detail
WHERE doc_date >= _bofy AND  doc_date <= _eopd AND  
registered NOT IN (0) 
AND (prj_id =26 OR prj_id IS NULL)
GROUP BY cust_id,cust_number) AS EndPD ON prepay_revenue_detail.cust_id = EndPD.cust_id

ORDER BY 2;

 




END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION _report.monthly_deferred_revenue(date, date)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION _report.monthly_deferred_revenue(date, date) TO admin;
GRANT EXECUTE ON FUNCTION _report.monthly_deferred_revenue(date, date) TO public;
GRANT EXECUTE ON FUNCTION _report.monthly_deferred_revenue(date, date) TO xtrole;

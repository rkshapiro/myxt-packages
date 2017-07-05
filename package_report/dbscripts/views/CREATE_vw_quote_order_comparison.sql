-- View: _report.quote_order_comparison

-- DROP VIEW _report.quote_order_comparison;

CREATE OR REPLACE VIEW _report.quote_order_comparison AS 

SELECT  un.source, 
	un.crmacct_number as cust_number,
	un.crmacct_name as cust_name,
	SUM(un.extprice) as amount,
	un.planned_schoolyear
FROM 
(
SELECT 
  'Q' as source,
  quote_revenue.crmacct_number, 
  quote_revenue.crmacct_name, 
  quote_revenue.extprice, 
  quote_revenue.planned_schoolyear
FROM 
  _report.quote_revenue
  
UNION ALL

SELECT 
  sales_revenue.source, 
  sales_revenue.cust_number, 
  sales_revenue.cust_name, 
  sales_revenue.extprice,  
  sales_revenue.delivery_schoolyear
FROM 
  _report.sales_revenue
  WHERE prj_number != 'SCHOLARSHIP'
) un
GROUP BY 
	un.source, 
	un.crmacct_number,
	un.crmacct_name,
	un.planned_schoolyear
         
ORDER BY 1 DESC;

ALTER TABLE _report.quote_order_comparison OWNER TO "admin";
GRANT ALL ON TABLE _report.quote_order_comparison TO "admin";
GRANT ALL ON TABLE _report.quote_order_comparison TO xtrole;
GRANT SELECT, REFERENCES ON TABLE _report.quote_order_comparison TO public;
COMMENT ON VIEW _report.quote_order_comparison IS 'Used by Quote Order Comparison Report';


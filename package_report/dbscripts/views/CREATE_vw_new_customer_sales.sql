-- View: _report.new_customer_sales

-- DROP VIEW _report.new_customer_sales;

CREATE OR REPLACE VIEW _report.new_customer_sales AS
 
 SELECT 
	customer_start.cust_id, 
	customer_start.cust_active,
	customer_start.cust_custtype_id, 
	customer_start.custtype_code, 
	customer_start.cust_number, 
	customer_start.cust_name, 
	customer_start.fiscalyear AS startfiscalyear, 
	customer_start.fiscalquarter AS startfiscalquarter, 
	customer_start.fiscalmonth AS startfiscalmonth, 
	sales_revenue.productcode, 
	sales_revenue.extprice as amount, 
	_report.getfiscalyear(sales_revenue.orderdate) AS salesfiscalyear, 
	_report.getfiscalquarter(sales_revenue.orderdate) AS salesfiscalquarter, 
	_report.getfiscalmonth(sales_revenue.orderdate) AS salesfiscalmonth
   
FROM _report.sales_revenue
        
RIGHT JOIN _report.customer_start ON sales_revenue.cust_id = customer_start.cust_id
ORDER BY customer_start.cust_id DESC;

ALTER TABLE _report.new_customer_sales OWNER TO admin;
GRANT ALL ON TABLE _report.new_customer_sales TO xtrole;
GRANT SELECT, REFERENCES ON TABLE _report.new_customer_sales TO public;
COMMENT ON VIEW _report.new_customer_sales IS '20141013:rek Orbit 640';

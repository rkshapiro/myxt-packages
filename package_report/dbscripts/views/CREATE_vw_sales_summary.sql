-- View: _report.sales_summary

-- DROP VIEW _report.sales_summary;

CREATE OR REPLACE VIEW _report.sales_summary AS 
 SELECT 'K'::text || btrim(sales_revenue.cust_number, '9999999999'::text) AS key, sales_revenue.cust_name, sales_revenue.cust_number, sales_revenue.productcode, sales_revenue.delivery_schoolyear, sum(sales_revenue.extprice) AS tot_extprice, sales_revenue.ordernumber
   FROM _report.sales_revenue
  GROUP BY sales_revenue.cust_name, sales_revenue.cust_number, sales_revenue.productcode, sales_revenue.delivery_schoolyear, sales_revenue.ordernumber;

ALTER TABLE _report.sales_summary OWNER TO "admin";
GRANT ALL ON TABLE _report.sales_summary TO "admin";
GRANT ALL ON TABLE _report.sales_summary TO xtrole;
COMMENT ON VIEW _report.sales_summary IS 'used by membership renewal update report';


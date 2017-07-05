-- View: _report.sales_trend

-- DROP VIEW _report.sales_trend;

CREATE OR REPLACE VIEW _report.sales_trend AS 
 SELECT saleshistory.cust_id, 
 saleshistory.cust_name, 
 saleshistory.cust_number, 
 cohead.cohead_number, 
 sum(saleshistory.cohist_qtyshipped) AS qtyord, 
 sum(saleshistory.extprice) AS extprice, 
 costcat.costcat_code, 
 saleshistory.item_number, 
 saleshistory.item_descrip1, 
 COALESCE(prj.prj_number, 'blank'::text) AS prj_number, 
 saleshistory.item_id, 
 cohead.cohead_shipvia AS shipvia,
 _report.getschoolyear(cohist_shipdate) as school_year,
cohist_shipdate as ship_date,
CASE
WHEN _return.isfinalsale(getcoheadid(cohead_number)) THEN 'SALE'
ELSE 'LEASE'
END AS sale_type,
cohist_orderdate AS order_date
   FROM saleshistory
   JOIN custinfo ON saleshistory.cust_id = custinfo.cust_id
   JOIN cohead ON cohead.cohead_number = saleshistory.cohist_ordernumber
   JOIN itemsite ON saleshistory.cohist_itemsite_id = itemsite.itemsite_id
   JOIN costcat ON itemsite.itemsite_costcat_id = costcat.costcat_id
   LEFT JOIN prj ON cohead.cohead_prj_id = prj.prj_id
  WHERE saleshistory.extprice > 0::numeric AND (prj.prj_number = 'ASSET'::text OR prj.prj_number = 'MSC'::text OR prj.prj_number IS NULL)
  GROUP BY saleshistory.cust_id, saleshistory.cust_name, saleshistory.cust_number, cohead.cohead_number, costcat.costcat_code, saleshistory.item_number, saleshistory.item_descrip1, prj.prj_number, saleshistory.item_id, cohead.cohead_shipvia,cohist_shipdate,cohist_orderdate;

ALTER TABLE _report.sales_trend OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.sales_trend TO mfgadmin;
GRANT ALL ON TABLE _report.sales_trend TO xtrole;
COMMENT ON VIEW _report.sales_trend IS 'used by sales_trend report';


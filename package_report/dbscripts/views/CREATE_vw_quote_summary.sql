-- View: _report.quote_summary

-- DROP VIEW _report.quote_summary;

CREATE OR REPLACE VIEW _report.quote_summary AS 
 SELECT 'K'::text || btrim(quote_revenue.crmacct_number, '9999999999'::text) AS key, quote_revenue.crmacct_name, quote_revenue.crmacct_number, quote_revenue.productcode, quote_revenue.planned_schoolyear, sum(quote_revenue.extprice) AS tot_extprice, quote_revenue.opstage_name, quote_revenue.quhead_number, quote_revenue.optype_name
   FROM _report.quote_revenue
  GROUP BY quote_revenue.planned_schoolyear, quote_revenue.crmacct_name, quote_revenue.crmacct_number, quote_revenue.productcode, quote_revenue.optype_name, quote_revenue.opstage_name, quote_revenue.quhead_number;

ALTER TABLE _report.quote_summary OWNER TO "admin";
GRANT ALL ON TABLE _report.quote_summary TO "admin";
GRANT ALL ON TABLE _report.quote_summary TO xtrole;
COMMENT ON VIEW _report.quote_summary IS 'used by membership renewal update report';


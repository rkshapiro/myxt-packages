-- View: _report.quote_revenue

-- DROP VIEW _report.quote_revenue;
--20150114:rek change where statement to convert nulls in crmacct_cust_id to zero so that prospects can be returned.

CREATE OR REPLACE VIEW _report.quote_revenue AS 
 SELECT crmacct.crmacct_name, 
 crmacct.crmacct_number, 
	CASE
		WHEN crmacct.crmacct_cust_id > 0 THEN 'Customer'::text
		WHEN crmacct.crmacct_prospect_id > 0 THEN 'Prospect'::text
		ELSE 'Other'::text
	END AS account_type, 
	optype.optype_name, 
	opstage.opstage_name, 
	quhead.quhead_number, 
	item.item_number, 
	item.item_descrip1, 
	costcat.costcat_code, 
	_report.getschoolyear(min(quitem.quitem_scheddate)) AS planned_schoolyear, 
	sum(quitem.quitem_qtyord) AS qtyord, 
	sum(quitem.quitem_qtyord * quitem.quitem_price) AS extprice, 
	to_char(min(quitem.quitem_scheddate)::timestamp with time zone, 'Mon'::text) AS deliverymonth, 
	CASE
		WHEN _return.isfinalsalequote(quhead.quhead_id) = true THEN 'MOD SALE'::text
		ELSE prodcat.prodcat_code
	END AS productcode, 
	CASE
		WHEN date_part('MONTH'::text, min(quitem.quitem_scheddate)) >= 7::double precision 
		AND date_part('MONTH'::text, min(quitem.quitem_scheddate)) <= 12::double precision 
		THEN date_part('MONTH'::text, min(quitem.quitem_scheddate)) - 6::double precision
		ELSE date_part('MONTH'::text, min(quitem.quitem_scheddate)) + 6::double precision
	END AS month_order, 
	crmacct.crmacct_id,
	crmacct.crmacct_owner_username,
	formatperiodname(getperiodid(min(quitem.quitem_scheddate)),'Q') AS quarter,
	COALESCE(prj_number,'blank'::text) as prj_number,
	ophead_owner_username,
	ophead.ophead_name
   FROM quhead
   JOIN quitem ON quitem.quitem_quhead_id = quhead.quhead_id
   JOIN itemsite ON quitem.quitem_itemsite_id = itemsite.itemsite_id
   JOIN item ON itemsite.itemsite_item_id = item.item_id
   JOIN ophead ON quhead.quhead_ophead_id = ophead.ophead_id
   JOIN crmacct ON ophead.ophead_crmacct_id = crmacct.crmacct_id
   JOIN optype ON ophead.ophead_optype_id = optype.optype_id
   JOIN opstage ON ophead.ophead_opstage_id = opstage.opstage_id
   JOIN costcat ON itemsite.itemsite_costcat_id = costcat.costcat_id
   JOIN prodcat ON item.item_prodcat_id = prodcat.prodcat_id
   LEFT JOIN prj ON quhead.quhead_prj_id = prj.prj_id
  WHERE quitem.quitem_scheddate > '2012-06-30'::date 
  AND ((quhead.quhead_expire > 'now'::text::date OR quhead.quhead_expire IS NULL) 
  AND (opstage.opstage_name = ANY (ARRAY['1 ASSESSMENT'::text, '2 QUOTE'::text, '3 COMMIT'::text, '3 FINAL'::text])) 
  OR opstage.opstage_name = '4 COMPLETED'::text) 
  AND NOT (opstage.opstage_name = ANY (ARRAY['4 CANCELED'::text, '4 COLD'::text])) 
  AND NOT (COALESCE(crmacct.crmacct_cust_id,0) = ANY (ARRAY[1476, 6562, 6574, 6959, 9154, 9150, 9152, 9154])) -- 20150114:rek
  GROUP BY crmacct.crmacct_number, crmacct.crmacct_cust_id, crmacct.crmacct_prospect_id, crmacct.crmacct_name, optype.optype_name, quhead.quhead_number, costcat.costcat_code, item.item_number, opstage.opstage_name, item.item_descrip1, quhead.quhead_id, prodcat.prodcat_code, crmacct.crmacct_id, crmacct.crmacct_owner_username,prj_number,ophead_owner_username,ophead_name;

ALTER TABLE _report.quote_revenue OWNER TO "admin";
GRANT ALL ON TABLE _report.quote_revenue TO "admin";
GRANT ALL ON TABLE _report.quote_revenue TO xtrole;
GRANT SELECT, REFERENCES ON TABLE _report.quote_revenue TO public;
COMMENT ON VIEW _report.quote_revenue IS 'used by executive dashboard and planned sales analysis';


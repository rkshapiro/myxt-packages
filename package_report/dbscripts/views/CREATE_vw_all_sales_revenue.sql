-- View: _report.all_sales_revenue

-- DROP VIEW _report.all_sales_revenue;

CREATE OR REPLACE VIEW _report.all_sales_revenue AS 
 SELECT 'S'::text AS source,
    custinfo.cust_id,
    custinfo.cust_name,
    custinfo.cust_number,
    cohead.cohead_number AS ordernumber,
    sum(coitem.coitem_qtyord) AS qtyord,
    sum(round(coitem.coitem_qtyord * coitem.coitem_price, 2)) AS extprice,
    COALESCE(prj.prj_number, 'blank'::text) AS prj_number,
        CASE
            WHEN _asset.isfinalsale(cohead.cohead_id) = true THEN 'MOD SALE'::text
            ELSE prodcat.prodcat_code
        END AS productcode,
    cohead.cohead_orderdate AS orderdate,
    to_char(cohead.cohead_orderdate::timestamp with time zone, 'Mon'::text) AS ordermonth,
    custtype.custtype_code,
        CASE
            WHEN coitem.coitem_promdate = '2100-01-01'::date THEN min(coitem.coitem_scheddate)
            ELSE min(COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate))
        END AS deliverydate,
        CASE
            WHEN coitem.coitem_promdate = '2100-01-01'::date THEN to_char(min(coitem.coitem_scheddate)::timestamp with time zone, 'Mon'::text)
            ELSE to_char(min(COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate))::timestamp with time zone, 'Mon'::text)
        END AS deliverymonth,
        CASE
            WHEN coitem.coitem_promdate = '2100-01-01'::date THEN _report.getschoolyear(min(coitem.coitem_scheddate))
            ELSE _report.getschoolyear(min(COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate)))
        END AS delivery_schoolyear,
        CASE
            WHEN coitem.coitem_promdate = '2100-01-01'::date THEN formatperiodname(getperiodid(min(coitem.coitem_scheddate)), 'Q'::bpchar)
            ELSE formatperiodname(getperiodid(min(COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate))), 'Q'::bpchar)
        END AS deliveryqtr,
    max(coitem.coitem_status) AS status,
        CASE
            WHEN date_part('MONTH'::text, min(coitem.coitem_scheddate)) >= 7::double precision AND date_part('MONTH'::text, min(coitem.coitem_scheddate)) <= 12::double precision THEN date_part('MONTH'::text, min(coitem.coitem_scheddate)) - 6::double precision
            ELSE date_part('MONTH'::text, min(coitem.coitem_scheddate)) + 6::double precision
        END AS month_order,
    item.item_number,
    item.item_descrip1,
    crm.crmacct_owner_username
   FROM cohead
     JOIN custinfo ON cohead.cohead_cust_id = custinfo.cust_id
     JOIN crmacct crm ON crm.crmacct_number = custinfo.cust_number
     JOIN custtype ON custinfo.cust_custtype_id = custtype.custtype_id
     JOIN coitem ON cohead.cohead_id = coitem.coitem_cohead_id
     JOIN itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
     JOIN item ON itemsite.itemsite_item_id = item.item_id
     JOIN prodcat ON item.item_prodcat_id = prodcat.prodcat_id
     LEFT JOIN prj ON cohead.cohead_prj_id = prj.prj_id
  WHERE
        CASE
            WHEN coitem.coitem_custprice > 0::numeric THEN coitem.coitem_custprice
            ELSE coitem.coitem_price
        END > 0::numeric AND coitem.coitem_status <> 'X'::bpchar AND NOT (custinfo.cust_id = ANY (ARRAY[1476, 6562, 6574, 6959, 9154, 9150, 9152, 9154])) AND NOT upper(cohead.cohead_custponumber) ~ 'INVALID'::text AND NOT (cohead.cohead_id IN ( SELECT docass.docass_target_id
           FROM docass
          WHERE docass.docass_source_type = 'INCDT'::text AND docass.docass_target_type = 'S'::text))
  GROUP BY custinfo.cust_id, custinfo.cust_name, custinfo.cust_number, cohead.cohead_number, prj.prj_number, prodcat.prodcat_code, custtype.custtype_code, cohead.cohead_orderdate, cohead.cohead_id, coitem.coitem_promdate, item.item_number, item.item_descrip1, crm.crmacct_owner_username, coitem.coitem_custprice
UNION
 SELECT 'I'::text AS source,
    custinfo.cust_id,
    custinfo.cust_name,
    custinfo.cust_number,
    invchead.invchead_invcnumber AS ordernumber,
    sum(invcitem.invcitem_billed) AS qtyord,
    sum(invcitem.invcitem_price * invcitem.invcitem_billed) AS extprice,
    COALESCE(prj.prj_number, 'blank'::text) AS prj_number,
    COALESCE(salescat.salescat_name, prodcat.prodcat_code) AS productcode,
    invchead.invchead_invcdate AS orderdate,
    to_char(invchead.invchead_invcdate::timestamp with time zone, 'Mon'::text) AS ordermonth,
    custtype.custtype_code,
    invchead.invchead_invcdate AS deliverydate,
    to_char(invchead.invchead_invcdate::timestamp with time zone, 'Mon'::text) AS deliverymonth,
    _report.getschoolyear(invchead.invchead_invcdate) AS delivery_schoolyear,
    formatperiodname(getperiodid(invchead.invchead_invcdate), 'Q'::bpchar) AS deliveryqtr,
        CASE
            WHEN invchead.invchead_posted THEN 'C'::text
            ELSE 'O'::text
        END AS status,
        CASE
            WHEN date_part('MONTH'::text, invchead.invchead_invcdate) >= 7::double precision AND date_part('MONTH'::text, invchead.invchead_invcdate) <= 12::double precision THEN date_part('MONTH'::text, invchead.invchead_invcdate) - 6::double precision
            ELSE date_part('MONTH'::text, invchead.invchead_invcdate) + 6::double precision
        END AS month_order,
    COALESCE(item.item_number, ' '::text) AS item_number,
    COALESCE(item.item_descrip1, ' '::text) AS item_descrip1,
    crm.crmacct_owner_username
   FROM invchead
     JOIN invcitem ON invchead.invchead_id = invcitem.invcitem_invchead_id
     JOIN custinfo ON custinfo.cust_id = invchead.invchead_cust_id
     JOIN crmacct crm ON crm.crmacct_number = custinfo.cust_number
     JOIN custtype ON custinfo.cust_custtype_id = custtype.custtype_id
     LEFT JOIN prj ON prj.prj_id = invchead.invchead_prj_id
     LEFT JOIN item ON invcitem.invcitem_item_id = item.item_id
     LEFT JOIN salescat ON invcitem.invcitem_salescat_id = salescat.salescat_id
     LEFT JOIN prodcat ON item.item_prodcat_id = prodcat.prodcat_id
  WHERE invcitem.invcitem_price > 0::numeric AND NOT (custinfo.cust_id = ANY (ARRAY[1476, 6562, 6574, 6959, 9154, 9150, 9152, 9154])) AND NOT upper(invchead.invchead_ponumber) ~ 'INVALID'::text AND invcitem.invcitem_coitem_id IS NULL AND NOT invchead.invchead_void
  GROUP BY custinfo.cust_id, custinfo.cust_name, custinfo.cust_number, invchead.invchead_invcnumber, prj.prj_number, invchead.invchead_invcdate, custtype.custtype_code, salescat.salescat_name, prodcat.prodcat_code, invchead.invchead_posted, item.item_number, item.item_descrip1, crm.crmacct_owner_username;

ALTER TABLE _report.all_sales_revenue
  OWNER TO admin;
GRANT ALL ON TABLE _report.all_sales_revenue TO admin;
GRANT ALL ON TABLE _report.all_sales_revenue TO xtrole;
GRANT SELECT, REFERENCES ON TABLE _report.all_sales_revenue TO public;
COMMENT ON VIEW _report.all_sales_revenue
  IS 'used by custom report';

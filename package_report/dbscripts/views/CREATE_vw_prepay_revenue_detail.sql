-- View: _report.prepay_revenue_detail

-- DROP VIEW _report.prepay_revenue_detail;

CREATE OR REPLACE VIEW _report.prepay_revenue_detail AS 
 SELECT detail.doc_id,
    detail.doc_number,
    detail.cust_id,
    detail.cust_number,
    detail.cust_name,
    detail.doc_date,
    detail.registered,
    detail.doc_type,
    detail.amount,
    detail.ord,
    detail.description,
    detail.prj_id,
    detail.prj_number,
    detail.item_number
   FROM ( SELECT invchead.invchead_id AS doc_id,
            invchead.invchead_invcnumber AS doc_number,
            invchead.invchead_cust_id AS cust_id,
            custinfo.cust_number,
            custinfo.cust_name,
            invchead.invchead_invcdate AS doc_date,
            0 AS registered,
            'Invoice'::text AS doc_type,
            invcitem.invcitem_price AS amount,
            1 AS ord,
            item.item_number,
            'Prepayment Invoice'::text AS description,
            invchead.invchead_prj_id AS prj_id,
            prj.prj_number
           FROM invcitem
             JOIN item ON invcitem.invcitem_item_id = item.item_id
             JOIN invchead ON invchead.invchead_id = invcitem.invcitem_invchead_id
             JOIN custinfo ON invchead.invchead_cust_id = custinfo.cust_id
             LEFT JOIN prj ON prj.prj_id = invchead.invchead_prj_id
          WHERE (item.item_number = ANY (ARRAY['PPD'::text, 'MEM-PPD'::text])) AND NOT (invchead.invchead_cust_id = ANY (ARRAY[1476, 6562, 6574, 6959, 9154, 9150, 9152, 9154])) AND NOT upper(invchead.invchead_ponumber) ~ 'INVALID'::text AND invchead.invchead_invcdate > '2012-06-30'::date
          GROUP BY invchead.invchead_id, invchead.invchead_cust_id, custinfo.cust_name, custinfo.cust_number, invchead.invchead_invcdate, invcitem.invcitem_price, prj.prj_number, item.item_number
        UNION
         SELECT cohead.cohead_id AS doc_id,
            cohead.cohead_number AS doc_number,
            custinfo.cust_id,
            custinfo.cust_number,
            custinfo.cust_name,
            sess.start_date AS doc_date,
            reg.registered::integer AS registered,
            'Sales Order'::text AS doc_type,
            open_pd_items.coitem_price * reg.registered::numeric * (- 1::numeric) AS amount,
            2 AS ord,
            open_pd_items.item_number,
            open_pd_items.item_descrip1 AS description,
            cohead.cohead_prj_id,
            open_pd_items.prj_number
           FROM _report.open_pd_items
             JOIN cohead ON cohead.cohead_id = open_pd_items.cohead_id
             JOIN custinfo ON custinfo.cust_id = open_pd_items.cohead_cust_id
             JOIN ( SELECT reg_1.reg_schevnt_id,
                    reg_1.reg_coitem_id,
                    count(*) AS registered
                   FROM regmgmt.reg reg_1
                  WHERE reg_1.reg_status <> 'X'::text
                  GROUP BY reg_1.reg_schevnt_id, reg_1.reg_coitem_id) reg ON reg.reg_coitem_id = open_pd_items.coitem_id
             JOIN regmgmt.schevnt ON schevnt.schevnt_id = reg.reg_schevnt_id
             JOIN ( SELECT schevntsess.schevntsess_schevnt_id,
                    min(schevntsess.schevntsess_start_datetime)::date AS start_date
                   FROM regmgmt.schevntsess
                  GROUP BY schevntsess.schevntsess_schevnt_id) sess ON sess.schevntsess_schevnt_id = schevnt.schevnt_id
          WHERE cohead.cohead_prj_id = ANY (ARRAY[26])) detail
  ORDER BY detail.cust_id, detail.doc_date;

ALTER TABLE _report.prepay_revenue_detail
  OWNER TO admin;
GRANT ALL ON TABLE _report.prepay_revenue_detail TO admin;
GRANT ALL ON TABLE _report.prepay_revenue_detail TO xtrole;

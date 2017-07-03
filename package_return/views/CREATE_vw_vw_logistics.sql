-- View: vw_logistics

-- DROP VIEW vw_logistics;

CREATE OR REPLACE VIEW vw_logistics AS 
         SELECT coitem.coitem_scheddate AS _date, 'Deliver' AS _in_out, encode(digest((((cohead.cohead_shiptozipcode || cohead.cohead_shiptocity) || cohead.cohead_shiptoaddress3) || cohead.cohead_shiptoaddress2) || cohead.cohead_shiptoaddress1, 'md5'::text), 'hex'::text) AS addr_sort, cohead.cohead_number AS _order_ra, custinfo.cust_name, custinfo.cust_number, cohead.cohead_shiptoname AS _name, cohead.cohead_shiptoaddress1 AS _addr1, cohead.cohead_shiptoaddress2 AS _addr2, cohead.cohead_shiptoaddress3 AS _addr3, cohead.cohead_shiptocity AS city, cohead.cohead_shiptostate AS state, cohead.cohead_shiptozipcode AS zip, cohead.cohead_shipvia AS _shipvia, coitem.coitem_qtyord AS _boxes, item.item_number, cohead.cohead_holdtype, cohead.cohead_cust_id AS cust_id, formatsolinenumber(coitem.coitem_id) AS line_number, 
	 CASE
         WHEN ( (SELECT COUNT(*)
                   FROM coitem
                  WHERE ((coitem_status<>'X') AND (coitem_cohead_id=cohead_id))) = 0) THEN 'No lines'
         WHEN ( ( (SELECT COUNT(*)
                     FROM coitem
                    WHERE ((coitem_status='C')
                      AND (coitem_cohead_id=cohead_id))) > 0)
                      AND ( (SELECT COUNT(*)
                               FROM coitem
                              WHERE ((coitem_status NOT IN ('C','X'))
                                AND (coitem_cohead_id=cohead_id))) = 0) ) THEN 'Closed'
         WHEN ( ( (SELECT COUNT(*)
                     FROM coitem
                    WHERE ((coitem_status='C')
                      AND (coitem_cohead_id=cohead_id))) = 0)
                      AND ( (SELECT COUNT(*)
                               FROM coitem
                              WHERE ((coitem_status NOT IN ('C','X'))
                                AND (coitem_cohead_id=cohead_id))) > 0) ) THEN 'Open'
         ELSE 'Partial'
       END AS order_status
           FROM cohead
      JOIN coitem ON coitem.coitem_cohead_id = cohead.cohead_id
   JOIN itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
   JOIN item ON itemsite.itemsite_item_id = item.item_id
   JOIN crmacct ON cohead.cohead_cust_id = crmacct.crmacct_cust_id
   JOIN custinfo ON cohead.cohead_cust_id = custinfo.cust_id
   JOIN classcode ON item.item_classcode_id = classcode.classcode_id
   LEFT JOIN docass ON cohead.cohead_id = docass.docass_source_id
  WHERE item.item_type <> 'K'::bpchar AND crmacct.crmacct_number <> 'USDED-I3'::text AND classcode.classcode_code <> 'DROPSHIP'::text AND itemsite.itemsite_warehous_id <> 51 AND (docass.docass_id IS NULL OR docass.docass_target_type <> 'INCDT'::text) AND (coitem.coitem_status = 'O'::bpchar OR coitem.coitem_status = 'C'::bpchar)
UNION 
         SELECT coitem_raitem.return_date AS _date, 'Return' AS _in_out, encode(digest((((coitem_raitem.rahead_shipto_zipcode || coitem_raitem.rahead_shipto_city) || coitem_raitem.rahead_shipto_address3) || coitem_raitem.rahead_shipto_address2) || coitem_raitem.rahead_shipto_address1, 'md5'::text), 'hex'::text) AS addr_sort, rh.rahead_number AS _order_ra, custinfo.cust_name, custinfo.cust_number, coitem_raitem.rahead_shipto_name AS _name, coitem_raitem.rahead_shipto_address1 AS _addr1, coitem_raitem.rahead_shipto_address2 AS _addr2, rh.rahead_shipto_address3 AS _addr3, coitem_raitem.rahead_shipto_city AS city, coitem_raitem.rahead_shipto_state AS state, coitem_raitem.rahead_shipto_zipcode AS zip, cohead.cohead_shipvia AS _shipvia, coitem_raitem.qtydue AS _boxes, item.item_number, cohead.cohead_holdtype, cohead.cohead_cust_id AS cust_id, (coitem_raitem.coitem_linenumber || '.'::text) || coitem_raitem.coitem_subnumber AS line_number,
	 CASE
         WHEN ( (SELECT COUNT(*)
                   FROM coitem
                  WHERE ((coitem_status<>'X') AND (coitem_cohead_id=cohead_id))) = 0) THEN 'No lines'
         WHEN ( ( (SELECT COUNT(*)
                     FROM coitem
                    WHERE ((coitem_status='C')
                      AND (coitem_cohead_id=cohead_id))) > 0)
                      AND ( (SELECT COUNT(*)
                               FROM coitem
                              WHERE ((coitem_status NOT IN ('C','X'))
                                AND (coitem_cohead_id=cohead_id))) = 0) ) THEN 'Closed'
         WHEN ( ( (SELECT COUNT(*)
                     FROM coitem
                    WHERE ((coitem_status='C')
                      AND (coitem_cohead_id=cohead_id))) = 0)
                      AND ( (SELECT COUNT(*)
                               FROM coitem
                              WHERE ((coitem_status NOT IN ('C','X'))
                                AND (coitem_cohead_id=cohead_id))) > 0) ) THEN 'Open'
         ELSE 'Partial'
       END AS order_status
           FROM _return.coitem_raitem
      JOIN cohead ON coitem_raitem.rahead_number = cohead.cohead_number
   JOIN coitem ON coitem_raitem.coitem_raitem_coitem_id = coitem.coitem_id
   JOIN itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
   JOIN item ON itemsite.itemsite_item_id = item.item_id
   JOIN crmacct ON cohead.cohead_cust_id = crmacct.crmacct_cust_id
   JOIN rahead rh ON rh.rahead_number = coitem_raitem.rahead_number
   JOIN custinfo ON cohead.cohead_cust_id = custinfo.cust_id
   JOIN classcode ON item.item_classcode_id = classcode.classcode_id
   LEFT JOIN docass ON cohead.cohead_id = docass.docass_source_id
  WHERE item.item_type <> 'K'::bpchar AND crmacct.crmacct_number <> 'USDED-I3'::text AND classcode.classcode_code <> 'DROPSHIP'::text AND itemsite.itemsite_warehous_id <> 51 AND (docass.docass_id IS NULL OR docass.docass_target_type <> 'INCDT'::text) AND coitem_raitem.qtydue > 0::numeric;

ALTER TABLE vw_logistics OWNER TO "admin";
GRANT ALL ON TABLE vw_logistics TO "admin";
GRANT ALL ON TABLE vw_logistics TO public;


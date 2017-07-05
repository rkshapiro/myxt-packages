-- View: _report.open_pd_items

-- DROP VIEW _report.open_pd_items;

CREATE OR REPLACE VIEW _report.open_pd_items AS 
 SELECT cohead.cohead_cust_id,
    cohead.cohead_id,
    cohead.cohead_number,
    cohead.cohead_prj_id,
    item.item_number,
    item.item_descrip1,
    coitem.coitem_id,
    coitem.coitem_qtyord,
    coitem.coitem_price,
    coitem.coitem_custprice,
    coitem.coitem_qtyord * coitem.coitem_price AS total_price,
    coitem.coitem_qtyord * (coitem.coitem_price - coitem.coitem_custprice) AS cust_discount,
    coitem.coitem_qtyshipped AS qtyshipped,
    qtyatshipping(coitem.coitem_id) AS qtyatshipping,
    prj.prj_number,
    item.item_id
   FROM cohead
     JOIN coitem ON coitem.coitem_cohead_id = cohead.cohead_id
     JOIN itemsite ON itemsite.itemsite_id = coitem.coitem_itemsite_id
     JOIN item ON item.item_id = itemsite.itemsite_item_id
     LEFT JOIN prj ON prj.prj_id = cohead.cohead_prj_id
     JOIN classcode ON classcode.classcode_id = item.item_classcode_id
  WHERE classcode.classcode_code ~ 'PROFDEV'::text AND NOT coitem.coitem_status = 'X'::bpchar AND NOT (cohead.cohead_cust_id = ANY (ARRAY[1476, 6562, 6574, 6959, 9154, 9150, 9152, 9154])) AND NOT upper(cohead.cohead_custponumber) ~ 'INVALID'::text AND NOT (cohead.cohead_number IN ( SELECT COALESCE(ccpay.ccpay_order_number, '-1'::text) AS "coalesce"
           FROM ccpay));

ALTER TABLE _report.open_pd_items
  OWNER TO admin;
GRANT ALL ON TABLE _report.open_pd_items TO admin;
GRANT ALL ON TABLE _report.open_pd_items TO xtrole;
GRANT SELECT ON TABLE _report.open_pd_items TO public;
COMMENT ON VIEW _report.open_pd_items
  IS 'rbit 869';

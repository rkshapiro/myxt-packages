
-- View: fedex_outbound

-- DROP VIEW fedex_outbound;
-- 20151203:rks changed the item description to be the item number and beginning of the description
-- 20151216:rks changed numlabels for teacher guides to be 1 label for every 10 guides

CREATE OR REPLACE VIEW fedex_outbound AS 
 
 SELECT cohead.cohead_id, coitem.coitem_id, item.item_id AS itemid, item.item_number, custinfo.cust_name AS customer, 
 cohead.cohead_shiptoname AS shipto, 
 item.item_number||'-'||substring(item.item_descrip1 FROM 1 FOR 30) AS item_description, item.item_prodweight AS weight, 
 cohead.cohead_shiptoaddress1 AS ship_address1, cohead.cohead_shiptoaddress2 AS ship_address2, cohead.cohead_shiptoaddress3 AS ship_address3, 
 cohead.cohead_number AS order_number, cohead.cohead_shiptocity AS ship_city, cohead.cohead_shiptostate AS ship_state, 
 cohead.cohead_shiptozipcode AS ship_postalcode, cohead.cohead_shipvia AS ship_via, 
 CASE
 WHEN classcode_code ~ 'TG' THEN round((shipitem_qty/10)+1)::integer
 ELSE shipitem_qty::integer 
 END AS numlabels, 
 item.item_freightclass_id AS freightclass_id, 
 shiphead.shiphead_number AS shipment_number,
 _asset.isfinalsale(cohead.cohead_id)::boolean as sale_flag,
 shipitem.shipitem_id
   FROM shipitem
   join coitem on shipitem_orderitem_id = coitem_id
   join cohead on coitem_cohead_id = cohead_id
   JOIN itemsite ON coitem_itemsite_id = itemsite.itemsite_id
   JOIN item ON itemsite.itemsite_item_id = item.item_id
   JOIN shiphead ON shipitem.shipitem_shiphead_id = shiphead.shiphead_id
   JOIN custinfo ON cohead.cohead_cust_id = custinfo.cust_id
   JOIN classcode ON classcode.classcode_id = item.item_classcode_id
  WHERE cohead.cohead_shipvia ~~ 'FEDEX%'::text 
  AND (coitem.coitem_status <> 'C'::bpchar AND coitem.coitem_status <> 'X'::bpchar)
  AND shiphead_shipdate between (current_date::text::date - 10) and (current_date::text::date + 30) 
  AND item.item_type <> 'K'::bpchar 
  AND item.item_number <> 'FREIGHT'::text 
  AND cohead.cohead_holdtype = 'N'::bpchar 
  AND classcode.classcode_code <> 'DROPSHIP'::text
  ORDER BY cohead.cohead_id, coitem.coitem_id, item.item_id;

ALTER TABLE fedex_outbound OWNER TO admin;
GRANT ALL ON TABLE fedex_outbound TO admin;
GRANT SELECT ON TABLE fedex_outbound TO public;


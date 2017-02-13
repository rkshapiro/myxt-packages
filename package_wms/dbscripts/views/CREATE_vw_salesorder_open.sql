-- View:  salesorder_open

-- DROP VIEW  salesorder_open;

-- 20131119:jjb Not showing DROPSHIP or MODULE lines.
-- 20140117:jjb Added _so_shipcomments field.
-- 20140620:jjb Filter out all reference items per Rebecca and Albie's request
-- 20140623:jjb Show only records from ASSET1 per Albie's request

CREATE OR REPLACE VIEW  salesorder_open AS 
 SELECT cohead.cohead_number::character varying(255) AS _so_number, cust.cust_number::character varying(255) AS _so_cust_number, cust.cust_name::character varying(255) AS _so_cust_name, cohead.cohead_shipvia::character varying(255) AS _so_shipvia, coitem.coitem_scheddate AS _soline_scheddate, coitem.coitem_memo::character varying(255) AS _soline_memo, coitem.coitem_linenumber AS _soline_number, coitem.coitem_subnumber AS _soline_subnumber, item.item_number::character varying(255) AS _soline_item_number, whsinfo.warehous_code::character varying(255) AS _soline_warehouse_code, coitem.coitem_qtyord AS _soline_qty_ordered, coitem.coitem_qtyshipped AS _soline_qty_shipped, coitem.coitem_qtyreturned AS _soline_qty_returned, coitem.coitem_qtyord - coitem.coitem_qtyshipped + coitem.coitem_qtyreturned AS _soline_qty_needed, cohead.cohead_shipcomments::character varying(255) AS _so_shipcomments
   FROM public.cohead
   JOIN public.cust ON cohead.cohead_cust_id = cust.cust_id
   LEFT JOIN public.coitem ON cohead.cohead_id = coitem.coitem_cohead_id
   JOIN public.itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
   JOIN public.item ON itemsite.itemsite_item_id = item.item_id 
   JOIN public.classcode ON item_classcode_id = classcode_id
   JOIN public.whsinfo ON itemsite.itemsite_warehous_id = whsinfo.warehous_id
  WHERE cohead.cohead_holdtype = 'N'::bpchar AND cohead.cohead_status = 'O'::bpchar AND coitem.coitem_status <> 'C'::bpchar AND coitem.coitem_status <> 'X'::bpchar AND item.item_type <> 'K'::bpchar AND item.item_type <> 'R'::bpchar AND (classcode_code <> 'DROPSHIP' AND classcode_code <> 'MODULE') AND whsinfo.warehous_code='ASSET1' 
  ORDER BY cohead.cohead_number::character varying(255), coitem.coitem_linenumber, coitem.coitem_subnumber;

ALTER TABLE  salesorder_open OWNER TO "admin";
GRANT ALL ON TABLE  salesorder_open TO "admin";
GRANT SELECT ON TABLE  salesorder_open TO public;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE  salesorder_open TO xtrole;
COMMENT ON VIEW  salesorder_open IS 'used by WMS for order management';


-- View:  purchaseorderline

-- DROP VIEW  purchaseorderline;

CREATE OR REPLACE VIEW  purchaseorderline AS 
 SELECT pohead.pohead_number::character varying(255) AS _po_number, pohead.pohead_status AS _po_status, poitem.poitem_linenumber AS _poline_number, poitem.poitem_vend_item_number::character varying(255) AS _vend_item_number, poitem.poitem_vend_item_descrip::character varying(255) AS _vend_item_descrip, poitem.poitem_vend_uom::character varying(255) AS _vend_uom, poitem.poitem_invvenduomratio AS _inventory_uom_ratio, whsinfo.warehous_code::character varying(255) AS _warehouse_code, item.item_number::character varying(255) AS _asset_item_number, item.item_descrip1::character varying(255) AS _asset_item_desc_1, poitem.poitem_qty_ordered AS _expected_qty, poitem.poitem_qty_received AS _qty_received_to_date, poitem.poitem_status AS _poline_status
   FROM public.poitem
   JOIN public.pohead ON poitem.poitem_pohead_id = pohead.pohead_id
   LEFT JOIN public.itemsite ON poitem.poitem_itemsite_id = itemsite.itemsite_id
   LEFT JOIN public.item ON itemsite.itemsite_item_id = item.item_id
   LEFT JOIN public.whsinfo ON itemsite.itemsite_warehous_id = whsinfo.warehous_id
  WHERE pohead.pohead_status <> 'U'::bpchar
  ORDER BY pohead.pohead_number::integer, poitem.poitem_linenumber;

ALTER TABLE  purchaseorderline OWNER TO "admin";
GRANT ALL ON TABLE  purchaseorderline TO "admin";
GRANT SELECT, UPDATE, REFERENCES, TRIGGER ON TABLE  purchaseorderline TO public;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE  purchaseorderline TO xtrole;
COMMENT ON VIEW  purchaseorderline IS 'used by WMS for purchase order receiving';


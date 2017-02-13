-- View:  coitem_raitem

-- DROP VIEW  coitem_raitem;

CREATE OR REPLACE VIEW  coitem_raitem AS 
 SELECT rahead.rahead_billtoname, 
	rahead.rahead_number, 
	item.item_number, 
	raitem.raitem_qtyauthorized, 
	raitem.raitem_qtyreceived, 
	raitem.raitem_qtyauthorized - raitem.raitem_qtyreceived AS qtydue,  
	CASE
		WHEN coitem.coitem_promdate = '2100-01-01' THEN coitem.coitem_scheddate
	ELSE
		COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate) 
	END AS delivery_date, 
	rahead.rahead_shipto_name, 
	rahead.rahead_shipto_address1, 
	rahead.rahead_shipto_address2, 
	rahead.rahead_shipto_address3, 
	rahead.rahead_shipto_city, 
	rahead.rahead_shipto_state, 
	rahead.rahead_shipto_zipcode, 
	rahead.rahead_new_cohead_id AS coitem_raitem_cohead_id, 
	raitem.raitem_orig_coitem_id AS coitem_raitem_coitem_id, 
	raitem.raitem_itemsite_id AS coitem_raitem_itemsite_id, 
	coitem.coitem_linenumber, 
	coitem.coitem_subnumber, 
	raitem.raitem_id, 
	raitem.raitem_status, 
	raitem.raitem_qty_uom_id, 
	coitem.coitem_itemsite_id, 
	raitem.raitem_itemsite_id, 
	raitem.raitem_linenumber, 
	raitem.raitem_subnumber
   FROM public.rahead
   JOIN public.raitem ON rahead.rahead_id = raitem.raitem_rahead_id
   JOIN public.coitem ON raitem.raitem_orig_coitem_id = coitem.coitem_id
   JOIN public.itemsite ON raitem.raitem_itemsite_id = itemsite.itemsite_id
   JOIN public.item ON itemsite.itemsite_item_id = item.item_id;

ALTER TABLE  coitem_raitem OWNER TO "admin";
GRANT ALL ON TABLE  coitem_raitem TO "admin";
GRANT SELECT ON TABLE  coitem_raitem TO public;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE  coitem_raitem TO xtrole;
COMMENT ON VIEW  coitem_raitem IS 'used by WMS for return processing';


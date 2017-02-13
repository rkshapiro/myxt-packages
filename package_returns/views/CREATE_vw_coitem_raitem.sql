-- View: coitem_raitem

-- DROP VIEW coitem_raitem;

CREATE OR REPLACE VIEW coitem_raitem AS 
-- 20140416:rks modified to use scheddate when promdate is 2100-01-01
 SELECT sl.return_date, rahead.rahead_billtoname, rahead.rahead_number, sl.item_number, raitem.raitem_qtyauthorized, raitem.raitem_qtyreceived, raitem.raitem_qtyauthorized - raitem.raitem_qtyreceived AS qtydue, 
 CASE
 WHEN coitem.coitem_promdate = '2100-01-01' THEN coitem.coitem_scheddate
 ELSE
 COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate) 
 END AS delivery_date, rahead.rahead_shipto_name, rahead.rahead_shipto_address1, rahead.rahead_shipto_address2, rahead.rahead_shipto_address3, rahead.rahead_shipto_city, rahead.rahead_shipto_state, rahead.rahead_shipto_zipcode, rahead.rahead_new_cohead_id AS coitem_raitem_cohead_id, raitem.raitem_orig_coitem_id AS coitem_raitem_coitem_id, raitem.raitem_itemsite_id AS coitem_raitem_itemsite_id, coitem.coitem_linenumber, coitem.coitem_subnumber
   FROM salesline_return_date sl
   JOIN rahead ON rahead.rahead_number = sl.order_number
   JOIN raitem ON rahead.rahead_id = raitem.raitem_rahead_id
   JOIN coitem ON raitem.raitem_orig_coitem_id = coitem.coitem_id
  WHERE sl.salesline_coitem_id = raitem.raitem_orig_coitem_id;

ALTER TABLE coitem_raitem OWNER TO mfgadmin;
GRANT ALL ON TABLE coitem_raitem TO mfgadmin;
GRANT ALL ON TABLE coitem_raitem TO xtrole;
COMMENT ON VIEW coitem_raitem IS 'used by reporting on leased items due to be returned';


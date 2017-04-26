-- View:  order_history
--DROP VIEW  order_history;
CREATE OR REPLACE VIEW  order_history AS 
-- 20140609:jjb Not all promdate instances were taken care of with the last revision -- this is now fixed
-- 20140416:rks modified to use scheddate when promdate is 2100-01-01
 SELECT custinfo.cust_id, custinfo.cust_name, cohead.cohead_number AS order_num, 
 CASE
 WHEN coitem.coitem_promdate = '2100-01-01' THEN coitem.coitem_scheddate
 ELSE
 COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate) 
 END AS delivery_date, item_descrip1 AS item_description, coitem.coitem_qtyord AS qty_ordered,
 CASE
 WHEN coitem.coitem_promdate = '2100-01-01' THEN   _return.getreturndate(coitem_id,coitem_scheddate) 
 ELSE
 _return.getreturndate(coitem_id,coalesce(coitem_promdate,coitem_scheddate)) 
 END AS return_date, 
null AS qty_due,  
 cohead.cohead_shiptoname AS order_shiptoname, cohead.cohead_shiptoaddress1 AS order_shiptoaddress, 
 coitem.coitem_linenumber AS order_line_num
   FROM cohead
   JOIN custinfo ON cohead.cohead_cust_id = custinfo.cust_id
   JOIN coitem ON coitem.coitem_cohead_id = cohead.cohead_id
   JOIN itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
   JOIN item ON itemsite.itemsite_item_id = item.item_id
   LEFT JOIN docass ON docass_source_id = cohead_id
  WHERE 
 coitem.coitem_subnumber = 0 AND 
 NOT (item.item_classcode_id = ANY (ARRAY[97, 63, 99, 113]))
 and cust_active = true
 and NOT cust_number ~ 'ASSET'
 AND (docass_id is null)
 AND coitem.coitem_status <> 'X'

 UNION -- get the old accounts with parent accounts
 
  SELECT p.cust_id, 
  CASE when custgrp_name  = '_All Other'
  THEN c.cust_name
  ELSE custgrp_descrip
  END AS cust_name, cohead.cohead_number AS order_num, 
 CASE
 WHEN coitem.coitem_promdate = '2100-01-01' THEN coitem.coitem_scheddate
 ELSE
 COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate) 
 END AS delivery_date, item_descrip1 AS item_description, coitem.coitem_qtyord AS qty_ordered, 
  null::date AS return_date, 
null AS qty_due,
 cohead.cohead_shiptoaddress1 AS order_shiptoname, cohead.cohead_shiptoaddress1 AS order_shiptoaddress, 
 coitem.coitem_linenumber AS order_line_num
   FROM cohead
   JOIN custinfo c ON cohead.cohead_cust_id = c.cust_id
   JOIN coitem ON coitem.coitem_cohead_id = cohead.cohead_id
   JOIN itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
   JOIN item ON itemsite.itemsite_item_id = item.item_id
   JOIN custgrpitem ON custgrpitem_cust_id = cust_id
   join custgrp on custgrpitem_custgrp_id = custgrp_id
   join custinfo p on p.cust_number = custgrp_name
   LEFT JOIN docass ON docass_source_id = cohead_id
  WHERE coitem.coitem_subnumber = 0 AND 
  NOT (item.item_classcode_id = ANY (ARRAY[97, 63, 99, 113]))
  and NOT c.cust_number ~ 'ASSET'
  AND (docass_id is null)
  AND coitem.coitem_status <> 'X'

  ORDER BY 2,3 ;


ALTER TABLE  order_history OWNER TO mfgadmin;
GRANT ALL ON TABLE  order_history TO mfgadmin;
GRANT ALL ON TABLE  order_history TO xtrole;
COMMENT ON VIEW  order_history IS 'Order History Report View used by webportal and xTuple';


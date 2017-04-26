-- View:  returns_list

-- DROP VIEW  returns_list;

CREATE OR REPLACE VIEW  returns_list AS 

SELECT rahead.rahead_id, 
rahead.rahead_number::character varying(25) AS authorization_number, 
cohead.cohead_number::character varying(25) AS cohead_number, 
coitem.coitem_id, 
raitem.raitem_orig_coitem_id, 
raitem.raitem_id, 
rahead.rahead_authdate AS f_authdate, 
return_date AS return_date, 
custinfo.cust_number::character varying(25) AS cust_number, 
custinfo.cust_name, 
item.item_number::character varying(25) AS item_number, 
item.item_descrip1::character varying(25) AS item_descrip1, 
delivery_date as coitem_scheddate,
0::int as dummy,
0::int as dummy1,
0::int as dummy2, 
raitem.raitem_qtyauthorized::integer AS raitem_qtyauthorized, 
coitem.coitem_qtyshipped::integer AS coitem_qtyshipped, 
raitem.raitem_qtyreceived::integer AS raitem_qtyreceived, 
coitem.coitem_qtyreturned::integer AS coitem_qtyreturned, 
raitem.raitem_status::character varying(25) AS raitem_status 
     
FROM rahead
JOIN raitem ON rahead.rahead_id = raitem.raitem_rahead_id
JOIN coitem ON coitem.coitem_id = raitem.raitem_orig_coitem_id
JOIN cohead ON cohead.cohead_id = coitem.coitem_cohead_id
JOIN _return.salesline_return_date ON salesline_return_date.salesline_coitem_id = coitem.coitem_id
JOIN custinfo ON cohead.cohead_cust_id = custinfo.cust_id
JOIN itemsite ON raitem.raitem_itemsite_id = itemsite.itemsite_id
JOIN item ON itemsite.itemsite_item_id = item.item_id
   
WHERE coitem.coitem_scheddate >= '2012-07-01'::date
       AND return_date <= '2099-12-31'         
       AND raitem.raitem_status = 'O'
AND raitem.raitem_qtyauthorized > 0                  		 
ORDER BY rahead.rahead_number, coitem.coitem_id;



ALTER TABLE  returns_list
  OWNER TO mfgadmin;
GRANT ALL ON TABLE  returns_list TO mfgadmin;
GRANT ALL ON TABLE  returns_list TO xtrole;
GRANT SELECT ON TABLE  returns_list TO public;
COMMENT ON VIEW  returns_list
  IS '20141107:rek Orbit 706 used by function getitemreturns';

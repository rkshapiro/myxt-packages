-- Function: getwaveitems(integer)

-- DROP FUNCTION getwaveitems(integer);

CREATE OR REPLACE FUNCTION getwaveitems(integer)
  RETURNS SETOF orderitems AS
$BODY$
DECLARE 
	_wave_number ALIAS FOR $1;
	_x RECORD;
	_y RECORD;	
	_z RECORD;
	_r _wms.orderitems%ROWTYPE;

BEGIN

	-- 20140218:jjb Had to add a new field to return (license_plate_number). Had to create a new type ( orderitems) to handle the new type.
	-- 20140826:rks reverted back to getting the item number and description from the sales order instead of the wave 
	--              also changed the wave to be in sales order number and item number order
	-- 20140904:rks added support for blank wave item numbers
	-- 20140910:rek completly rewritten query for speed and functionality. 
	-- 20140911:rek adding query for warehouse ship from address
	-- 20141013:rek added code for wavebatch_so_linenumber

-- rek 9/10/2014
-- this function is for printing out the labels for the wavebatch
---
-- our strategy here is to create two temp tables,
-- one of the cohead with addresses
-- and one of the coitem with item infomation

-- then we loop through the wavebatch for a selected wavebatch_wave_number
--
-- if the wavebatch_item_number is NULL, a blank item , we fill in most of the rows with cohead.
-- if not, we fill in the rows with cohead and coitem

-- Notes: for blank wavebatch_item_number, we use the MIN(coitem_scheddate) and the rahead_number is the wavebatch_sales_order_number

DROP TABLE IF EXISTS temp_cohead_holder;
DROP TABLE IF EXISTS temp_coitem_holder;

-- this temprary table retrieves the line items for the specific wavebatch_wave_number
-- first we find all coheads and associated data for any sales order items that are not null

CREATE Temporary table temp_cohead_holder as
select distinct ch.cohead_id,ch.cohead_number,ci.cust_name,		
	shipto_name AS to_address1,
	s.addr_line1 AS to_address2,
	s.addr_line2 AS to_address3,
	CASE
		WHEN LENGTH(s.addr_line3) > 0 THEN s.addr_line3
		ELSE s.addr_city||', '||s.addr_state||' '||s.addr_postalcode
	END AS to_address4,
	CASE
		WHEN LENGTH(s.addr_line3) = 0 THEN ''
		ELSE s.addr_city||', '||s.addr_state||' '||s.addr_postalcode 
	END AS to_address5,
	substring(ch.cohead_shipvia from position('-' in ch.cohead_shipvia)+1) as shipvia,
	'ASSET STEM Education' AS from_address1,
	w.addr_line1 AS from_address2,
	w.addr_line2 AS from_address3,
	CASE
		WHEN LENGTH(w.addr_line3) > 0 THEN w.addr_line3
		ELSE w.addr_city||', '||w.addr_state||' '||w.addr_postalcode
	END AS from_address4,
	CASE
		WHEN LENGTH(w.addr_line3) = 0 THEN ''
		ELSE w.addr_city||', '||w.addr_state||' '||w.addr_postalcode 
	END AS from_address5
from public.cohead ch
join  _wms.wavebatch wb
	on wb.wavebatch_sales_order_number = ch.cohead_number
JOIN custinfo ci 
	ON ci.cust_id = ch.cohead_cust_id
JOIN shiptoinfo st 
	ON ch.cohead_shipto_id = st.shipto_id
JOIN addr s ON st.shipto_addr_id = s.addr_id
JOIN whsinfo ws ON cohead_warehous_id = ws.warehous_id
JOIN addr w ON ws.warehous_addr_id = w.addr_id
where wb.wavebatch_wave_number = $1;

--- next we find all the coitems and associated data

CREATE Temporary table temp_coitem_holder as
select distinct coitem_cohead_id,
	ch.cohead_number,
	i.item_number,i.item_descrip1,ci.coitem_memo,ci.coitem_scheddate,
	ci.coitem_linenumber, -- 20141013:rek adding line number
	CASE 
		WHEN _return.isfinalsale(cohead_id) THEN 'Final Sale'
		WHEN coitem_raitem_itemsite_id IS NULL THEN cohead_number
		ELSE rahead_number
	END as rahead_number
from public.coitem ci
join public.cohead ch 
	on ci.coitem_cohead_id = ch.cohead_id
join public.itemsite s
	on ci.coitem_itemsite_id = s.itemsite_id
join public.item i
	on i.item_id = s.itemsite_item_id
 LEFT OUTER JOIN _wms.coitem_raitem 
 	ON ci.coitem_id = coitem_raitem_coitem_id
 LEFT OUTER JOIN itemalias 
 	ON (itemalias_item_id=item_id AND itemalias_number=coitem_custpn)
where ci.coitem_cohead_id in
	(select cohead_id from temp_cohead_holder);

 -- main loop. loop through the wavebatch table for a specific wavebatch_wave_number
for _y in
	select wavebatch_sales_order_number,wavebatch_item_number,wavebatch_license_plate_number,
	wavebatch_so_linenumber -- 20141013:rek adding line number
	from  _wms.wavebatch
	where wavebatch_wave_number = $1
	order by wavebatch_sales_order_number,wavebatch_item_number
	
LOOP
	if _y.wavebatch_item_number is NULL THEN
			-- blank item number

		-- only used for select the MIN date for a blank item number box for a specific cohead_number in temp_coitem_holder
		for _x in
			select MIN(coitem_scheddate) as coitem_scheddate
			from temp_coitem_holder
			where cohead_number = _y.wavebatch_sales_order_number
			
		LOOP	
			-- get the temp_cohead_holder data for s specific cohead_number
			for _z in
				select cohead_number,to_address1,to_address2,to_address3,to_address4,to_address5,cust_name,shipvia,
				from_address1,from_address2,from_address3,from_address4,from_address5
				from temp_cohead_holder
				where cohead_number = _y.wavebatch_sales_order_number
			LOOP		
				-- write out the reults to a row 
				_r.cohead_number := _y.wavebatch_sales_order_number;
				_r.rahead_number := '';
				_r.item_number := '';
				_r.item_descrip1 := '';
				_r.from_address1 := _z.from_address1;
				_r.from_address2 := _z.from_address2;
				_r.from_address3 := _z.from_address3;
				_r.from_address4 := _z.from_address4;
				_r.from_address5 := _z.from_address5;
				_r.to_address1 := _z.to_address1;
				_r.to_address2 := _z.to_address2;
				_r.to_address3 := _z.to_address3;
				_r.to_address4 := _z.to_address4;
				_r.to_address5 := _z.to_address5;
				_r.coitem_memo := '';
				_r.shipvia := _z.shipvia;
				_r.coitem_scheddate := _x.coitem_scheddate;
				_r.cust_name := _z.cust_name;
				_r.license_plate_number := _y.wavebatch_license_plate_number;

				RETURN NEXT _r;

			END LOOP;
			
		END LOOP;
			
	else
			-- named item number
			
			-- select from temp_coitem_holder for item description
			
			for _x in
				select item_descrip1,coitem_memo,coitem_scheddate,rahead_number
				from temp_coitem_holder
				where item_number = _y.wavebatch_item_number
				and cohead_number = _y.wavebatch_sales_order_number
				AND coitem_linenumber = _y.wavebatch_so_linenumber -- 20141013:rek check for line number
				order by coitem_memo desc
				LIMIT 1
				
				LOOP

				-- then select from temp_cohead_holder for addresses
					for _z in
						select cohead_number,to_address1,to_address2,to_address3,to_address4,to_address5,cust_name,
						shipvia,from_address1,from_address2,from_address3,from_address4,from_address5
						from temp_cohead_holder
						where cohead_number = _y.wavebatch_sales_order_number

					LOOP
						-- write out the results to a row 
						_r.cohead_number := _y.wavebatch_sales_order_number;
						_r.rahead_number := _x.rahead_number;
						_r.item_number := _y.wavebatch_item_number;
						_r.item_descrip1 := _x.item_descrip1;
						_r.from_address1 := _z.from_address1;
						_r.from_address2 := _z.from_address2;
						_r.from_address3 := _z.from_address3;
						_r.from_address4 := _z.from_address4;
						_r.from_address5 := _z.from_address5;
						_r.to_address1 := _z.to_address1;
						_r.to_address2 := _z.to_address2;
						_r.to_address3 := _z.to_address3;
						_r.to_address4 := _z.to_address4;
						_r.to_address5 := _z.to_address5;
						_r.coitem_memo := _x.coitem_memo;
						_r.shipvia := _z.shipvia;
						_r.coitem_scheddate := _x.coitem_scheddate;
						_r.cust_name := _z.cust_name;
						_r.license_plate_number := _y.wavebatch_license_plate_number;

						RETURN NEXT _r;

					END LOOP;
				
				END LOOP;
	End if;

END LOOP;
RETURN;
END;	
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION getwaveitems(integer) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION getwaveitems(integer) TO "admin";
GRANT EXECUTE ON FUNCTION getwaveitems(integer) TO xtrole;
COMMENT ON FUNCTION getwaveitems(integer) IS 'used for printing container labels from StepLogic';

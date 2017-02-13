-- DROP TYPE returnaging CASCADE;
CREATE TYPE returnaging AS (
return_date date,
delivery_date date,
item_number text,
item_description text,
rahead_number text,
rahead_billtoname text,
cust_number text,
cust_name text,
custtype_code text,
rahead_shipto_name text,
raitem_qtyauthorized numeric,
raitem_qtyreceived numeric,
thirty_fee numeric,
thirty_qty numeric,
sixty_qty numeric);
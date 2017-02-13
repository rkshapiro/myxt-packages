-- Type: orderitems

-- DROP TYPE orderitems;

CREATE TYPE orderitems AS
   (cohead_number character varying,
    rahead_number character varying,
    item_number character varying,
    item_descrip1 character varying,
    from_address1 character varying,
    from_address2 character varying,
    from_address3 character varying,
    from_address4 character varying,
    from_address5 character varying,
    to_address1 character varying,
    to_address2 character varying,
    to_address3 character varying,
    to_address4 character varying,
    to_address5 character varying,
    coitem_memo character varying,
    shipvia character varying,
    coitem_scheddate date,
    cust_name character varying,
    license_plate_number character varying
    );
ALTER TYPE orderitems OWNER TO "admin";

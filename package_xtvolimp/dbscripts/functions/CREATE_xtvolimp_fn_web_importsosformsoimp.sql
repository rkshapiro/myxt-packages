-- Function: xtvolimp.web_importsosfromsoimp()

-- DROP FUNCTION xtvolimp.web_importsosfromsoimp();

CREATE OR REPLACE FUNCTION xtvolimp.web_importsosfromsoimp()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full  of the software license.
DECLARE
 _cmacct    TEXT := '1-1020'; -- should be the bank account where CC funds are deposited
 _discountacct  TEXT := '1-4810'; -- the account for discounts
 _scheddate_offset INTEGER := 0; -- number of working days adjustment
 
BEGIN
-- Group: EDI (previous definition)
-- Name:  web_importsosfromsoimp
-- Notes: Deletes order from soimp where the order already exists in cohead.
--        Inserts customer when one does not exist
--        Inserts SO header
--        Inserts SO lines
--        Creates CMs
--        Allocates CMs
--        Updates soimp_inserted with date/time orders inserted
--        Only performs above where AND soimp_source = 'INT' so as not to process F4F and other order 
--        sources

-- validate orders with Processing status
SELECT xtvolimp.soimperrorcheckverbose();

BEGIN
-- Creates customer when customer does not yet exist
    INSERT INTO api.customer 
    (
    customer_number, customer_type, customer_name, active,
    sales_rep, commission, ship_via, ship_form, shipping_charges, 
    accepts_backorders, accepts_partial_shipments, 
    --
    allow_free_form_shipto, allow_free_form_billto,
    preferred_selling_site, default_tax_zone, default_terms,
    --
    balance_method, default_discount, default_currency, credit_limit_currency,
    credit_limit, alternate_grace_days, credit_rating, credit_status, credit_status_exceed_warn,
    credit_status_exceed_hold, uses_purchase_orders, uses_blanket_pos,
    --  billing contact
    billing_contact_number, 
    billing_contact_honorific, billing_contact_first,
    billing_contact_middle, billing_contact_last, billing_contact_suffix, 
    billing_contact_job_title, billing_contact_voice, billing_contact_alternate, 
    billing_contact_fax, billing_contact_email, billing_contact_web,
    billing_contact_change, billing_contact_address_number, 
    billing_contact_address1, billing_contact_address2, billing_contact_address3, 
    billing_contact_city, billing_contact_state, billing_contact_postalcode,
    billing_contact_country, billing_contact_address_change, 
    notes
    )
    SELECT DISTINCT ON (soimp_customer_number)
    UPPER(soimp_customer_number), 
    (SELECT custtype_code FROM custtype where custtype_id = fetchmetricvalue('DefaultCustType'::text)),
     soimp_customer_number, 't',
    (SELECT salesrep_number FROM salesrep WHERE salesrep_id = fetchmetricvalue('DefaultSalesRep'::text)),
     0, 'UPS GROUND-UPS Ground', 
    (SELECT shipform_name FROM shipform WHERE shipform_id = fetchmetricvalue('DefaultShipFormId'::text)),
    (SELECT shipchrg_name FROM shipchrg WHERE shipchrg_id = fetchmetricvalue('DefaultShipChrgId'::text)),
    'f','f', -- backorders
    't','t', -- free form
    (SELECT warehous_code FROM whsinfo WHERE warehous_id = fetchmetricvalue('DefaultSellingWarehouseId'::text)),
    null, 
    (SELECT terms_code FROM terms WHERE terms_id = fetchmetricvalue('DefaultTerms'::text)),
    --
    'Balance Forward', 0, 'USD', 'USD', 
    NULL, 0, 'Credit Card', 'In Good Standing', 'f',
    'f', 'f', 'f',
    -- billing contact
    '',  
    soimp_billto_cntct_honorific,  soimp_billto_cntct_first_name,
    soimp_billto_cntct_middle,  soimp_billto_cntct_last_name, soimp_billto_cntct_suffix,
    soimp_billto_cntct_title, soimp_billto_cntct_phone, '',
    soimp_billto_cntct_fax,  soimp_billto_cntct_email, '',
    '', '',
    soimp_billtoaddress1, soimp_billtoaddress2, soimp_billtoaddress3,
    soimp_billtocity, soimp_billtostate,  soimp_billtozipcode,
    soimp_billtocountry, '',
    -- correspond contact not done yet
    'Imported Customer'
    --
    FROM xtvolimp.soimp
    WHERE UPPER(soimp_customer_number) NOT IN (SELECT cust_number FROM custinfo) AND soimp_source = 'INT';
END;

BEGIN
    --Sales Order Header
    INSERT INTO api.salesorder
    (
    order_number, cust_po_number, site, order_date,
    customer_number,
    sale_type,
    terms,
    -- bill to start
    billto_contact_name, -- honorific 
    billto_contact_first, billto_contact_middle, billto_contact_last,  
    billto_contact_suffix,
    billto_contact_phone, billto_contact_title, billto_contct_fax,
    billto_contact_email,
    -- billto info
    billto_name,
    billto_address1, billto_address2, billto_address3, 
    billto_city, billto_state, billto_postal_code, billto_country,
    -- bill to end
    shipto_contact_honorific,  
    shipto_contact_first, shipto_contact_middle, shipto_contact_last,  
    shipto_contact_suffix,
    shipto_contact_phone, shipto_contact_title, shipto_contact_fax,
    shipto_contact_email,
    -- shipto info
    shipto_name,
    shipto_address1, shipto_address2, shipto_address3, 
    shipto_city, shipto_state, shipto_postal_code, shipto_country,
    freight, calculate_freight,
    misc_charge_description, misc_account_number, misc_charge,
    order_notes, shipping_notes,tax_zone
    )
    (SELECT DISTINCT soimp_order_number, soimp_po_number, soimp_sold_from_site, soimp_order_date,
    UPPER(soimp_customer_number), 
    'INT',  -- set sale type
    soimp_terms,
    -- billto start
    soimp_billto_cntct_honorific, 
    soimp_billto_cntct_first_name, soimp_billto_cntct_middle, soimp_billto_cntct_last_name,
    soimp_billto_cntct_suffix,
    soimp_billto_cntct_phone, soimp_billto_cntct_title, soimp_billto_cntct_fax,  
    soimp_billto_cntct_email,  
    -- billto info
    soimp_billto_name,
    soimp_billtoaddress1, soimp_billtoaddress2, soimp_billtoaddress3,
    soimp_billtocity, soimp_billtostate, soimp_billtozipcode, soimp_billtocountry,
    -- billto end
    soimp_shipto_cntct_honorific, 
    soimp_shipto_cntct_first_name, soimp_shipto_cntct_middle, soimp_shipto_cntct_last_name,
    soimp_shipto_cntct_suffix,
    soimp_shipto_cntct_phone, soimp_shipto_cntct_title, soimp_shipto_cntct_fax,  
    soimp_shipto_cntct_email,  
    -- shipto info
    soimp_shipto_name,
    soimp_shiptoaddress1, soimp_shiptoaddress2, soimp_shiptoaddress3,
    soimp_shiptocity, soimp_shiptostate, soimp_shiptozipcode, soimp_shiptocountry,
    soimp_freight, 'f'::bool,
    dsc.ordetail_productcode, 
    CASE WHEN dsc.ordimp_orderid IS NOT NULL THEN _discountacct ELSE NULL END AS misc_account,
    COALESCE(dsc.ordetail_productprice::numeric,0),
    soimp_delivery_note, soimp_delivery_note,
    UPPER(soimp_taxzone::TEXT)
    FROM xtvolimp.soimp 
    JOIN custinfo on cust_number = soimp_customer_number
    LEFT JOIN (SELECT ordimp_orderid,ordetail_productprice,ordetail_productcode -- grab the discount line item and make it a misc charge
               FROM xtvolimp.ordimp
               WHERE ordetail_productcode ~ 'DSC-') dsc ON dsc.ordimp_orderid = soimp_order_number
    WHERE soimp_inserted IS NULL
          AND soimp_status = 'Import'
          AND soimp_source = 'INT');
END;

--Lines
INSERT INTO api.salesline
(
order_number, 
item_number, sold_from_site, 
qty_ordered, net_unit_price,  
scheduled_date, notes, create_order
)
(SELECT DISTINCT 
soimp_order_number, 
-- soimp_line_number, 
soimp_item_number, 
soimp_sold_from_site, 
soimp_qty_ordered, soimp_unit_price, 
--  set the date to the next available working day
calculatenextworkingdate(
                         (SELECT warehous_id 
                          FROM whsinfo 
                          WHERE warehous_code = soimp_sold_from_site),
                         CURRENT_DATE, 
                         _scheddate_offset),
-- 
'Notes go here', CAST('f' AS BOOLEAN)
FROM xtvolimp.soimp
JOIN cohead on cohead_number = soimp_order_number
JOIN item on item_number = soimp_item_number
WHERE soimp_inserted IS NULL 
      AND soimp_status = 'Import'
      AND soimp_source = 'INT'
UNION
SELECT DISTINCT -- put the tax into a TAX reference item
soimp_order_number, 
-- soimp_line_number, 
'TAX'::text AS soimp_item_number, 
soimp_sold_from_site, 
1 AS soimp_qty_ordered, 
ordimp_salestax1::numeric AS soimp_unit_price, 
--  set the date to the next available working day
calculatenextworkingdate(
                         (SELECT warehous_id 
                          FROM whsinfo 
                          WHERE warehous_code = soimp_sold_from_site),
                         CURRENT_DATE, 
                         _scheddate_offset),
-- 
'Sales Tax charged on Volusion Order', CAST('f' AS BOOLEAN)
FROM xtvolimp.soimp
JOIN cohead on cohead_number = soimp_order_number
WHERE soimp_inserted IS NULL 
      AND soimp_status = 'Import'
      AND soimp_source = 'INT'
      AND ordimp_salestax1::numeric > 0
);

-- CREATE Credit Memo - assumes credit card payment
SELECT DISTINCT
cohead_number,
createarcreditmemo
( NULL::integer,  -- new
 cohead_cust_id,            
 cohead_number,   
 cohead_number,             
 cohead_orderdate,          
 (                          
   SELECT
       (SUM(round(coitem_qtyord * coitem_price,2)) + cohead_freight + cohead_misc)
   FROM coitem
   WHERE (coitem_cohead_id= cohead_id)         
          AND coitem_status NOT IN ('C','X')
          GROUP BY cohead_freight,cohead_misc, cohead_id
    ),
    'Auto Credit for Internet Order'::text,  
      getrsnid('ONLINE'), -- reason code (default) 
      NULL::integer,-- sales account id
      NULL::integer,-- account id
      current_date,-- duedate
      fetchmetricvalue('DefaultTerms'::text)::integer,-- terms id 
      fetchmetricvalue('DefaultSalesRep'::text)::integer,-- salesrepid
      0::numeric, -- commission due 
      NULL::integer, -- jrnl number 
      cohead_curr_id,
-------------------------------------------
      getglaccntid(_cmacct), -- accnt id
--------------------------------------------
      NULL::integer, -- pcoccayid 
      NULL::integer --taxzoneid               
    )
FROM cohead 
WHERE cohead_number IN (SELECT DISTINCT soimp_order_number 
                               FROM xtvolimp.soimp WHERE
                                                   soimp_inserted IS NULL 
                                                   AND soimp_status = 'Import'
                                                   AND soimp_source = 'INT'
                       );

-- ALLOCATE the CM to the SO
INSERT INTO aropenalloc
                        (aropenalloc_aropen_id, aropenalloc_doctype, aropenalloc_doc_id, 
                         aropenalloc_amount, aropenalloc_curr_id)
                    (
                           SELECT DISTINCT
                           aropen_id, 'S', cohead_id,
                           aropen_amount, aropen_curr_id
                           FROM aropen
                                JOIN cohead ON (cohead_number = aropen_ordernumber)
                                JOIN xtvolimp.soimp ON (soimp_order_number = cohead_number)
                                WHERE 
                                     aropen_doctype = 'C'
                                 AND soimp_status = 'Import'
                                 AND soimp_source = 'INT'
                                 AND soimp_inserted IS NULL
                                 AND aropen_amount - aropen_paid > 0
                                 AND aropen_posted = 'f'
                                 AND aropen_open = 't'
                                 AND aropen_id NOT IN (SELECT aropenalloc_aropen_id FROM aropenalloc)
                            ); 
-- set inserted date
UPDATE xtvolimp.ordimp
SET ordimp_inserted = current_date
WHERE ordimp_orderstatus = 'Import'
AND ordimp_inserted IS NULL ;

INSERT INTO evntlog (evntlog_evnttime, evntlog_username, evntlog_evnttype_id,evntlog_ordtype)
    SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,'S'
    FROM evntnot, evnttype
    WHERE ( (evntnot_evnttype_id=evnttype_id)
     AND (evnttype_name='SOImportComplete'));

RETURN 0;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10000;
ALTER FUNCTION xtvolimp.web_importsosfromsoimp()
  OWNER TO admin;

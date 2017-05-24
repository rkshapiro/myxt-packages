-- View: xtvolimp.soimp

DROP VIEW if exists xtvolimp.soimp;

CREATE OR REPLACE VIEW xtvolimp.soimp AS 
 SELECT ordimp.ordimp_orderstatus AS soimp_status,
    ordimp.ordimp_orderid AS soimp_order_number,
    ordimp.ordimp_orderdate::date AS soimp_order_date,
    'V-'||ordimp.ordimp_customerid AS soimp_customer_number,
    ordimp.ordimp_ponum AS soimp_po_number,
    ''::text AS soimp_shipto_number,
    ''::text AS soimp_shipto_cntct_honorific,
    ordimp.ordimp_shipfirstname AS soimp_shipto_cntct_first_name,
    ''::text AS soimp_shipto_cntct_middle,
    ordimp.ordimp_shiplastname AS soimp_shipto_cntct_last_name,
    ''::text AS soimp_shipto_cntct_suffix,
    ordimp.ordimp_shipphonenumber AS soimp_shipto_cntct_phone,
    ''::text AS soimp_shipto_cntct_title,
    ordimp.ordimp_shipfaxnumber AS soimp_shipto_cntct_fax,
    ''::text AS soimp_shipto_cntct_email,
    (ordimp.ordimp_shipfirstname || ' '::text) || ordimp.ordimp_shiplastname AS soimp_shipto_name,
    ordimp.ordimp_shipaddress1 AS soimp_shiptoaddress1,
    ordimp.ordimp_shipaddress2 AS soimp_shiptoaddress2,
    ''::text AS soimp_shiptoaddress3,
    ordimp.ordimp_shipcity AS soimp_shiptocity,
    ordimp.ordimp_shipstate AS soimp_shiptostate,
    ordimp.ordimp_shippostalcode AS soimp_shiptozipcode,
    ordimp.ordimp_shipcountry AS soimp_shiptocountry,
    ''::text AS soimp_line_number,
    (SELECT warehous_code FROM whsinfo WHERE warehous_id = fetchmetricvalue('DefaultSellingWarehouseId'::text)) AS soimp_sold_from_site,
    UPPER(ordimp.ordetail_productcode) AS soimp_item_number,
    ordimp.ordetail_quantity::numeric AS soimp_qty_ordered,
    ordimp.ordetail_productprice::numeric AS soimp_unit_price,
    ''::text AS soimp_po_uom,
    ''::text AS soimp_so_uom,
    ordimp.ordetail_shipdate::date AS soimp_due_date,
    ''::text AS soimp_characteristic,
    ''::text AS soimp_value,
    ordimp.ordimp_inserted AS soimp_inserted,
    current_date::date AS soimp_updated,
    ordimp.ordimp_totalshippingcost::numeric AS soimp_freight,
    ordimp.ordimp_ordernotes||' '||ordimp.ordimp_order_comments AS soimp_delivery_note,
    ''::text AS soimp_billto_cntct_honorific,
    ordimp.ordimp_billingfirstname AS soimp_billto_cntct_first_name,
    ''::text AS soimp_billto_cntct_middle,
    ordimp.ordimp_billinglastname AS soimp_billto_cntct_last_name,
    ''::text AS soimp_billto_cntct_suffix,
    ordimp.ordimp_billingphonenumber AS soimp_billto_cntct_phone,
    ''::text AS soimp_billto_cntct_title,
    ''::text AS soimp_billto_cntct_fax,
    ''::text AS soimp_billto_cntct_email,
    ordimp.ordimp_billingcompanyname AS soimp_billto_name,
    ordimp.ordimp_billingaddress1 AS soimp_billtoaddress1,
    ordimp.ordimp_billingaddress2 AS soimp_billtoaddress2,
    ''::text AS soimp_billtoaddress3,
    ordimp.ordimp_billingcity AS soimp_billtocity,
    ordimp.ordimp_billingstate AS soimp_billtostate,
    ordimp.ordimp_billingpostalcode AS soimp_billtozipcode,
    ordimp.ordimp_billingcountry AS soimp_billtocountry,
    ordimp.ordimp_paymentmethodid AS soimp_payment_type,
    ordimp.ordimp_creditcardauthorizationnumber,
    ordimp.ordimp_creditcardtransactionid,
    'INT'::text AS soimp_source,
    'TAX'::text AS soimp_taxzone, -- DEFAULT Exempt Tax will go on reference item
    CASE 
    WHEN ordimp_paymentmethodid = '5' THEN 'VISA'
    WHEN ordimp_paymentmethodid = '6' THEN 'MC'
    WHEN ordimp_paymentmethodid = '7' THEN 'AMEX'
    WHEN ordimp_paymentmethodid = '25' THEN 'PAYPAL'
    WHEN ordimp_paymentmethodid = '27' THEN 'AMAZON'
    ELSE 'DUE ON ORDER'
    END AS soimp_terms,
    ordimp.ordimp_tax2_title,
    ordimp.ordimp_tax3_title,
    ordimp.ordimp_salestax1,
    ordimp.ordimp_salestax2,
    ordimp.ordimp_salestax3,
    ordimp.ordimp_total_payment_received,
    ordimp.ordimp_total_payment_authorized,
    ordimp.ordimp_paymentamount,
    'V-' || ordimp.ordimp_customerid AS soimp_crm_number,
    ordimp.ordetail_orderdetailid AS orderdetailid,
    ordimp.ordetail_error AS error_msg
   FROM xtvolimp.ordimp;

ALTER TABLE xtvolimp.soimp
  OWNER TO admin;
GRANT ALL ON TABLE xtvolimp.soimp TO admin;
GRANT ALL ON TABLE xtvolimp.soimp TO xtrole;

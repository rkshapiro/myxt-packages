--create table to receive data
-- Table: xtvolimp.ordimp
drop table if exists xtvolimp.ordimp cascade;

CREATE TABLE xtvolimp.ordimp
(
  ordimp_id serial NOT NULL,
ordimp_orderid text,
ordimp_customerid text,
ordimp_billingcompanyname text,
ordimp_billingfirstname text,
ordimp_billinglastname text,
ordimp_billingaddress1 text,
ordimp_billingaddress2 text,
ordimp_billingcity text,
ordimp_billingstate text,
ordimp_billingpostalcode text,
ordimp_billingcountry text,
ordimp_billingphonenumber text,
ordimp_shipcompanyname text,
ordimp_shipfirstname text,
ordimp_shiplastname text,
ordimp_shipaddress1 text,
ordimp_shipaddress2 text,
ordimp_shipcity text,
ordimp_shipstate text,
ordimp_shippostalcode text,
ordimp_shipcountry text,
ordimp_shipphonenumber text,
ordimp_shipfaxnumber text,
ordimp_shippingmethodid text,
ordimp_totalshippingcost text,
ordimp_salestaxrate text,
ordimp_paymentamount text,
ordimp_paymentmethodid text,
ordimp_cardholdersname text,
ordimp_creditcardexpdate text,
ordimp_creditcardauthorizationnumber text,
ordimp_creditcardtransactionid text,
ordimp_bankname text,
ordimp_routingnumber text,
ordimp_accountnumber text,
ordimp_accounttype text,
ordimp_micr text,
ordimp_checknumber text,
ordimp_ponum text,
ordimp_giftcardidused text,
ordimp_isagift text,
ordimp_locked text,
ordimp_shipped text,
ordimp_vendorid text,
ordimp_orderdate text,
ordimp_creditcardauthorizationdate text,
ordimp_shipdate text,
ordimp_paymentdeclined text,
ordimp_customer_ipaddress text,
ordimp_lastmodified text,
ordimp_avs text,
ordimp_cashtender text,
ordimp_billingfaxnumber text,
ordimp_cvv2_response text,
ordimp_orderstatus text,
ordimp_affiliate_commissionable_value text,
ordimp_processed_autoevents text,
ordimp_lastmodby text,
ordimp_shipping_locked text,
ordimp_printed text,
ordimp_total_payment_received text,
ordimp_total_payment_authorized text,
ordimp_batchnumber text,
ordimp_tax1_title text,
ordimp_tax2_title text,
ordimp_tax3_title text,
ordimp_salestaxrate1 text,
ordimp_salestaxrate2 text,
ordimp_salestaxrate3 text,
ordimp_salestax1 text,
ordimp_salestax2 text,
ordimp_salestax3 text,
ordimp_creditcardissuedate text,
ordimp_creditcardissuenumber text,
ordimp_ordernotes text,
ordimp_order_comments text,
ordimp_salesrep_customerid text,
ordimp_order_entry_system text,
ordimp_shipresidential text,
ordimp_stock_priority text,
ordimp_custom_field_custom1 text,
ordimp_custom_field_custom2 text,
ordimp_custom_field_custom3 text,
ordimp_custom_field_custom4 text,
ordimp_custom_field_custom5 text,
ordimp_orderid_third_party text,
ordimp_addressvalidated text,
ordimp_cc_last4 text,
ordimp_dv_creditcardnumber text,
ordimp_taxrate_isvat text,
ordimp_tax2_includeprevious text,
ordimp_tax3_includeprevious text,
ordimp_tax1_ignorenotaxrules text,
ordimp_tax2_ignorenotaxrules text,
ordimp_tax3_ignorenotaxrules text,
ordimp_giftwrapnote text,
ordimp_authhash text,
ordimp_pciaas_cardid text,
ordimp_pciaas_maskedcardref text,
ordimp_sorderid text,
ordimp_cancelreason text,
ordimp_canceldate text,
ordimp_isgtsorder text,
ordimp_initiallyshippeddate text,
ordimp_orderid_third_party_link text,
ordimp_orderdateutc text,
ordimp_inserted DATE DEFAULT NULL,
ordetail_orderdetailid text,
ordetail_productcode text,
ordetail_productprice text,
ordetail_quantity text,
ordetail_shipdate text,
ordetail_error text,
ordetail_import boolean,
  CONSTRAINT ordimp_pkey PRIMARY KEY (ordimp_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE xtvolimp.ordimp OWNER TO "admin";
GRANT ALL ON TABLE xtvolimp.ordimp TO "admin";
GRANT ALL ON TABLE xtvolimp.ordimp TO xtrole;
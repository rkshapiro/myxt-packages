--create table to receive data
-- Table: xtvolimp.custimp

-- DROP TABLE xtvolimp.custimp;

CREATE TABLE xtvolimp.custimp
(
  custimp_id serial NOT NULL,
custimp_customerid text,
custimp_accesskey text,
custimp_firstname text,
custimp_lastname text,
custimp_companyname text,
custimp_billingaddress1 text,
custimp_billingaddress2 text,
custimp_city text,
custimp_state text,
custimp_postalcode text,
custimp_country text,
custimp_phonenumber text,
custimp_faxnumber text,
custimp_emailaddress text,
custimp_paysstatetax text,
custimp_taxid text,
custimp_emailsubscriber text,
custimp_catalogsubscriber text,
custimp_lastmodified text,
custimp_percentdiscount text,
custimp_websiteaddress text,
custimp_discountlevel text,
custimp_customertype text,
custimp_lastmodby text,
custimp_customer_isanonymous text,
custimp_issuperadmin text,
custimp_news1 text,
custimp_news2 text,
custimp_news3 text,
custimp_news4 text,
custimp_news5 text,
custimp_news6 text,
custimp_news7 text,
custimp_news8 text,
custimp_news9 text,
custimp_news10 text,
custimp_news11 text,
custimp_news12 text,
custimp_news13 text,
custimp_news14 text,
custimp_news15 text,
custimp_news16 text,
custimp_news17 text,
custimp_news18 text,
custimp_news19 text,
custimp_news20 text,
custimp_allow_access_to_private_sections text,
custimp_customer_notes text,
custimp_salesrep_customerid text,
custimp_id_customers_groups text,
custimp_custom_field_custom1 text,
custimp_custom_field_custom2 text,
custimp_custom_field_custom3 text,
custimp_custom_field_custom4 text,
custimp_custom_field_custom5 text,
custimp_removed_from_rewards text,
  CONSTRAINT custimp_pkey PRIMARY KEY (custimp_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE xtvolimp.custimp OWNER TO "admin";
GRANT ALL ON TABLE xtvolimp.custimp TO "admin";
GRANT ALL ON TABLE xtvolimp.custimp TO xtrole;
--create table to receive data
-- Table: xtvolimp.ordetail

-- DROP TABLE xtvolimp.ordetail CASCADE;

CREATE TABLE xtvolimp.ordetail
(
  ordetail_id serial NOT NULL,
ordetail_orderdetailid text,
ordetail_orderid text,
ordetail_productcode text,
ordetail_productname text,
ordetail_quantity text,
ordetail_downloadfile text,
ordetail_productprice text,
ordetail_totalprice text,
ordetail_shipped text,
ordetail_shipdate text,
ordetail_gifttraknumber text,
ordetail_locked text,
ordetail_onorder_qty text,
ordetail_giftwrap text,
ordetail_giftwrapnote text,
ordetail_giftwrapcost text,
ordetail_lastmodified text,
ordetail_optionids text,
ordetail_rma_number text,
ordetail_rmai_id text,
ordetail_returned text,
ordetail_returned_date text,
ordetail_product_keys_shipped text,
ordetail_iskitid text,
ordetail_kitid text,
ordetail_fixed_shippingcost text,
ordetail_fixed_shippingcost_outside_localregion text,
ordetail_optionid text,
ordetail_warehouses text,
ordetail_productweight text,
ordetail_affiliate_commissionable_value text,
ordetail_customlineitem text,
ordetail_taxableproduct text,
ordetail_freeshippingitem text,
ordetail_productnote text,
ordetail_qtyonbackorder text,
ordetail_qtyonhold text,
ordetail_qtyshipped text,
ordetail_autodropship text,
ordetail_lastmodby text,
ordetail_vendor_price text,
ordetail_categoryid text,
ordetail_options text,
ordetail_qtyonpackingslip text,
ordetail_couponcode text,
ordetail_discountautoid text,
ordetail_discounttype text,
ordetail_discountvalue text,
ordetail_vat_percentage text,
ordetail_reward_points_given_for_purchase text,
ordetail_length text,
ordetail_width text,
ordetail_height text,
ordetail_ships_by_itself text,
ordetail_package_type text,
ordetail_oversized text,
ordetail_additiona_handling_indicator text,
ordetail_orderdetailid_third_party text,
ordetail_orderdetailid_third_party_link text,
ordetail_error text,
ordetail_import boolean DEFAULT true,
  CONSTRAINT ordetail_pkey PRIMARY KEY (ordetail_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE xtvolimp.ordetail OWNER TO "admin";
GRANT ALL ON TABLE xtvolimp.ordetail TO "admin";
GRANT ALL ON TABLE xtvolimp.ordetail TO xtrole;
create table xtsqrimp.sqrimp
(
sqrimp_id serial not null,
sqrimp_date text,
sqrimp_time text, 
sqrimp_timezone text, 
sqrimp_category text, 
sqrimp_item text, 
sqrimp_qty text, 
sqrimp_pricepointname text, 
sqrimp_sku text, 
sqrimp_modifiersapplied text, 
sqrimp_grosssales text, 
sqrimp_discounts text, 
sqrimp_netsales text, 
sqrimp_tax text, 
sqrimp_transactionid text, 
sqrimp_paymentid text, 
sqrimp_devicename text, 
sqrimp_notes text, 
sqrimp_details text, 
sqrimp_eventtype text, 
sqrimp_location text, 
sqrimp_diningoption text, 
sqrimp_customerid text, 
sqrimp_customername text, 
sqrimp_customerreferenceid text,
sqrimp_status text,
sqrimp_invcnum text,
  constraint sqrimp_pkey primary key (sqrimp_id)
)
with (
  oids=false
);
alter table xtsqrimp.sqrimp owner to "admin";
grant all on table xtsqrimp.sqrimp to "admin";
grant all on table xtsqrimp.sqrimp to xtrole;
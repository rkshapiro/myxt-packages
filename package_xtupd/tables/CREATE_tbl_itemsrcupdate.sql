-- Table: itemsrcupdate

DROP TABLE IF EXISTS itemsrcupdate;

CREATE TABLE itemsrcupdate
(
  itemsrcupdate_id serial NOT NULL,
  itemsrcupdate_item_number text,
  itemsrcupdate_vend_number text,
  itemsrcupdate_vend_item_number text,
  itemsrcupdate_active boolean,
  itemsrcupdate_default boolean,
  itemsrcupdate_vend_uom text,
  itemsrcupdate_invvendoruomratio numeric(20,10),
  itemsrcupdate_minordqty numeric(18,6) ,
  itemsrcupdate_multordqty numeric(18,6),
  itemsrcupdate_ranking integer,
  itemsrcupdate_leadtime integer,
  itemsrcupdate_comments text,
  itemsrcupdate_vend_item_descrip text,
  itemsrcupdate_manuf_name text DEFAULT ''::text,
  itemsrcupdate_manuf_item_number text DEFAULT ''::text,
  itemsrcupdate_manuf_item_descrip text, 
  itemsrcupdate_upccode text,
  itemsrcupdate_contrct_number text,
  itemsrcupdate_effective date DEFAULT startoftime(), -- Effective date for item source.  Constraint for overlap.
  itemsrcupdate_expires date DEFAULT endoftime(), -- Expiration date for item source.  Constraint for overlap.
  itemsrcupdate_qtybreak numeric(18,6),
  itemsrcupdate_type text , -- Pricing type for item source price.  Valid values are N-nominal and D-discount.
  itemsrcupdate_pricing_site text, -- Used to determine if item source price applies only to specific site on purchase orders.
  itemsrcupdate_dropship boolean , -- Used to determine if item source price applies only to drop ship purchase orders.
  itemsrcupdate_price numeric(16,6),
  itemsrcupdate_curr text,
  itemsrcupdate_discntprcnt numeric(16,6), -- Discount percent for item source price.
  itemsrcupdate_fixedamtdiscount numeric(16,6), -- Fixed amount discount for item source price.
  itemsrcupdate_updated date NOT NULL DEFAULT now(),
  CONSTRAINT itemsrcupdate_pkey PRIMARY KEY (itemsrcupdate_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE itemsrcupdate
  OWNER TO admin;
GRANT ALL ON TABLE itemsrcupdate TO admin;
GRANT ALL ON TABLE itemsrcupdate TO xtrole;
COMMENT ON TABLE itemsrcupdate
  IS 'Item Source update information';
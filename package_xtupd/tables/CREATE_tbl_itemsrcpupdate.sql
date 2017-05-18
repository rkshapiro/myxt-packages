-- Table: itemsrcpupdate

-- DROP TABLE itemsrcpupdate;

CREATE TABLE itemsrcpupdate
(
  itemsrcpupdate_id serial NOT NULL,
  itemsrcpupdate_item_number text,
  itemsrcpupdate_vend_number text,
  itemsrcpupdate_vend_item_number text,
  itemsrcpupdate_effective date DEFAULT startoftime(), -- Effective date for item source.  Constraint for overlap.
  itemsrcpupdate_expires date DEFAULT endoftime(), -- Expiration date for item source.  Constraint for overlap.
  itemsrcpupdate_qtybreak numeric(18,6),
  itemsrcpupdate_type text , -- Pricing type for item source price.  Valid values are N-nominal and D-discount.
  itemsrcpupdate_warehous_code text, -- Used to determine if item source price applies only to specific site on purchase orders.
  itemsrcpupdate_dropship boolean , -- Used to determine if item source price applies only to drop ship purchase orders.
  itemsrcpupdate_price numeric(16,6),
  itemsrcpupdate_curr text,
  itemsrcpupdate_discntprcnt numeric(16,6), -- Discount percent for item source price.
  itemsrcpupdate_fixedamtdiscount numeric(16,6), -- Fixed amount discount for item source price.
  itemsrcpupdate_updated date NOT NULL DEFAULT now(),
  CONSTRAINT itemsrcpupdate_pkey PRIMARY KEY (itemsrcpupdate_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE itemsrcpupdate
  OWNER TO admin;
GRANT ALL ON TABLE itemsrcpupdate TO admin;
GRANT ALL ON TABLE itemsrcpupdate TO xtrole;
COMMENT ON TABLE itemsrcpupdate
  IS 'Item Source Price information';
-- Table: outbound_writeback

-- DROP TABLE outbound_writeback;

CREATE TABLE outbound_writeback
(
  outbound_writeback_id integer NOT NULL DEFAULT nextval('outbound_writeback_id_seq'::regclass),
  track_number text, -- shipped item tracking number
  order_number text,
  ship_date date,
  item_descrip text,
  box_weight text,
  shipto_name text,
  shipto_address1 text,
  shipto_address2 text,
  shipto_address3 text,
  city text,
  state text,
  zip text,
  shiphead_number text, -- shipment number
  master_track_number text, -- shipment tracking number
  CONSTRAINT outbound_writeback_pk PRIMARY KEY (outbound_writeback_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE outbound_writeback
  OWNER TO xtrole;
GRANT ALL ON TABLE outbound_writeback TO xtrole;
COMMENT ON TABLE outbound_writeback
  IS 'outbound writeback CSV Import';
COMMENT ON COLUMN outbound_writeback.track_number IS 'shipped item tracking number';
COMMENT ON COLUMN outbound_writeback.master_track_number IS 'shipment tracking number';
COMMENT ON COLUMN outbound_writeback.shiphead_number IS 'shipment number';


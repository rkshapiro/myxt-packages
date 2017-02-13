-- Sequence:  wavebatch_wavebatch_id_seq

-- DROP SEQUENCE  wavebatch_wavebatch_id_seq;

CREATE SEQUENCE  wavebatch_wavebatch_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 3
  CACHE 1;
ALTER TABLE  wavebatch_wavebatch_id_seq OWNER TO mfgadmin;
GRANT ALL ON TABLE  wavebatch_wavebatch_id_seq TO mfgadmin;
GRANT ALL ON TABLE  wavebatch_wavebatch_id_seq TO xtrole;

-- Table:  wavebatch

-- DROP TABLE  wavebatch;

CREATE TABLE  wavebatch
(
  wavebatch_id integer NOT NULL DEFAULT nextval(' wavebatch_wavebatch_id_seq'::regclass),
  wavebatch_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
  wavebatch_item_number text,
  wavebatch_license_plate_number text,
  wavebatch_wave_number integer NOT NULL,
  wavebatch_sales_order_number text,
  wavebatch_so_linenumber integer,
  CONSTRAINT wavebatch_pkey PRIMARY KEY (wavebatch_id),
  CONSTRAINT wavebatch_id UNIQUE (wavebatch_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE  wavebatch OWNER TO mfgadmin;
GRANT ALL ON TABLE  wavebatch TO mfgadmin;
GRANT ALL ON TABLE  wavebatch TO xtrole;
COMMENT ON TABLE  wavebatch IS 'wavebatch - container labels to print as part of a wave';


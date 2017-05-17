-- Sequence: outbound_writeback_id_seq

-- DROP SEQUENCE outbound_writeback_id_seq;

CREATE SEQUENCE outbound_writeback_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 24193
  CACHE 1;
ALTER TABLE outbound_writeback_id_seq
  OWNER TO xtrole;
GRANT ALL ON TABLE outbound_writeback_id_seq TO xtrole;
GRANT ALL ON TABLE outbound_writeback_id_seq TO public;

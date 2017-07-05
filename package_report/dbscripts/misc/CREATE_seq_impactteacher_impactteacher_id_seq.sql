-- Sequence: impactteacher_impactteacher_id_seq

-- DROP SEQUENCE impactteacher_impactteacher_id_seq;

CREATE SEQUENCE impactteacher_impactteacher_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE impactteacher_impactteacher_id_seq
  OWNER TO mfgadmin;
GRANT ALL ON TABLE impactteacher_impactteacher_id_seq TO mfgadmin;
GRANT ALL ON TABLE impactteacher_impactteacher_id_seq TO xtrole;
-- Sequence: impact_comment_id_seq

-- DROP SEQUENCE impact_comment_id_seq;

CREATE SEQUENCE impact_comment_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 201
  CACHE 1;
ALTER TABLE impact_comment_id_seq
  OWNER TO mfgadmin;
GRANT ALL ON TABLE impact_comment_id_seq TO mfgadmin;
GRANT ALL ON TABLE impact_comment_id_seq TO xtrole;

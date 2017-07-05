-- Sequence: _report.impact_comment_id_seq

-- DROP SEQUENCE _report.impact_comment_id_seq;

CREATE SEQUENCE _report.impact_comment_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 201
  CACHE 1;
ALTER TABLE _report.impact_comment_id_seq
  OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.impact_comment_id_seq TO mfgadmin;
GRANT ALL ON TABLE _report.impact_comment_id_seq TO xtrole;

-- Sequence: impact_teacher_impactteacher_id_seq

-- DROP SEQUENCE impact_teacher_impactteacher_id_seq;

CREATE SEQUENCE impact_teacher_impactteacher_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 2
  CACHE 1;
ALTER TABLE impact_teacher_impactteacher_id_seq
  OWNER TO mfgadmin;
GRANT ALL ON TABLE impact_teacher_impactteacher_id_seq TO mfgadmin;
GRANT ALL ON TABLE impact_teacher_impactteacher_id_seq TO xtrole;

-- Sequence: impact_teacher_comment_id_seq

-- DROP SEQUENCE impact_teacher_comment_id_seq;

CREATE SEQUENCE impact_teacher_comment_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 7
  CACHE 1;
ALTER TABLE impact_teacher_comment_id_seq
  OWNER TO admin;
COMMENT ON SEQUENCE impact_teacher_comment_id_seq
  IS '20150428:rek Orbit 881';

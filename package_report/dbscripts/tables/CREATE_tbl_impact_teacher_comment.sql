-- Sequence: _report.impact_teacher_comment_id_seq

DROP SEQUENCE IF EXISTS _report.impact_teacher_comment_id_seq CASCADE;

CREATE SEQUENCE _report.impact_teacher_comment_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 7
  CACHE 1;
ALTER TABLE _report.impact_teacher_comment_id_seq
  OWNER TO admin;
COMMENT ON SEQUENCE _report.impact_teacher_comment_id_seq
  IS '20150428:rek Orbit 881';

-- Table: _report.impact_teacher_comment

DROP TABLE IF EXISTS _report.impact_teacher_comment CASCADE;

CREATE TABLE _report.impact_teacher_comment 
(
  impact_teacher_comment_id integer NOT NULL DEFAULT nextval('_report.impact_teacher_comment_id_seq'::regclass),
  impact_teacher_comment_impact_teacher_id integer NOT NULL,
  impact_teacher_comment_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
  impact_teacher_comment_user text NOT NULL DEFAULT "current_user"(),
  impact_teacher_comment_comment text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE _report.impact_teacher_comment
  OWNER TO admin;
GRANT SELECT ON TABLE _report.impact_teacher_comment TO public;
GRANT ALL ON TABLE _report.impact_teacher_comment TO xtrole;
COMMENT ON TABLE _report.impact_teacher_comment
  IS '20150428:rek Orbit 881';

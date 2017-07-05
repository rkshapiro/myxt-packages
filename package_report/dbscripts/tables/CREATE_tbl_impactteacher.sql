-- Sequence: _report.impactteacher_impactteacher_id_seq

DROP SEQUENCE IF EXISTS _report.impactteacher_impactteacher_id_seq CASCADE;

CREATE SEQUENCE _report.impactteacher_impactteacher_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE _report.impactteacher_impactteacher_id_seq
  OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.impactteacher_impactteacher_id_seq TO mfgadmin;
GRANT ALL ON TABLE _report.impactteacher_impactteacher_id_seq TO xtrole;

-- Table: _report.impactteacher

DROP TABLE IF EXISTS _report.impactteacher CASCADE;

CREATE TABLE _report.impactteacher
(
  impactteacher_id integer NOT NULL DEFAULT nextval('_report.impactteacher_impactteacher_id_seq'::regclass),
  impactteacher_cust_id integer NOT NULL,
  impactteacher_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
  impactteacher_lastupdated timestamp without time zone NOT NULL DEFAULT ('now'::text)::timestamp(6) with time zone,
  impactteacher_teacher_pre_k integer NOT NULL DEFAULT 0,
  impactteacher_teacher_kindergarten integer NOT NULL DEFAULT 0,
  impactteacher_teacher_1 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_2 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_3 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_4 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_5 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_6 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_7 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_8 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_9 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_10 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_11 integer NOT NULL DEFAULT 0,
  impactteacher_teacher_12 integer NOT NULL DEFAULT 0,
  
  CONSTRAINT impactteacher_pkey PRIMARY KEY (impactteacher_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE _report.impactteacher
  OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.impactteacher TO mfgadmin;
GRANT ALL ON TABLE _report.impactteacher TO xtrole;
COMMENT ON TABLE _report.impactteacher
  IS 'Impact Teacher - who is using the ASSET program';

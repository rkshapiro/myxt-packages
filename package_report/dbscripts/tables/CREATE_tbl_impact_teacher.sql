-- Table: _report.impact_teacher

-- DROP TABLE _report.impact_teacher;

CREATE TABLE _report.impact_teacher
(
  impact_teacher_id integer NOT NULL DEFAULT nextval('_report.impact_teacher_impactteacher_id_seq'::regclass),
  impact_teacher_cust_id integer NOT NULL,
  impact_teacher_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
  impact_teacher_lastupdated timestamp without time zone NOT NULL DEFAULT ('now'::text)::timestamp(6) with time zone,
  impact_teacher_teacher_pre_k integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_kindergarten integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_1 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_2 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_3 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_4 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_5 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_6 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_7 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_8 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_9 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_10 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_11 integer NOT NULL DEFAULT 0,
  impact_teacher_teacher_12 integer NOT NULL DEFAULT 0,
  impact_teacher_undergraduate integer NOT NULL DEFAULT 0,
  impact_teacher_graduate integer NOT NULL DEFAULT 0,
  impact_teacher_out_of_school integer NOT NULL DEFAULT 0,
  impact_teacher_total integer NOT NULL DEFAULT 0,
  impact_teacher_reduced_lunch integer NOT NULL DEFAULT 0,
  fiscal_year bpchar,
  source_id integer,
  created_by_user text,
  modified_by_user text,
  CONSTRAINT impact_teacher_pkey PRIMARY KEY (impact_teacher_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE _report.impact_teacher
  OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.impact_teacher TO mfgadmin;
GRANT ALL ON TABLE _report.impact_teacher TO xtrole;
COMMENT ON TABLE _report.impact_teacher
  IS 'Impact Teacher - who is using the ASSET program';

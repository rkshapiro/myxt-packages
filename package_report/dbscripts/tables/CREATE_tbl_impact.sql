-- Sequence: _report.impact_impact_id_seq

-- DROP SEQUENCE _report.impact_impact_id_seq;

CREATE SEQUENCE _report.impact_impact_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 3
  CACHE 1;
ALTER TABLE _report.impact_impact_id_seq OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.impact_impact_id_seq TO mfgadmin;
GRANT ALL ON TABLE _report.impact_impact_id_seq TO xtrole;

-- Table: _report.impact

-- DROP TABLE _report.impact;

CREATE TABLE _report.impact
(
  impact_id integer NOT NULL DEFAULT nextval('_report.impact_impact_id_seq'::regclass),
  impact_cust_id integer NOT NULL,
  impact_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
  impact_lastupdated timestamp without time zone NOT NULL DEFAULT ('now'::text)::timestamp(6) with time zone,
  impact_students_pre_k integer NOT NULL DEFAULT 0,
  impact_students_kindergarten integer NOT NULL DEFAULT 0,
  impact_students_1 integer NOT NULL DEFAULT 0,
  impact_students_2 integer NOT NULL DEFAULT 0,
  impact_students_3 integer NOT NULL DEFAULT 0,
  impact_students_4 integer NOT NULL DEFAULT 0,
  impact_students_5 integer NOT NULL DEFAULT 0,
  impact_students_6 integer NOT NULL DEFAULT 0,
  impact_students_7 integer NOT NULL DEFAULT 0,
  impact_students_8 integer NOT NULL DEFAULT 0,
  impact_students_9 integer NOT NULL DEFAULT 0,
  impact_students_10 integer NOT NULL DEFAULT 0,
  impact_students_11 integer NOT NULL DEFAULT 0,
  impact_students_12 integer NOT NULL DEFAULT 0,
  impact_students_undergraduate integer NOT NULL DEFAULT 0,
  impact_students_graduate integer NOT NULL DEFAULT 0,
  impact_students_out_of_school integer NOT NULL DEFAULT 0,
  impact_teachers_in_district integer NOT NULL DEFAULT 0,
  impact_students_in_district integer NOT NULL DEFAULT 0,
  impact_reduced_lunch integer NOT NULL DEFAULT 0,
  impact_students_total integer NOT NULL DEFAULT 0,
  fiscal_year bpchar,
  source_id integer,
  created_by_user text,
  modified_by_user text,
  CONSTRAINT impact_pkey PRIMARY KEY (impact_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE _report.impact
  OWNER TO admin;
GRANT ALL ON TABLE _report.impact TO xtrole;
GRANT SELECT ON TABLE _report.impact TO public;
REVOKE ALL ON TABLE _report.impact FROM admin;
COMMENT ON TABLE _report.impact
  IS 'Impact - who is using the ASSET program';

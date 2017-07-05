-- Sequence: _report.impact_comment_id_seq

DROP SEQUENCE IF EXISTS _report.impact_comment_id_seq CASCADE;

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

-- Table: _report.impact_comment

DROP TABLE IF EXISTS _report.impact_comment CASCADE;

CREATE TABLE _report.impact_comment
(
  impact_comment_id integer NOT NULL DEFAULT nextval('_report.impact_comment_id_seq'::regclass),
  impact_comment_impact_id integer NOT NULL,
  impact_comment_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
  impact_comment_user text NOT NULL DEFAULT "current_user"(),
  impact_comment_comment text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE _report.impact_comment
  OWNER TO admin;
GRANT SELECT ON TABLE _report.impact_comment TO public;
GRANT ALL ON TABLE _report.impact_comment TO xtrole;
COMMENT ON TABLE _report.impact_comment
  IS '20150428:rek Orbit 881';

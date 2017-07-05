-- Table: _report.impact_comment

-- DROP TABLE _report.impact_comment;

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

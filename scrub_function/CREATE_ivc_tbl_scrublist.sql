-- Table: ivc.scrublist

-- DROP TABLE ivc.scrublist;

CREATE TABLE ivc.scrublist
(
  scrublist_id serial NOT NULL,
  schema text,
  tablename text,
  tablepkey text,
  field text,
  CONSTRAINT scrublist_pkey PRIMARY KEY (scrublist_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ivc.scrublist
  OWNER TO admin;
GRANT ALL ON TABLE ivc.scrublist TO admin;
GRANT ALL ON TABLE ivc.scrublist TO xtrole;
GRANT ALL ON TABLE ivc.scrublist TO public;
COMMENT ON TABLE ivc.scrublist
  IS 'list of fields to remove leading/trailing spaces, /n,tab';

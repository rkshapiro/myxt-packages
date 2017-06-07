-- Table: scrublist

DROP TABLE IF EXISTS scrublist;

CREATE TABLE scrublist
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
ALTER TABLE scrublist
  OWNER TO admin;
GRANT ALL ON TABLE scrublist TO admin;
GRANT ALL ON TABLE scrublist TO xtrole;
GRANT ALL ON TABLE scrublist TO public;
COMMENT ON TABLE scrublist
  IS 'list of fields to remove leading/trailing spaces, /n,tab';

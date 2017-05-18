-- Table: itemupdate

-- DROP TABLE itemupdate;

CREATE TABLE itemupdate
(
  itemupdate_id serial NOT NULL,
  itemupdate_number text,
  itemupdate_descrip1 text,
  itemupdate_descrip2 text,
  itemupdate_maxcost numeric(16,6),
  itemupdate_classcode_code text,
  itemupdate_sold text,
  itemupdate_prodcat_code text,
  itemupdate_listprice numeric(16,4),
  itemupdate_listcost numeric(16,4),
  itemupdate_prodweight numeric(16,2),
  itemupdate_packweight numeric(16,2),
  itemupdate_comments text,
  itemupdate_extdescrip text,
  itemupdate_lastupdated timestamp with time zone DEFAULT now(),
  CONSTRAINT itemupdate_pkey PRIMARY KEY (itemupdate_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE itemupdate
  OWNER TO admin;
GRANT ALL ON TABLE itemupdate TO admin;
GRANT ALL ON TABLE itemupdate TO xtrole;
COMMENT ON TABLE itemupdate
  IS 'itemupdate update temp table';

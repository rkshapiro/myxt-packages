-- Table: itemcharupdate

DROP TABLE IF EXISTS itemcharupdate;

CREATE TABLE itemcharupdate
(
  itemcharupdate_id serial NOT NULL,
itemnumber TEXT,
description TEXT,
classcode TEXT,
uom TEXT,
eccn TEXT,
exportban TEXT,
origin TEXT,
stcode TEXT,
tariffcode TEXT,
xreviewed TEXT, 
  CONSTRAINT itemcharupdate_pkey PRIMARY KEY (itemcharupdate_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE itemcharupdate OWNER TO "admin";
GRANT ALL ON TABLE itemcharupdate TO "admin";
GRANT ALL ON TABLE itemcharupdate TO xtrole;

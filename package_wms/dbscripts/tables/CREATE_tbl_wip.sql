-- Table:  wip

-- DROP TABLE  wip;

CREATE TABLE  wip
(
  run_date date,
  sales_order text,
  item_number text,
  item_description text,
  class_code text,
  onhand_qty integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE  wip OWNER TO admin;
GRANT ALL ON TABLE  wip TO xtrole;
GRANT SELECT ON TABLE  wip TO public;
COMMENT ON TABLE  wip IS '20150130:rek Orbit 803 Staging table for WIP exported file from SSRS';

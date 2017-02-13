-- Table:  invimport

-- DROP TABLE  invimport;

CREATE TABLE  invimport
(
  invimport_location text,
  invimport_sku text,
  invimport_uom_desc text,
  invimport_qty numeric(18,6),
  invimport_site_id text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE  invimport OWNER TO "admin";
COMMENT ON TABLE  invimport IS 'A temporary table for uploading physical inventory to xTuple from Oracle. Part of WIP RAID Log #51: "Physical Inventory Import" ';

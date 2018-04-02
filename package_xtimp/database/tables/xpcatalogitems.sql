DROP TABLE IF EXISTS xtimp.xpcatalogitems;
-- Create xtimp catalog group table for catalog group imports
CREATE TABLE xtimp.xpcatalogitems
(xpcatalogitems_id  SERIAL NOT NULL,
xpcatalogitems_itemnumber text,
xpcatalogitems_groupname text,
xpcatalogitems_checked boolean NOT NULL DEFAULT FALSE,
xpcatalogitems_imported boolean NOT NULL DEFAULT FALSE,
xpcatalogitems_import_error text,
CONSTRAINT xpcatalogitems_pkey PRIMARY KEY (xpcatalogitems_id)
);
ALTER TABLE xtimp.xpcatalogitems OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpcatalogitems TO "admin";
GRANT ALL ON TABLE xtimp.xpcatalogitems TO xtrole;
GRANT ALL ON SEQUENCE xtimp.xpcatalogitems_xpcatalogitems_id_seq TO xtrole;

COMMENT ON TABLE xtimp.xpcatalogitems IS 'xtimp XP Catalog Group Import Table';
   
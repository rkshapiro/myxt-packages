DROP TABLE IF EXISTS xtimp.xpcataloggroup;
-- Create xtimp catalog group table for catalog group imports
CREATE TABLE xtimp.xpcataloggroup
(xpcataloggroup_id  SERIAL NOT NULL,
xpcataloggroup_groupitemname text,
xpcataloggroup_parentgroupname text,
xpcataloggroup_checked boolean NOT NULL DEFAULT FALSE,
xpcataloggroup_imported boolean NOT NULL DEFAULT FALSE,
xpcataloggroup_import_error text,
CONSTRAINT xpcataloggroup_pkey PRIMARY KEY (xpcataloggroup_id)
);
ALTER TABLE xtimp.xpcataloggroup OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpcataloggroup TO "admin";
GRANT ALL ON TABLE xtimp.xpcataloggroup TO xtrole;
GRANT ALL ON SEQUENCE xtimp.xpcataloggroup_xpcataloggroup_id_seq TO xtrole;

COMMENT ON TABLE xtimp.xpcataloggroup IS 'xtimp XP Catalog Group Import Table';
   
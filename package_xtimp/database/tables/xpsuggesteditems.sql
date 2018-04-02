DROP TABLE IF EXISTS xtimp.xpsuggesteditems;
-- Create xtimp Suggested Item Table for xTC imports
CREATE TABLE xtimp.xpsuggesteditems
(xpsuggesteditems_id  SERIAL NOT NULL,
xpsuggesteditems_itemnumber text,
xpsuggesteditems_sugesteditemnumber text,
xpsuggesteditems_reason text,
xpsuggesteditems_quantity text,
xpsuggesteditems_mandatory text,
xpsuggesteditems_checked boolean NOT NULL DEFAULT FALSE,
xpsuggesteditems_imported boolean NOT NULL DEFAULT FALSE,
xpsuggesteditems_import_error text,
CONSTRAINT xpsuggesteditems_pkey PRIMARY KEY (xpsuggesteditems_id)
);
ALTER TABLE xtimp.xpsuggesteditems OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpsuggesteditems TO "admin";
GRANT ALL ON TABLE xtimp.xpsuggesteditems TO xtrole;
GRANT ALL ON SEQUENCE xtimp.xpsuggesteditems_xpsuggesteditems_id_seq TO xtrole;

COMMENT ON TABLE xtimp.xpsuggesteditems IS 'xtimp XP Suggested Item Import Table';
   
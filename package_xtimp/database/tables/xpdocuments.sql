DROP TABLE IF EXISTS xtimp.xpdocuments;
-- Create xtimp Item Table for Item imports
CREATE TABLE xtimp.xpdocuments
(xpdocuments_id  SERIAL NOT NULL,
xpdocuments_itemnumber text,
xpdocuments_documentname text,
xpdocuments_url text,
xpdocuments_weight text,
xpdocuments_published text,
xpdocuments_checked boolean NOT NULL DEFAULT FALSE,
xpdocuments_imported boolean NOT NULL DEFAULT FALSE,
xpdocuments_import_error text,
CONSTRAINT xpdocuments_pkey PRIMARY KEY (xpdocuments_id)
);
ALTER TABLE xtimp.xpdocuments OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpdocuments TO "admin";
GRANT ALL ON TABLE xtimp.xpdocuments TO xtrole;
GRANT ALL ON SEQUENCE xtimp.xpdocuments_xpdocuments_id_seq TO xtrole;

COMMENT ON TABLE xtimp.xpdocuments IS 'xtimp XP Item Import Table';
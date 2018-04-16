-- Table: xtimp.xpstdjrnl

DROP TABLE IF EXISTS  xtimp.xpstdjrnl;

CREATE TABLE xtimp.xpstdjrnl
(
  xpstdjrnl_id text NOT NULL DEFAULT nextval(('xtimp.xpstdjrnl_xpstdjrnl_id_seq'::text)::regclass),
  xpstdjrnl_name text,
  xpstdjrnl_descrip text,
  xpstdjrnl_journal_notes text,
  xpstdjrnl_account text,
  xpstdjrnl_debit text,
  xpstdjrnl_credit text,
  xpstdjrnl_entry_notes text,
  xpstdjrnl_import_user text,
  xpstdjrnl_import_date text,
  CONSTRAINT xpstdjrnl_pkey PRIMARY KEY (xpstdjrnl_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE xtimp.xpstdjrnl OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpstdjrnl TO "admin";
GRANT ALL ON TABLE xtimp.xpstdjrnl TO xtrole;
COMMENT ON TABLE xtimp.xpstdjrnl IS 'xtimp Journal Import Table for trial balance';


-- Sequence: xtimp.xpstdjrnl_xpstdjrnl_id_seq

CREATE SEQUENCE xtimp.xpstdjrnl_xpstdjrnl_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 205
  CACHE 1;
ALTER TABLE xtimp.xpstdjrnl_xpstdjrnl_id_seq OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpstdjrnl_xpstdjrnl_id_seq TO "admin";
GRANT ALL ON TABLE xtimp.xpstdjrnl_xpstdjrnl_id_seq TO xtrole;



   

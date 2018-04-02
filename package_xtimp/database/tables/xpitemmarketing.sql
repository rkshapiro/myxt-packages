DROP TABLE IF EXISTS xtimp.xpitemmarketing;
-- Create xtimp Item Table for Item imports
CREATE TABLE xtimp.xpitemmarketing
(xpitemmarketing_id  SERIAL NOT NULL,
xpitemmarketing_itemnumber text,
xpitemmarketing_title text,
xpitemmarketing_subtitle text,
xpitemmarketing_teaser text,
xpitemmarketing_description text,
xpitemmarketing_seokeywords text,
xpitemmarketing_seotitle text,
xpitemmarketing_checked boolean NOT NULL DEFAULT FALSE,
xpitemmarketing_imported boolean NOT NULL DEFAULT FALSE,
xpitemmarketing_import_error text,
CONSTRAINT xpitemmarketing_pkey PRIMARY KEY (xpitemmarketing_id)
);
ALTER TABLE xtimp.xpitemmarketing OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpitemmarketing TO "admin";
GRANT ALL ON TABLE xtimp.xpitemmarketing TO xtrole;
GRANT ALL ON SEQUENCE xtimp.xpitemmarketing_xpitemmarketing_id_seq TO xtrole;

COMMENT ON TABLE xtimp.xpitemmarketing IS 'xtimp XP Item Import Table';
   
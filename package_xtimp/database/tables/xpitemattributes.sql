DROP TABLE IF EXISTS xtimp.xpitemattributes;
-- Create xtimp Item Table for Item imports NOT USED
CREATE TABLE xtimp.xpitemattributes
(xpitemattributes_id  SERIAL NOT NULL,
xpitemattributes_itemnumber text,
xpitemattributes_publishtowebsite text,
xpitemattributes_publicviewexclusive text,
xpitemattributes_productlength text,
xpitemattributes_productwidth text,
xpitemattributes_productheight text,
xpitemattributes_productuom text,
xpitemattributes_packagelength text,
xpitemattributes_packagewidth text,
xpitemattributes_packageheight text,
xpitemattributes_packageuom text,
xpitemattributes_shipseparately text,
xpitemattributes_requirefreightinsurance text,
xpitemattributes_insuranceamount text,
xpitemattributes_amountbasis text,
xpitemattributes_additionalfreightfee text,
xpitemattributes_addfreightbasis text,
xpitemattributes_acceptbackorders text,
xpitemattributes_backordermessage text,
xpitemattributes_quotefreightbyvolume text,
xpitemattributes_checked boolean NOT NULL DEFAULT FALSE,
xpitemattributes_imported boolean NOT NULL DEFAULT FALSE,
xpitemattributes_import_error text,
CONSTRAINT xpitemattributes_pkey PRIMARY KEY (xpitemattributes_id)
);
ALTER TABLE xtimp.xpitemattributes OWNER TO "admin";
GRANT ALL ON TABLE xtimp.xpitemattributes TO "admin";
GRANT ALL ON TABLE xtimp.xpitemattributes TO xtrole;
GRANT ALL ON SEQUENCE xtimp.xpitemattributes_xpitemattributes_id_seq TO xtrole;

COMMENT ON TABLE xtimp.xpitemattributes IS 'xtimp XP Item Attributes Import Table';
   
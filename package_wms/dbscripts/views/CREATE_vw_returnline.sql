-- View:  returnline

-- DROP VIEW  returnline;

CREATE OR REPLACE VIEW  returnline AS 
 SELECT returnline._ra_number, returnline._raline_number, returnline._raline_subnumber, returnline._raline_status, returnline._raline_item_number, returnline._raline_uom, returnline._so_number, returnline._soline_number, returnline._soline_subnumber, returnline._soline_item_number, returnline._soline_shipped_qty, returnline._warehouse_code
   FROM  _wms.returnline('2013-06-30'::date) returnline(_ra_number, _raline_number, _raline_subnumber, _raline_status, _raline_item_number, _raline_uom, _so_number, _soline_number, _soline_subnumber, _soline_item_number, _soline_shipped_qty, _warehouse_code);

-- 20140310:jjb added _warehouse_code as a parameter

ALTER TABLE  returnline OWNER TO "admin";
GRANT ALL ON TABLE  returnline TO "admin";
GRANT SELECT ON TABLE  returnline TO public;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE  returnline TO xtrole;
COMMENT ON VIEW  returnline IS 'used by WMS for leased return processing';


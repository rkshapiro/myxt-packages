-- delete old schema objects
DROP VIEW IF EXISTS _wms.coitem_raitem;
DROP VIEW IF EXISTS _wms.purchaseorderline;
DROP VIEW IF EXISTS _wms.returnline;
DROP VIEW IF EXISTS _wms.salesorder_open;
DROP VIEW IF EXISTS _wms.shipstatus;
DROP VIEW IF EXISTS _wms.v_item;

DROP FUNCTION IF EXISTS _wms.getwaveitems(integer);
DROP FUNCTION IF EXISTS _wms.importinventory();
DROP FUNCTION IF EXISTS _wms.insertwavebatch(character varying, character varying, integer, character varying, integer);
DROP FUNCTION IF EXISTS _wms.insertwavebatch(character varying, character varying, integer, character varying);
DROP FUNCTION IF EXISTS _wms.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer, integer);
DROP FUNCTION IF EXISTS _wms.inventoryadjustment(character varying, character varying, character varying, numeric, character varying, character varying, character varying, integer);
DROP FUNCTION IF EXISTS _wms.issuesalesline(integer, integer, character varying, numeric, character varying, character varying, character varying, integer);
DROP FUNCTION IF EXISTS _wms.itemcomponent(character varying);
DROP FUNCTION IF EXISTS _wms.purchasereceipt(character varying, integer, character varying, character varying, numeric, character varying, character varying);
DROP FUNCTION IF EXISTS _wms.returnline(date);
DROP FUNCTION IF EXISTS _wms.returnreceipt(character varying, integer, integer, character varying, character varying, numeric, character varying, character varying);
DROP FUNCTION IF EXISTS _wms.scrapadjustment(character varying, character varying, numeric, character varying, character varying, character varying);


DROP TABLE IF EXISTS _wms.invimport;
DROP TABLE IF EXISTS _wms.wavebatch;
DROP TABLE IF EXISTS _wms.wip;

DROP SEQUENCE IF EXISTS _wms.wavebatch_wavebatch_id_seq;

DROP TYPE IF EXISTS _wms.orderitems;


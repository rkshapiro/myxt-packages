-- remove objects from _asset schema

DELETE FROM metasql 
WHERE metasql_group = 'AAA_ASSET'
AND metasql_name IN (
'Create RA for SO',
'delivery_return_notification',
'detail_logistics',
'logistics_report',
'QRY_returns_summary_report',
'RA_detail',
'returns_list',
'Run_durable_planned_order_returns'
'SET_returndate',
'SET_returndate_fix',
'SET_salesline_return_date'
);

DELETE FROM report
WHERE report_name IN (
'DeliveryReturnNotification',
'Logistics',
'Returns_By_Item',
'Return_List',
'ReturnAging',
'CustOrderAcknowledgement',
'CustomerOrders'
);

DELETE FROM uiform
WHERE uiform_name IN (
'Logistics',
'newReturndate',
'ReturnsByItem',
'ReturnsList'
);

DELETE FROM script
WHERE script_name IN (
'Logistics',
'newReturndate',
'ReturnsByItem',
'ReturnsList'
);

DELETE FROM cmdarg
WHERE cmdarg_cmd_id IN (
SELECT cmd_id
FROM cmd
WHERE cmd_privname IN (
'DeliveryReturnNotification',
'ReturnAgingReport',
'ABoxMaterialsListReport',
'CustomerOrderHistory',
'Logistics',
'newReturndate',
'ReturnsByItem',
'ReturnsList')
);

DELETE FROM cmd
WHERE cmd_privname IN (
'DeliveryReturnNotification',
'ReturnAgingReport',
'ABoxMaterialsListReport',
'CustomerOrderHistory',
'Logistics',
'newReturndate',
'ReturnsByItem',
'ReturnsList');

DROP VIEW IF EXISTS _asset.vw_logistics;
DROP VIEW IF EXISTS _asset.coitem_raitem;
DROP VIEW IF EXISTS _asset.coitem_raitem_old;
DROP VIEW IF EXISTS _asset.salesline_rental_period;
DROP VIEW IF EXISTS _asset.returns_list;
DROP VIEW IF EXISTS _asset.salesline_return_date;
DROP VIEW IF EXISTS _asset.salesline_return_date_override;
DROP VIEW IF EXISTS _asset.order_history;

DROP FUNCTION IF EXISTS _asset.createraforso(integer);
DROP FUNCTION IF EXISTS _asset.getitemreturns(text, date);
DROP FUNCTION IF EXISTS _asset.getreturndate(integer, date);
DROP FUNCTION IF EXISTS _asset.getreturndate(text, date);
DROP FUNCTION IF EXISTS _asset.islastcomment(integer, text, text);
DROP FUNCTION IF EXISTS _asset.returnaging(date);
DROP FUNCTION IF EXISTS _asset.reverse_bom(text);
DROP FUNCTION IF EXISTS _asset.setreturndate(integer);
DROP FUNCTION IF EXISTS _asset.durable_planned_order_returns();


DROP TRIGGER IF EXISTS soheadaftertrigger_asset ON cohead;
DROP FUNCTION IF EXISTS _asset._soheadaftertrigger_asset();
DROP TRIGGER IF EXISTS soitemaftertrigger_asset ON coitem;
DROP FUNCTION IF EXISTS _asset._soitemaftertrigger_asset();

DROP TYPE IF EXISTS _asset.return_items_list;
DROP TYPE IF EXISTS public.returnaging;

DROP TABLE IF EXISTS _asset.durable_planord_return_items_list;
DROP TABLE IF EXISTS _asset.matlistcomment;
DROP TABLE IF EXISTS _asset.priority_return_items_list;

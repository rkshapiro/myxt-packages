-- drop objects that were moved from the old location
DELETE FROM metasql 
WHERE metasql_group = 'AAA_ASSET'
AND metasql_name IN (
'SO Events',
'QRY_SOMissingFreight',
'run_returns_analysis_list',
'PDStatement',
'deferredRevenueSummary',
'deferredRevenueDetail',
'ProductItemGroupPricing',
'product_family_price'
'ProductItemPricing'
);

DELETE FROM report
WHERE report_name IN (
'AAA_PDF_Customer_Profile',
'PDStatement',
'ProductFamilyPrices',
'ProductItemFamilyPricingReport',
'ProductItemPricingReport'
);

DELETE FROM uiform
WHERE uiform_name IN (
'DeferredRevenueDetail',
'DeferredRevenueSummary',
'PrepaidPDStatement',
'Impact',
'Impact_Student',
'Impact_Student_Comment',
'Impact_Teacher',
'Impact_Teacher_Comment',
'ProductFamily_Price',
'ProductItemPricing'
);

DELETE FROM script
WHERE script_name IN (
'DeferredRevenueDetail',
'DeferredRevenueSummary',
'Impact',
'Impact_Student',
'Impact_Student_Comment',
'Impact_Teacher',
'Impact_Teacher_Comment',
'PrepaidPDStatement',
'ProductFamily_Price',
'ProductItemPricing'
);

DELETE FROM cmdarg
WHERE cmdarg_cmd_id IN (
SELECT cmd_id
FROM cmd
WHERE cmd_privname IN (
'Impact_Data',
'AAA_PDF_Customer_Profile',
'ProductFamilyPricing',
'CustomerPrepaidBalance',
'DeferredRevenueSummary',
'DeferredRevenueDetail',
'ProductFamilyPricingSheet',
'ProductItemPricingForm')
);

DELETE FROM cmd
WHERE cmd_privname IN (
'Impact_Data',
'AAA_PDF_Customer_Profile',
'ProductFamilyPricing',
'CustomerPrepaidBalance',
'DeferredRevenueSummary',
'DeferredRevenueDetail',
'ProductFamilyPricingSheet',
'ProductItemPricingForm');

DROP VIEW IF EXISTS _asset.sales_trend;
DROP VIEW IF EXISTS _asset.quote_revenue;
DROP VIEW IF EXISTS _asset.contact_list;
DROP FUNCTION IF EXISTS _asset.isfinalsale(integer) CASCADE;
DROP FUNCTION IF EXISTS _asset.getschoolyear(date) CASCADE;
DROP FUNCTION IF EXISTS _asset.monthly_cogs(character varying, character varying);
DROP FUNCTION IF EXISTS _asset.getpriorrevid(text, integer, date) CASCADE;
DROP TABLE IF EXISTS _cpo.impact CASCADE;
DROP TABLE IF EXISTS _cpo.impact_comment CASCADE;
DROP TABLE IF EXISTS _cpo.impact_teacher CASCADE;
DROP TABLE IF EXISTS _cpo.impact_teacher_comment CASCADE;
DROP TABLE IF EXISTS _cpo.impactteacher CASCADE;
DROP SEQUENCE IF EXISTS _cpo.impact_comment_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impact_impact_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impact_teacher_comment_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impact_teacher_impactteacher_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impactteacher_impactteacher_id_seq;

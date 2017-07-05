-- drop objects that were moved from the old location
DROP VIEW IF EXISTS _asset.sales_trend;
DROP VIEW IF EXISTS _asset.quote_revenue;
DROP VIEW IF EXISTS _asset.contact_list;
DROP FUNCTION IF EXISTS _asset.isfinalsale(integer) CASCADE;
DROP FUNCTION IF EXISTS _asset.getschoolyear(date) CASCADE;
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

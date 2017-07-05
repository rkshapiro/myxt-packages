-- drop objects that were moved from the old location
DROP VIEW IF EXISTS _asset.sales_trend;
DROP VIEW IF EXISTS _asset.quote_revenue;
DROP VIEW IF EXISTS _asset.contact_list;
DROP FUNCTION IF EXISTS _asset.isfinalsale;
DROP FUNCTION IF EXISTS _asset.getschoolyear;
DROP SEQUENCE IF EXISTS _cpo.impact_comment_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impact_impact_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impact_teacher_comment_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impact_teacher_impactteacher_id_seq;
DROP SEQUENCE IF EXISTS _cpo.impactteacher_impactteacher_id_seq;
DROP TABLE IF EXISTS _cpo.impact;
DROP TABLE IF EXISTS _cpo.impact_comment;
DROP TABLE IF EXISTS _cpo.impact_teacher;
DROP TABLE IF EXISTS _cpo.impact_teacher_comment;
DROP TABLE IF EXISTS _cpo.impactteacher;
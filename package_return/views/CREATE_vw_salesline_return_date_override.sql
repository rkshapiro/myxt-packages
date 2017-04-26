-- View: salesline_return_date_override

-- DROP VIEW salesline_return_date_override;

CREATE OR REPLACE VIEW salesline_return_date_override AS 
SELECT comment.comment_source_id AS comment_coitem_id, comment.comment_text::date AS override_date
FROM comment
JOIN coitem on comment_source_id = coitem_id
JOIN cohead on coitem_cohead_id = cohead_id
WHERE comment_id = _return.islastcomment(coitem_id,'SI','RETURN DATE Override')
AND cohead_orderdate > '6/30/2012';

ALTER TABLE salesline_return_date_override OWNER TO mfgadmin;
GRANT ALL ON TABLE salesline_return_date_override TO mfgadmin;
GRANT ALL ON TABLE salesline_return_date_override TO xtrole;
COMMENT ON VIEW salesline_return_date_override IS 'used by auto-return authorization process';


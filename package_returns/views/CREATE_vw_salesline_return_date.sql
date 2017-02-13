-- View: salesline_return_date

-- DROP VIEW salesline_return_date;

CREATE OR REPLACE VIEW salesline_return_date AS 
-- 20140416:rks modified to use scheddate when promdate is 2100-01-01
 SELECT charass.charass_target_id AS salesline_coitem_id, charass.charass_value::date AS return_date, item.item_number, cohead.cohead_number AS order_number, 
	CASE
	WHEN coitem.coitem_promdate = '2100-01-01' THEN coitem.coitem_scheddate
	ELSE
	COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate) 
	END AS delivery_date
   FROM charass
   JOIN "char" ON charass.charass_char_id = "char".char_id
   JOIN coitem ON charass.charass_target_id = coitem.coitem_id
   JOIN itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
   JOIN item ON itemsite.itemsite_item_id = item.item_id
   JOIN cohead ON coitem.coitem_cohead_id = cohead.cohead_id
  WHERE "char".char_name = 'RETURN DATE'::text AND charass.charass_target_type = 'SI'::text;

ALTER TABLE salesline_return_date OWNER TO mfgadmin;
GRANT ALL ON TABLE salesline_return_date TO mfgadmin;
GRANT ALL ON TABLE salesline_return_date TO xtrole;
COMMENT ON VIEW salesline_return_date IS 'used by auto-return authorization process';


-- View: _report.return_analysis

-- DROP VIEW _report.return_analysis;

CREATE OR REPLACE VIEW _report.return_analysis AS 
SELECT 
	cohead.cohead_number, 
	item.item_number, 
	item.item_descrip1, 
	lx1.count AS leaseextension, 
	lx2.count AS rdo, 
	custinfo.cust_number, 
	custinfo.cust_name, 
	CASE
		WHEN coitem.coitem_promdate = '2100-01-01' THEN coitem.coitem_scheddate
	ELSE
		COALESCE(coitem.coitem_promdate, coitem.coitem_scheddate) 
	END as deliverydate, 
	coitem.coitem_qtyord, 
	shipitem.shipitem_transdate AS shipdate, 
	coitem.coitem_qtyshipped, 
	rahist.recv_date, 
	rahist.recv_qty, 
	charass.charass_value AS charass_returndate, 
	charass1.charass_value AS rental_period, 
	rahist.recv_date::date - charass.charass_value::date  AS returndiffdays, 
	(rahist.recv_date - charass.charass_value::date)::numeric / 7  AS returndiffweeks,
	rahead.rahead_warehous_id,
	cohead.cohead_custponumber,
	rahead.rahead_number,
	_report.getschoolyear(charass.charass_value::Date) AS schoolYear,
	prj.prj_number
	
FROM 
( 
	SELECT 
		rahist.rahist_rahead_id, 
		rahist.rahist_itemsite_id, 
		sum(rahist.rahist_qty) AS recv_qty, 
		max(rahist.rahist_date) AS recv_date
	FROM rahist
	WHERE rahist.rahist_itemsite_id IS NOT NULL
	GROUP BY rahist.rahist_rahead_id, rahist.rahist_itemsite_id) rahist
	
JOIN rahead ON rahead.rahead_id = rahist.rahist_rahead_id

JOIN cohead ON COALESCE(rahead.rahead_new_cohead_id, rahead.rahead_orig_cohead_id) = cohead.cohead_id	

JOIN custinfo ON cohead.cohead_cust_id = custinfo.cust_id

JOIN itemsite ON rahist.rahist_itemsite_id = itemsite.itemsite_id

JOIN item ON itemsite.itemsite_item_id = item.item_id

LEFT JOIN 
( 
	SELECT 
		cohead.cohead_id, 
		substr(item.item_number, 1, length(item.item_number) - 2) AS item_number, 
		count(*) AS count
	FROM cohead
	JOIN coitem ON cohead.cohead_id = coitem.coitem_cohead_id
	JOIN itemsite ON coitem.coitem_itemsite_id = itemsite.itemsite_id
	JOIN item ON itemsite.itemsite_item_id = item.item_id
	WHERE item.item_number ~ 'LX'::text
	GROUP BY 
		cohead.cohead_id, 
		substr(item.item_number, 1, length(item.item_number) - 2)
) lx1 ON cohead.cohead_id = lx1.cohead_id 
	AND lx1.item_number = substr(item.item_number, 1, length(item.item_number) - 2)

JOIN raitem ON raitem.raitem_rahead_id = rahead.rahead_id AND raitem.raitem_itemsite_id = itemsite.itemsite_id

JOIN coitem ON COALESCE(raitem.raitem_new_coitem_id, raitem.raitem_orig_coitem_id) = coitem.coitem_id

LEFT JOIN 
( 
	SELECT 
		comment.comment_source_id, 
		count(DISTINCT comment_text) AS count
	FROM comment
	JOIN cmnttype ON comment.comment_cmnttype_id = cmnttype.cmnttype_id
	WHERE cmnttype.cmnttype_name = 'RETURN DATE Override'::text
	GROUP BY comment.comment_source_id
) lx2 ON lx2.comment_source_id = coitem.coitem_id

JOIN 
( 
	SELECT 
		shipitem.shipitem_orderitem_id, 
		sum(shipitem.shipitem_qty) AS shipitem_qty, 
		max(shipitem.shipitem_transdate::date) AS shipitem_transdate
	FROM shipitem
	GROUP BY shipitem.shipitem_orderitem_id
) shipitem ON shipitem.shipitem_orderitem_id = coitem.coitem_id

JOIN charass ON charass.charass_target_id = coitem.coitem_id

JOIN "char" ON charass.charass_char_id = "char".char_id

JOIN charass charass1 ON charass1.charass_target_id = coitem.coitem_id

JOIN "char" char1 ON charass1.charass_char_id = char1.char_id

JOIN public.prj ON cohead.cohead_prj_id = prj.prj_id

WHERE 
	rahist.recv_date > '2012-07-01'::date AND 
	charass.charass_target_type = 'SI'::text AND 
	"char".char_name = 'RETURN DATE'::text 
	AND char1.char_name = 'RENTAL PERIOD'::text
	AND rahead.rahead_warehous_id = 49
	AND cohead.cohead_custponumber <> 'INVALID';


ALTER TABLE _report.return_analysis OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.return_analysis TO mfgadmin;
GRANT ALL ON TABLE _report.return_analysis TO xtrole;
COMMENT ON VIEW _report.return_analysis IS 'used by return analysis report. orbit 659';


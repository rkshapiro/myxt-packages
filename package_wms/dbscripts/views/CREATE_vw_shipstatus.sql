-- View:  shipstatus

-- DROP VIEW  shipstatus;

CREATE OR REPLACE VIEW  shipstatus AS 

-- 20140418:jjb Made it so that it checks if qtyshipped = 0 per DMLogic's request as well as joining shipitem
-- 20140414:jjb Made it so that it only pulls back distinct combinations of whether something was shipped or not per Albie's request
--              (returns date if something on a SO was shipped and NULL if there are outstanding items)
-- 20150407:rek change for parital orders coitem_qtyshipped < coitem_qtyord

SELECT DISTINCT cohead_number::character varying(255) AS _so_number, 
	CASE WHEN ((coitem_status='O') AND (coitem.coitem_qtyshipped < coitem.coitem_qtyord)) THEN NULL
		ELSE shiphead_shipdate
	END AS  _so_shipped_date
FROM public.coitem
JOIN public.cohead ON coitem_cohead_id=cohead_id
LEFT JOIN public.shiphead ON cohead.cohead_id=shiphead.shiphead_order_id
JOIN public.shipitem on shiphead.shiphead_id = shipitem.shipitem_shiphead_id and coitem.coitem_id = shipitem_orderitem_id
WHERE (coitem_status<>'X')
ORDER BY _so_number, _so_shipped_date DESC;

ALTER TABLE  shipstatus OWNER TO "admin";
GRANT ALL ON TABLE  shipstatus TO "admin";
GRANT SELECT ON TABLE  shipstatus TO public;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE  shipstatus TO xtrole;
COMMENT ON VIEW  shipstatus IS 'used by WMS for order management';


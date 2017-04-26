-- Table:  priority_return_items_list

DROP TABLE IF EXISTS priority_return_items_list CASCADE;

CREATE TABLE  priority_return_items_list
(
  planord_duedate date,
  return_authorization text,
  return_date date,
  cust_number text,
  cust_name text,
  child_item_id integer,
  child_number text,
  child_desc text,
  parent_item_id integer,
  parent_number text,
  parent_desc text,
  kit_returns integer,
  item_returns integer,
  index integer,
  xtindentrole integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE  priority_return_items_list
  OWNER TO admin;
COMMENT ON TABLE  priority_return_items_list
  IS ' 20150223:rek Orbit 830';
  
-- Function:  priority_returns()

-- DROP FUNCTION  priority_returns();

CREATE OR REPLACE FUNCTION  priority_returns()
  RETURNS SETOF priority_return_items_list AS
$BODY$
DECLARE _x Record;
DECLARE _r Record;

BEGIN

TRUNCATE TABLE  _return.priority_return_items_list;

FOR _r IN
	SELECT 
		child_item_id,
		child_number,
		child_desc,
		planord_duedate,
		planord_reqd_qty
	FROM  _return.durable_planord_return_items_list

LOOP

	FOR _x IN
	SELECT
	_r.planord_duedate,
	ret.authorization_number::text as ra_number,
	ret.return_date,	
	ret.cust_number::text,
	ret.cust_name,
	_r.child_item_id,
	_r.child_number,
	_r.child_desc,
	it.child_item_id as parent_id,
	it.parent_number,
	it.parent_desc,
	(ret.raitem_qtyauthorized - ret.raitem_qtyreceived) ::integer as kit_return,
	(ret.raitem_qtyauthorized - ret.raitem_qtyreceived) * COALESCE(rt.bomitem_qtyper,it.bomitem_qtyper)  ::integer as total_item_return,
	_r.planord_reqd_qty::integer,
	0::integer
	FROM  _return.getitemreturns(_r.child_number,_r.planord_duedate) it
	LEFT JOIN  _return.getitemreturns(_r.child_number,_r.planord_duedate) rt ON rt.child_item_id = it.parent_item_id AND rt.item_classcode_id = 113
	JOIN public.item item on it.parent_item_id = item.item_id  
	JOIN public.classcode cc ON item.item_classcode_id = cc.classcode_id
	
	JOIN
	(
		SELECT trunc_index, MAX(index) as max_index
		FROM
		(
			SELECT 
				trunc(index,CASE xtindentrole WHEN 0 THEN 0 ELSE xtindentrole-1 END ) as trunc_index , index
			FROM  _return.getitemreturns(_r.child_number,_r.planord_duedate) it
			WHERE qty_ret > 0  and item_classcode_id = 113
		) ind
		GROUP BY trunc_index
	) mindex ON mindex.max_index = it.index

	JOIN  _return.returns_list ret ON ret.item_number = it.parent_number
			AND ret.return_date <= _r.planord_duedate 
			AND ret.return_date >= current_date - 30
	WHERE it.qty_ret > 0 AND it.item_classcode_id = 113
	ORDER BY ret.authorization_number

	LOOP
		INSERT INTO _return.priority_return_items_list
		VALUES
		(
			_r.planord_duedate,
			_x.ra_number,
			_x.return_date,
			_x.cust_number,
			_x.cust_name,
			_r.child_item_id,
			_r.child_number,
			_r.child_desc,
			_x.parent_id,
			_x.parent_number,
			_x.parent_desc,
			_x.kit_return,
			_x.total_item_return,
			_r.planord_reqd_qty,
			0
		);
		
		RETURN NEXT _x;
	END LOOP;
END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
  ALTER FUNCTION  priority_returns()
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION  priority_returns() TO admin;
GRANT EXECUTE ON FUNCTION  priority_returns() TO public;

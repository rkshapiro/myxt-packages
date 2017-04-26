-- Table: durable_planord_return_items_list

DROP TABLE IF EXISTS durable_planord_return_items_list CASCADE;

CREATE TABLE durable_planord_return_items_list
(
  parent_item_id integer,
  parent_item_number text,
  parent_descript text,
  child_item_id integer,
  uom_descrip text,
  item_type character(1),
  item_classcode text,
  child_number text,
  child_desc text,
  qty_ret bigint,
  planord_duedate date,
  planord_reqd_qty bigint,
  xtindentrole integer,
  jindex numeric,
  iindex integer,
  grp integer,
  return_date date
)
WITH (
  OIDS=FALSE
);
ALTER TABLE durable_planord_return_items_list
  OWNER TO admin;
GRANT ALL ON TABLE durable_planord_return_items_list TO admin;
GRANT SELECT ON TABLE durable_planord_return_items_list TO public;

-- Function:  durable_planned_order_returns()

-- DROP FUNCTION  durable_planned_order_returns();

CREATE OR REPLACE FUNCTION  durable_planned_order_returns()
  RETURNS SETOF durable_planord_return_items_list AS
$BODY$DECLARE _x RECORD;
DECLARE _y RECORD;
DECLARE _counter INTEGER;

BEGIN

_counter = 0;

TRUNCATE TABLE  _return.durable_planord_return_items_list;

FOR _x IN

	SELECT item_number, planord_duedate,planord_qty
	FROM
	 (
		SELECT *
		FROM planord 
			JOIN itemsite ON (planord_itemsite_id=itemsite.itemsite_id)
			JOIN whsinfo ON (itemsite.itemsite_warehous_id=whsinfo.warehous_id)
			JOIN item ON (itemsite.itemsite_item_id=item_id)
			JOIN classcode ON item_classcode_id=classcode_id 
			JOIN uom ON (item_inv_uom_id=uom_id)
			LEFT OUTER JOIN itemsite supplyitemsite ON (planord_supply_itemsite_id=supplyitemsite.itemsite_id)
			LEFT OUTER JOIN whsinfo supplywhsinfo ON (supplyitemsite.itemsite_warehous_id=supplywhsinfo.warehous_id)
		WHERE planord_type = 'P' AND classcode_code = 'D-COMPONENTS'
	 )  AS data
	ORDER BY  item_number, planord_duedate
	
LOOP
	_counter = _counter + 1;
	
	FOR _y IN
	
		SELECT 
			it.child_item_id as parent_item_id,
			parent.item_number as parent_item_number,
			parent.item_descrip1 as parent_item_desc,
			parent_item_id as child_item_id,
			uom_descrip,
			item.item_type,
			cc.classcode_code,
			child_number,
			child_desc,
			COALESCE(rl.a_qty_ret,qty_ret) as qty_ret,			
			_x.planord_duedate,
			_x.planord_qty::bigint,
			it.xtindentrole,
			it.index::numeric as jindex, 
			grp.index as iindex,
			_counter as grp,
			rl.return_date
			
		FROM  _return.getitemreturns(_x.item_number,_x.planord_duedate) it
		LEFT JOIN 
			(
				SELECT return_date,item_number,SUM(raitem_qtyauthorized - coitem_qtyreturned) as a_qty_ret
				FROM  _return.returns_list 
				GROUP BY return_date,item_number
			) rl ON it.child_number = rl.item_number
				AND rl.return_date <= _x.planord_duedate
				AND rl.return_date >= current_date - 30
		JOIN public.item item on it.parent_item_id = item.item_id
		JOIN public.item parent on it.child_item_id = parent.item_id
		JOIN public.classcode cc ON item.item_classcode_id = cc.classcode_id
		JOIN
		(
			SELECT 
				DISTINCT index::integer as index
			FROM  _return.getitemreturns(_x.item_number,_x.planord_duedate) it
			--Where qty_ret > 0
		) grp ON grp.index = it.index::integer
		Where NOT parent.item_number ~ 'SIE'

	LOOP

		INSERT INTO _return.durable_planord_return_items_list
		VALUES
		(	
			_y.parent_item_id,
			_y.parent_item_number,
			_y.parent_item_desc,
			_y.child_item_id,
			_y.uom_descrip,
			_y.item_type,
			_y.classcode_code,
			_y.child_number,
			_y.child_desc,
			_y.qty_ret,			
			_x.planord_duedate,
			_x.planord_qty,
			_y.xtindentrole,
			_y.jindex::numeric,
			_y.iindex,
			_y.grp,
			_y.return_date
		);
		
		RETURN NEXT _y;
		
	END LOOP;

END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION  durable_planned_order_returns()
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION  durable_planned_order_returns() TO public;
GRANT EXECUTE ON FUNCTION  durable_planned_order_returns() TO admin;

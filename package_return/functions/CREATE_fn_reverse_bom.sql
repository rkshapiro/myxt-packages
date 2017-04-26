-- Function: reverse_bom(text)

-- DROP FUNCTION reverse_bom(text);

CREATE OR REPLACE FUNCTION reverse_bom("$1" text)
  RETURNS SETOF return_items_list AS
$BODY$

-- the purpose of this function is to enter an item number and return all parents of said item number
-- I use the recursive function to expedite this query
-- the two important columns are the 
--	xtindentrole column which is used by the xTuple xTreeWidget to indent tows
--	index column which keeps track of the child-parent relationship
-- I also ise the xtindentrole column to determine the number of decimal places in the index column
-- 20150303:rek we now include kits level rows

WITH RECURSIVE chain AS
	(
	-- first part of query is the child level
		SELECT
		  bomitem.bomitem_item_id as child_item_id,
		  bomitem.bomitem_parent_item_id as parent_item_id, 	  		   
		  bomitem.bomitem_qtyper::integer,
		  bomitem.bomitem_expires,
		  bomitem.bomitem_rev_id,
		  bomitem.bomitem_uom_id,
		  0::integer as xtindentrole,
		  (ROW_NUMBER() OVER (ORDER BY bomitem.bomitem_parent_item_id)) ::numeric as index	  	  
		FROM
		(
			SELECT DISTINCT
				bomitem_parent_item_id,bomitem_item_id,bomitem_rev_id
				 AS bomhead_rev_id
			FROM bomitem
			JOIN public.item ON bomitem.bomitem_parent_item_id = item.item_id
			WHERE bomitem_item_id = getitemid($1)
			AND bomitem_rev_id = getActiveRevId('BOM',bomitem_parent_item_id)
			AND bomitem_rev_id != -1
			AND item.item_active
			AND item.item_descrip1 NOT LIKE '%INACTIVE%'
			
		) bomhead
		  JOIN public.bomitem ON bomhead.bomhead_rev_id = bomitem.bomitem_rev_id
				AND bomitem.bomitem_parent_item_id = bomhead.bomitem_parent_item_id
				AND bomitem.bomitem_item_id = bomhead.bomitem_item_id
		  WHERE bomitem.bomitem_expires > current_date
		  
		  UNION ALL

		-- second part of query which is the parent levels

		  SELECT
		  bomitem.bomitem_item_id as child_item_id,
		  bomitem.bomitem_parent_item_id as parent_item_id, 	  		  
		  bomitem.bomitem_qtyper::integer ,
		  bomitem.bomitem_expires,
		  bomitem.bomitem_rev_id,
		  bomitem.bomitem_uom_id,
		  c.xtindentrole + 1,

		-- the index here is incremented by the number of decimal places in xtindentrole
		  
		  c.index + (power(10,-(c.xtindentrole + 1 ))::numeric *  ntile(2) OVER (ORDER BY bomitem.bomitem_parent_item_id))	 
		FROM
		chain c
		JOIN
		(
			SELECT 
				bomitem_parent_item_id,bomitem_item_id,bomitem_rev_id
				 AS bomhead_rev_id
			FROM bomitem
			JOIN public.item ON bomitem.bomitem_parent_item_id = item.item_id
			WHERE bomitem_rev_id = getActiveRevId('BOM',bomitem_parent_item_id)
			AND bomitem_rev_id != -1
			AND item.item_active
			AND item.item_descrip1 NOT LIKE '%INACTIVE%'			
			
		) bomhead ON c.parent_item_id = bomhead.bomitem_item_id	
		JOIN public.bomitem ON bomhead.bomhead_rev_id = bomitem.bomitem_rev_id
				AND bomitem.bomitem_parent_item_id = bomhead.bomitem_parent_item_id
				AND bomitem.bomitem_item_id = bomhead.bomitem_item_id				
		WHERE bomitem.bomitem_expires > current_date
		AND c.parent_item_id IS  NOT NULL
	)

-- the return query which uses the chain table and associated joins

	SELECT   DISTINCT
		chain.child_item_id,
		chain.parent_item_id,
		chain.bomitem_qtyper,
		chain.bomitem_expires,
		chain.bomitem_rev_id,
		chain.bomitem_uom_id,
		chain.xtindentrole,
		uom.uom_descrip, 
		item.item_number as parent_number,
		item.item_descrip1 as parent_desc,
		item.item_type,
		item.item_classcode_id,
		child.item_number as child_number, 
		child.item_descrip1 as child_desc,
		index,0::bigint,0::bigint
	FROM chain 
	JOIN public.item ON chain.parent_item_id = item.item_id
	JOIN public.item child ON chain.child_item_id = child.item_id
	JOIN public.uom ON uom.uom_id = chain.bomitem_uom_id	
	Where --item.item_type in ('M','K') AND
	--item.item_classcode_id NOT IN (111) AND 
	bomitem_rev_id != -1 AND
	item.item_active AND
	item.item_descrip1 NOT LIKE '%INACTIVE%'
	AND NOT item.item_number ~ 'SIE'
	
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION reverse_bom(text)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION reverse_bom(text) TO admin;
GRANT EXECUTE ON FUNCTION reverse_bom(text) TO public;

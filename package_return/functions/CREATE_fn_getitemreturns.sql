-- Function: getitemreturns(text, date)

-- DROP FUNCTION getitemreturns(text, date);

CREATE OR REPLACE FUNCTION getitemreturns(text, date DEFAULT '2099-12-31'::date)
  RETURNS SETOF return_items_list AS
$BODY$DECLARE
	_item_number ALIAS FOR $1;
	_cutoffdate ALIAS FOR $2;
	_x RECORD;
	_y RECORD;
	_z RECORD;
	_counter numeric;
	_returns bigint;

BEGIN
	_counter = 0;
	_returns = 0;

	DROP TABLE IF EXISTS temp_ra;

	-- Create a temporary table to update in the loop below
		
	CREATE TEMPORARY TABLE temp_ra as
	SELECT 
		parent_item_id,
		child_item_id,				
		bomitem_qtyper,		
		bomitem_expires,
		bomitem_rev_id,
		bomitem_uom_id,
		xtindentrole,
		uom_descrip,
		parent_number,
		parent_desc,
		item_type,
		item_classcode_id,
		child_number,
		child_desc,
		index,
		COALESCE(ra.qty_return,0)::bigint as returned,
		0::bigint as qty_ret
	FROM _return.reverse_bom(_item_number)
	LEFT JOIN
	(
		Select 
			item_number,
			SUM(raitem_qtyauthorized - raitem_qtyreceived) as qty_return 
		from _return.returns_list
		WHERE return_date <= _cutoffdate
		AND 	return_date >= current_date - 30
		GROUP BY item_number
	) ra ON ra.item_number = reverse_bom.parent_number
	-- we dont want to include XCON which may have durables
	WHERE index::integer NOT IN 
	(
		SELECT 		
		index:: integer
		FROM reverse_bom(_item_number)
		WHERE getclasscodeid('XCON') = item_classcode_id
	)
	ORDER BY index;
	
	

	FOR _x IN
	
		-- start from the bootom of the index counter and desc
		-- this doen to be certain that we start with a child item
		
		SELECT * FROM temp_ra		
		ORDER BY index DESC

	LOOP	
		-- The xtindentrole column is a level column ised by xTuple xTreeWidget to indent rows, 0, 1, 2, ...
		-- and indicates how many decimal places that are in the index column
		-- I use the xtindentrole to trunicate the index and find the next level of index
		-- thus 2.11 -> 2.1
		-- so sum up all the returns for the current index, say 2.11, there may be more than one
		-- and place this value into the index above, say 2.1

		-- at the next column 2.1 will sum up to 2 and end
		
		--SELECT SUM(returned) into _returns
		--FROM temp_ra
		--WHERE trunc(index,xtindentrole-1) = _x.index
		--GROUP BY trunc(index,xtindentrole-1);

		-- 20150219:rek
		-- When xtindentrole = 0 THEN xtindentrole - 1 = -1
		-- THEN trunc(index,xtindentrole-1) = 10 when index > 9 and 0 when index < 10
		-- so I correct this to 

		SELECT SUM(returned) into _returns
		FROM temp_ra
		WHERE trunc(index,CASE xtindentrole WHEN 0 THEN 0 ELSE xtindentrole-1 END) = _x.index
		GROUP BY trunc(index,CASE xtindentrole WHEN 0 THEN 0 ELSE xtindentrole-1 END);

					
		IF (_returns > 0) THEN

			UPDATE temp_ra
			SET returned = _returns
			WHERE index = _x.index;

		END IF;	

		-- then update the qty_ret column	

		UPDATE temp_ra
		SET qty_ret = returned * bomitem_qtyper;
		
	END LOOP;

	FOR _y IN
	
		SELECT * FROM temp_ra
		ORDER BY index
		
	LOOP
		RETURN NEXT _y;
	END LOOP;

	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION getitemreturns(text, date)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION getitemreturns(text, date) TO admin;
GRANT EXECUTE ON FUNCTION getitemreturns(text, date) TO public;

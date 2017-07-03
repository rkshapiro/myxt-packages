-- Function: returnaging(date)

-- DROP FUNCTION returnaging(date);

CREATE OR REPLACE FUNCTION returnaging(date)
  RETURNS SETOF returnaging AS
$BODY$
DECLARE
  pAsOfDate ALIAS FOR $1;
  _row returnaging%ROWTYPE;
  _x RECORD;
  _returnVal INTEGER;
  _asOfDate DATE;
BEGIN

  _asOfDate := COALESCE(pAsOfDate,current_date);

    
  FOR _x IN
	SELECT 
        --report uses currtobase to convert all amounts to base based on aropen_docdate to ensure the same exchange rate

        --30 days past due
        CASE WHEN(return_date+60 >= DATE(_asOfDate)) AND (return_date+30 <= DATE(_asOfDate)) 
        THEN (qtydue)
		ELSE 0
		END as thirty_qty,

		CASE WHEN(return_date+60 >= DATE(_asOfDate)) AND (return_date+30 <= DATE(_asOfDate)) 
        THEN (qtydue) * 100.0 -- FY2013 late fee per item
		ELSE 0
		END as thirty_fee,
		
        --60 days or more
        CASE WHEN((return_date+60 <= DATE(_asOfDate))) 
        THEN (qtydue)
		ELSE 0
		END as sixty_qty,

        return_date,
		delivery_date,
        coitem_raitem.item_number,
		item_descrip1,
		rahead_number,
		rahead_billtoname,
        cust_number,
		cust_name,
		rahead_shipto_name,
		custtype_code,
		raitem_qtyauthorized,
		raitem_qtyreceived,
		item_descrip1

        FROM _return.coitem_raitem
		join cohead on coitem_raitem_cohead_id = cohead_id
		join custinfo on cohead_cust_id = cust_id
		join custtype on cust_custtype_id = custtype_id
		join itemsite on coitem_raitem_itemsite_id = itemsite_id
		join item on itemsite_item_id = item_id
        WHERE _asOfDate >= return_date+30 and qtydue > 0
LOOP
        _row.return_date := _x.return_date;
        _row.delivery_date := _x.delivery_date;
        _row.item_number := _x.item_number;
		_row.item_description := _x.item_descrip1;
        _row.rahead_number := _x.rahead_number;
        _row.rahead_billtoname := _x.rahead_billtoname;
        _row.cust_number := _x.cust_number;
        _row.cust_name := _x.cust_name;
		_row.rahead_shipto_name := _x.rahead_shipto_name;
		_row.custtype_code := _x.custtype_code;
		_row.raitem_qtyauthorized := _x.raitem_qtyauthorized;
		_row.raitem_qtyreceived := _x.raitem_qtyreceived;
        _row.thirty_fee := _x.thirty_fee;
        _row.thirty_qty := _x.thirty_qty;
        _row.sixty_qty := _x.sixty_qty;

        RETURN NEXT _row;
  END LOOP;
  RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION returnaging(date) OWNER TO "admin";

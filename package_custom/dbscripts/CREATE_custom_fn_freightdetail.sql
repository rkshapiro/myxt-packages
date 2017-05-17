-- Function: _custom.freightdetail(text, integer, integer, integer, date, text, integer)

-- DROP FUNCTION _custom.freightdetail(text, integer, integer, integer, date, text, integer);

CREATE OR REPLACE FUNCTION _custom.freightdetail(text, integer, integer, integer, date, text, integer)
  RETURNS SETOF freightdata AS
$BODY$
-- 20140224:jjb Function originally compared schedules against CURRENT_DATE -- switched it to compare against scheduled date of the order (getSoSchedDate(pOrderId))
-- 20121214:rks ASSET customized to remove grouping by freight class when total order weight <= 200 lbs
-- 20160419:rks enabled freight on quotes
DECLARE
  pOrderType ALIAS FOR $1;
  pOrderId ALIAS FOR $2;
  pCustId ALIAS FOR $3;
  pShiptoId ALIAS FOR $4;
  pOrderDate ALIAS FOR $5;
  pShipVia ALIAS FOR $6;
  pCurrId ALIAS FOR $7;
  _row freightData%ROWTYPE;
  _order RECORD;
  _weights RECORD;
  _price RECORD;
  _sales RECORD;
  _freightid INTEGER := NULL;
  _totalprice NUMERIC := 0.0;
  _includepkgweight BOOLEAN := FALSE;
  _freight RECORD;
  _qry TEXT;
  _debug BOOLEAN := false;
  _ground BOOLEAN := false; -- ASSET flag used to indicate if freight should be charged by piece (default = mulitweight)
  _asof DATE;
	
BEGIN
  IF (_debug) THEN
    RAISE NOTICE 'pOrderType = %', pOrderType;
    RAISE NOTICE 'pOrderId = %', pOrderId;
    RAISE NOTICE 'pCustId = %', pCustId;
    RAISE NOTICE 'pShiptoId = %', pShiptoId;
    RAISE NOTICE 'pOrderDate = %', pOrderDate;
    RAISE NOTICE 'pShipVia = %', pShipVia;
    RAISE NOTICE 'pCurrId = %', pCurrId;
  END IF;

  SELECT fetchMetricBool('IncludePackageWeight') INTO _includepkgweight;

  --Get the order header information need to match
  --against price schedules
  IF (pOrderType = 'SO') THEN
    SELECT cust_id AS cust_id,
           custtype_id,
           custtype_code,
           COALESCE(shipto_id, -1) AS shipto_id,
           COALESCE(shipto_num, '') AS shipto_num,
           COALESCE(pOrderDate, cohead_orderdate) AS orderdate,
           COALESCE(pShipVia, cohead_shipvia) AS shipvia,
           shipto_shipzone_id AS shipzone_id,
           COALESCE(pCurrId, cohead_curr_id) AS curr_id,
           currConcat(COALESCE(pCurrId, cohead_curr_id)) AS currAbbr
    INTO _order
    FROM cohead JOIN cust ON (cust_id=COALESCE(pCustId, cohead_cust_id))
                JOIN custtype ON (custtype_id=cust_custtype_id)
                LEFT OUTER JOIN shipto ON (shipto_id=COALESCE(pShiptoId, cohead_shipto_id))
    WHERE (cohead_id=pOrderId);

  ELSIF (pOrderType = 'QU') THEN
    SELECT quhead_cust_id AS cust_id,
           COALESCE(custtype_id, getcusttypeid('NM')) AS custtype_id,
           COALESCE(custtype_code,'NM') AS custtype_code,
           COALESCE(shipto_id, -1) AS shipto_id,
           COALESCE(shipto_num, '') AS shipto_num,
           COALESCE(null,quhead_quotedate) AS orderdate,
           quhead_shipvia AS shipvia,
		   CASE WHEN shipto_shipzone_id IS NULL THEN
		   (SELECT
           CASE
	       WHEN zone = 'Zone 2' THEN 44
	       WHEN zone = 'Zone 3' THEN 45
	       WHEN zone = 'Zone 4' THEN 47
	       WHEN zone = 'Zone 5' THEN 48
	       WHEN zone = 'Zone 6' THEN 49
	       WHEN zone = 'Zone 7' THEN 50
	       WHEN zone = 'Zone 8' THEN 51
	       ELSE 0 
           END 
           FROM zipcode_zone
           WHERE SUBSTRING(COALESCE(quhead_shiptozipcode, quhead_billtozip),1,3) = zipcode_prefix)
		   ELSE shipto_shipzone_id
		   END AS shipzone_id,
           quhead_curr_id AS curr_id,
           currConcat(quhead_curr_id) AS currAbbr
    INTO _order
    FROM quhead LEFT OUTER JOIN prospect ON (prospect_id = quhead_cust_id)
	            LEFT OUTER JOIN custinfo ON (cust_id = quhead_cust_id)
				LEFT OUTER JOIN custtype ON (custtype_id=cust_custtype_id)
                LEFT OUTER JOIN shipto ON (shipto_id=quhead_shipto_id)
    WHERE (quhead_id=pOrderId);

  ELSIF (pOrderType = 'RA') THEN
    SELECT cust_id AS cust_id,
           custtype_id,
           custtype_code,
           COALESCE(shipto_id, -1) AS shipto_id,
           COALESCE(shipto_num, '') AS shipto_num,
           COALESCE(pOrderDate, rahead_authdate) AS orderdate,
           ''::text AS shipvia,
           shipto_shipzone_id AS shipzone_id,
           COALESCE(pCurrId, rahead_curr_id) AS curr_id,
           currConcat(COALESCE(pCurrId, rahead_curr_id)) AS currAbbr
    INTO _order
    FROM rahead JOIN cust ON (cust_id=COALESCE(pCustId, rahead_cust_id))
                JOIN custtype ON (custtype_id=cust_custtype_id)
                LEFT OUTER JOIN shipto ON (shipto_id=COALESCE(pShiptoId, rahead_shipto_id))
    WHERE (rahead_id=pOrderId);

  ELSE
    RAISE EXCEPTION 'Invalid order type.';
  END IF;

  IF (_debug) THEN
    RAISE NOTICE 'cust_id = %', _order.cust_id;
    RAISE NOTICE 'custtype_id = %', _order.custtype_id;
    RAISE NOTICE 'shipto_id = %', _order.shipto_id;
    RAISE NOTICE 'shipto_num = %', _order.shipto_num;
    RAISE NOTICE 'orderdate = %', _order.orderdate;
    RAISE NOTICE 'shipvia = %', _order.shipvia;
    RAISE NOTICE 'shipzone_id = %', _order.shipzone_id;
    RAISE NOTICE 'curr_id = %', _order.curr_id;
    RAISE NOTICE 'currAbbr = %', _order.currAbbr;
  END IF;
-- ASSET custom - determine the total weight of the order first
-- then group the weight by freight class if the total is > 200 to mimic multiweight rate charges
-- otherwise apply the freight schedule by piece to mimic ground by piece rate charges
IF (_includePkgWeight AND pOrdertype <> 'QU') THEN
    _qry := 'SELECT SUM(orderitem_qty_ordered * (item_prodweight + item_packweight)) AS weight ';
  ELSE
    _qry := 'SELECT SUM(orderitem_qty_ordered * item_prodweight) AS weight ';
  END IF;

  _qry := _qry || 'FROM orderitem JOIN itemsite ON (itemsite_id=orderitem_itemsite_id)
                          JOIN item ON (item_id=itemsite_item_id) ';

  IF (pOrderType = 'RA') THEN
    _qry := _qry || 'JOIN raitem ON ((orderitem_id=raitem_id)
				AND  (raitem_disposition IN (''C'',''R'',''P''))) ';
  END IF;
  
  IF (pOrderType = 'QU') THEN
	_qry := _qry || 'JOIN quitem ON (orderitem_id=quitem_id)';
  END IF;  
  
  _qry := _qry || '
    WHERE ( (orderitem_orderhead_type=' || quote_literal(pOrderType) || ')
      AND   (orderitem_orderhead_id=' || quote_literal(pOrderId) || ')
      AND   (orderitem_status <> ''X'')
		  AND   (item_freightclass_id IS NOT NULL';
		  
	  IF (pOrderType = 'QU') THEN -- include kits on quote
		_qry := _qry ||  ' OR item_type = ''K''';
	  END IF;
		
  _qry := _qry ||'))';
		
  --Get a list of aggregated weights from sites and
  --freight classes used on order lines
	EXECUTE _qry INTO _weights;
	
	IF (_debug) THEN
	    RAISE NOTICE 'qry = %',_qry;
		RAISE NOTICE '_weights.weight order total = %', _weights.weight;
	END IF;
	
	IF (_weights.weight > 200) THEN
	  IF (_includePkgWeight AND pOrdertype <> 'QU') THEN
	  
		_qry := 'SELECT SUM(orderitem_qty_ordered * (item_prodweight + item_packweight)) AS weight, ';
	  ELSE
		_qry := 'SELECT SUM(orderitem_qty_ordered * item_prodweight) AS weight, ';
	  END IF;

	  _qry := _qry || '1.0 as qty,itemsite_warehous_id, COALESCE(item_freightclass_id,getfreightclassid(''MODULE'')) AS item_freightclass_id,''na''::text as item_number
			   FROM orderitem JOIN itemsite ON (itemsite_id=orderitem_itemsite_id)
							  JOIN item ON (item_id=itemsite_item_id) ';

	  IF (pOrderType = 'RA') THEN
		_qry := _qry || 'JOIN raitem ON ((orderitem_id=raitem_id)
					AND  (raitem_disposition IN (''C'',''R'',''P''))) ';
	  END IF;
	  
	  IF (pOrderType = 'QU') THEN
		_qry := _qry || 'JOIN quitem ON (orderitem_id=quitem_id)';
	  END IF;
	  
	  _qry := _qry || '
		WHERE ( (orderitem_orderhead_type=' || quote_literal(pOrderType) || ')
		  AND   (orderitem_orderhead_id=' || quote_literal(pOrderId) || ')
		  AND   (orderitem_status <> ''X'')
		  AND   (item_freightclass_id IS NOT NULL';
		  
	  IF (pOrderType = 'QU') THEN -- include kits on quote
		_qry := _qry ||  ' OR item_type = ''K''';
	  END IF;
		_qry := _qry ||')) GROUP BY itemsite_warehous_id, item_freightclass_id;';
	ELSE
		_ground := true;  -- ASSET apply frieght rates by piece
		IF (_includePkgWeight AND pOrdertype <> 'QU') THEN
			_qry := 'SELECT (item_prodweight + item_packweight) AS weight, ';
		ELSE
			_qry := 'SELECT item_prodweight AS weight, ';
		END IF;

		_qry := _qry || 'orderitem_qty_ordered as qty,itemsite_warehous_id, COALESCE(item_freightclass_id,getfreightclassid(''MODULE'')) AS item_freightclass_id,item_number  
			   FROM orderitem JOIN itemsite ON (itemsite_id=orderitem_itemsite_id)
							  JOIN item ON (item_id=itemsite_item_id) ';

		IF (pOrderType = 'RA') THEN
			_qry := _qry || 'JOIN raitem ON ((orderitem_id=raitem_id)
					AND  (raitem_disposition IN (''C'',''R'',''P''))) ';
		END IF;
		
	    IF (pOrderType = 'QU') THEN
		    _qry := _qry || 'JOIN quitem ON (orderitem_id=quitem_id)';
	    END IF;

	
		_qry := _qry || '
		WHERE ( (orderitem_orderhead_type=' || quote_literal(pOrderType) || ')
		  AND   (orderitem_orderhead_id=' || quote_literal(pOrderId) || ')
		  AND   (orderitem_status <> ''X'')
		  AND   (item_freightclass_id IS NOT NULL';
		  
	  IF (pOrderType = 'QU') THEN -- include kits on quote
		_qry := _qry ||  ' OR item_type = ''K''';
	  END IF;
		
		_qry := _qry ||'))';
	END IF;
	
  --Get pricing effectivity metric
IF (SELECT fetchMetricText('soPriceEffective') = 'OrderDate') THEN
    _asof := pOrderDate;
  ELSE IF (SELECT fetchMetricText('soPriceEffective') = 'ScheduleDate') THEN
    IF (pOrderType = 'SO') THEN
	  _asof := getSoSchedDate(pOrderId);
	ELSE IF (pOrderType = 'QU') THEN
	     _asof := getquotescheddate(pOrderId);
	ELSE IF (pOrderType = 'RA') THEN
	     _asof := CURRENT_DATE;
	    END IF;
	END IF;	
    END IF; 
  END IF;
END IF;

  IF (_debug) THEN
    RAISE NOTICE '_asof = %',_asof;
  END IF;	
  
  FOR _weights IN
    EXECUTE _qry LOOP

  IF (_debug) THEN
    RAISE NOTICE '_weights.weight = %', _weights.weight;
    RAISE NOTICE '_weights.itemsite_warehous_id = %', _weights.itemsite_warehous_id;
    RAISE NOTICE '_weights.item_freightclass_id = %', _weights.item_freightclass_id;
	RAISE NOTICE '_weights.qty = %', _weights.qty;
	RAISE NOTICE '_weights.item_number = %', _weights.item_number;
  END IF;

-- First get a sales price if any so we when we find other prices
-- we can determine if we want that price or this price.
--  Check for a Sale Price
  SELECT ipsfreight_id,
         CASE WHEN (ipsfreight_type='F') THEN currToCurr(ipshead_curr_id, _order.curr_id,
                                                         ipsfreight_price, _order.orderdate)
              WHEN (ipsfreight_type<>'F' AND NOT _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price), _order.orderdate)
			  WHEN (ipsfreight_type<>'F' AND _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price)*_weights.qty, _order.orderdate) -- ASSET
         END AS price
         INTO _sales
  FROM ipsfreight JOIN ipshead ON (ipshead_id=ipsfreight_ipshead_id)
                  JOIN sale ON (sale_ipshead_id=ipshead_id)
  WHERE ( (ipsfreight_qtybreak <= _weights.weight)
    AND   ((ipsfreight_warehous_id IS NULL) OR (ipsfreight_warehous_id=_weights.itemsite_warehous_id))
    AND   ((ipsfreight_freightclass_id IS NULL) OR (ipsfreight_freightclass_id=_weights.item_freightclass_id))
    AND   ((ipsfreight_shipzone_id IS NULL) OR (ipsfreight_shipzone_id=_order.shipzone_id))
    AND   ((ipsfreight_shipvia IS NULL) OR (ipsfreight_shipvia=_order.shipvia))
    AND   (_asof BETWEEN sale_startdate AND sale_enddate)
    AND   (_order.cust_id IS NOT NULL) )
  ORDER BY ipsfreight_qtybreak DESC, price ASC
  LIMIT 1;

  IF (_debug) THEN
    IF (_sales.price IS NOT NULL) THEN
      RAISE NOTICE 'Sales Price found, %', _sales.price;
    END IF;
  END IF;

--  Check for a Customer Shipto Price
  SELECT ipsfreight_id,
         CASE WHEN (ipsfreight_type='F') THEN currToCurr(ipshead_curr_id, _order.curr_id,
                                                         ipsfreight_price, _order.orderdate)
			  WHEN (ipsfreight_type<>'F' AND NOT _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price), _order.orderdate)
			  WHEN (ipsfreight_type<>'F' AND _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price)*_weights.qty, _order.orderdate) -- ASSET
         END AS price
         INTO _price
  FROM ipsfreight JOIN ipshead ON (ipshead_id=ipsfreight_ipshead_id)
                  JOIN ipsass ON (ipsass_ipshead_id=ipshead_id)
  WHERE ( (ipsfreight_qtybreak <= _weights.weight)
    AND   ((ipsfreight_warehous_id IS NULL) OR (ipsfreight_warehous_id=_weights.itemsite_warehous_id))
    AND   ((ipsfreight_freightclass_id IS NULL) OR (ipsfreight_freightclass_id=_weights.item_freightclass_id))
    AND   ((ipsfreight_shipzone_id IS NULL) OR (ipsfreight_shipzone_id=_order.shipzone_id))
    AND   ((ipsfreight_shipvia IS NULL) OR (ipsfreight_shipvia=_order.shipvia))
    AND   (_asof BETWEEN ipshead_effective AND (ipshead_expires - 1))
    AND   (ipsass_cust_id=_order.cust_id)
    AND   (ipsass_shipto_id != -1)
    AND   (ipsass_shipto_id=_order.shipto_id) )
  ORDER BY ipsfreight_qtybreak DESC, price ASC
  LIMIT 1;

  IF (_debug) THEN
    IF (_price.price IS NOT NULL) THEN
      RAISE NOTICE 'Customer Shipto Price found, %', _price.price;
    END IF;
  END IF;

  IF (_price.price IS NULL) THEN
--  Check for a Customer Shipto Pattern Price
  SELECT ipsfreight_id,
         CASE WHEN (ipsfreight_type='F') THEN currToCurr(ipshead_curr_id, _order.curr_id,
                                                         ipsfreight_price, _order.orderdate)
              WHEN (ipsfreight_type<>'F' AND NOT _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price), _order.orderdate)
			  WHEN (ipsfreight_type<>'F' AND _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price)*_weights.qty, _order.orderdate) -- ASSET
         END AS price
         INTO _price
  FROM ipsfreight JOIN ipshead ON (ipshead_id=ipsfreight_ipshead_id)
                  JOIN ipsass ON (ipsass_ipshead_id=ipshead_id)
  WHERE ( (ipsfreight_qtybreak <= _weights.weight)
    AND   (_asof BETWEEN ipshead_effective AND (ipshead_expires - 1))
    AND   (ipsass_cust_id=_order.cust_id)
    AND   (COALESCE(LENGTH(ipsass_shipto_pattern), 0) > 0)
    AND   (_order.shipto_num ~ ipsass_shipto_pattern)
    AND   ((ipsfreight_warehous_id IS NULL) OR (ipsfreight_warehous_id=_weights.itemsite_warehous_id))
    AND   ((ipsfreight_freightclass_id IS NULL) OR (ipsfreight_freightclass_id=_weights.item_freightclass_id))
    AND   ((ipsfreight_shipzone_id IS NULL) OR (ipsfreight_shipzone_id=_order.shipzone_id))
    AND   ((ipsfreight_shipvia IS NULL) OR (ipsfreight_shipvia=_order.shipvia)) )
  ORDER BY ipsfreight_qtybreak DESC, price ASC
  LIMIT 1;

  IF (_debug) THEN
    IF (_price.price IS NOT NULL) THEN
      RAISE NOTICE 'Customer Shipto Pattern Price found, %', _price.price;
    END IF;
  END IF;

  END IF;

  IF (_price.price IS NULL) THEN
--  Check for a Customer Price
  SELECT ipsfreight_id,
         CASE WHEN (ipsfreight_type='F') THEN currToCurr(ipshead_curr_id, _order.curr_id,
                                                         ipsfreight_price, _order.orderdate)
              WHEN (ipsfreight_type<>'F' AND NOT _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price), _order.orderdate)
			  WHEN (ipsfreight_type<>'F' AND _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price)*_weights.qty, _order.orderdate) -- ASSET
         END AS price
         INTO _price
  FROM ipsfreight JOIN ipshead ON (ipshead_id=ipsfreight_ipshead_id)
                  JOIN ipsass ON (ipsass_ipshead_id=ipshead_id)
  WHERE ( (ipsfreight_qtybreak <= _weights.weight)
    AND   ((ipsfreight_warehous_id IS NULL) OR (ipsfreight_warehous_id=_weights.itemsite_warehous_id))
    AND   ((ipsfreight_freightclass_id IS NULL) OR (ipsfreight_freightclass_id=_weights.item_freightclass_id))
    AND   ((ipsfreight_shipzone_id IS NULL) OR (ipsfreight_shipzone_id=_order.shipzone_id))
    AND   ((ipsfreight_shipvia IS NULL) OR (ipsfreight_shipvia=_order.shipvia))
    AND   (_asof BETWEEN ipshead_effective AND (ipshead_expires - 1))
    AND   (ipsass_cust_id=_order.cust_id)
    AND   (COALESCE(LENGTH(ipsass_shipto_pattern), 0) = 0) )
  ORDER BY ipsfreight_qtybreak DESC, price ASC
  LIMIT 1;

  IF (_debug) THEN
    IF (_price.price IS NOT NULL) THEN
      RAISE NOTICE 'Customer Price found, %', _price.price;
    END IF;
  END IF;

  END IF;

  IF (_price.price IS NULL) THEN
--  Check for a Customer Type Price
  SELECT ipsfreight_id,
         CASE WHEN (ipsfreight_type='F') THEN currToCurr(ipshead_curr_id, _order.curr_id,
                                                         ipsfreight_price, _order.orderdate)
              WHEN (ipsfreight_type<>'F' AND NOT _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price), _order.orderdate)
			  WHEN (ipsfreight_type<>'F' AND _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price)*_weights.qty, _order.orderdate) -- ASSET
         END AS price
         INTO _price
  FROM ipsfreight JOIN ipshead ON (ipshead_id=ipsfreight_ipshead_id)
                  JOIN ipsass ON (ipsass_ipshead_id=ipshead_id)
  WHERE ( (ipsfreight_qtybreak <= _weights.weight)
    AND   ((ipsfreight_warehous_id IS NULL) OR (ipsfreight_warehous_id=_weights.itemsite_warehous_id))
    AND   ((ipsfreight_freightclass_id IS NULL) OR (ipsfreight_freightclass_id=_weights.item_freightclass_id))
    AND   ((ipsfreight_shipzone_id IS NULL) OR (ipsfreight_shipzone_id=_order.shipzone_id))
    AND   ((ipsfreight_shipvia IS NULL) OR (ipsfreight_shipvia=_order.shipvia))
    AND   (_asof BETWEEN ipshead_effective AND (ipshead_expires - 1))
    AND   (ipsass_custtype_id=_order.custtype_id) )
  ORDER BY ipsfreight_qtybreak DESC, price ASC
  LIMIT 1;

  IF (_debug) THEN
    IF (_price.price IS NOT NULL) THEN
      RAISE NOTICE 'Customer Type Price found, %', _price.price;
    END IF;
  END IF;

  END IF;

  IF (_price.price IS NULL) THEN
--  Check for a Customer Type Pattern Price
  SELECT ipsfreight_id,
         CASE WHEN (ipsfreight_type='F') THEN currToCurr(ipshead_curr_id, _order.curr_id,
                                                         ipsfreight_price, _order.orderdate)
              WHEN (ipsfreight_type<>'F' AND NOT _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price), _order.orderdate)
			  WHEN (ipsfreight_type<>'F' AND _ground) THEN currToCurr(ipshead_curr_id, _order.curr_id,
                              (_weights.weight * ipsfreight_price)*_weights.qty, _order.orderdate) -- ASSET
         END AS price
         INTO _price
  FROM ipsfreight JOIN ipshead ON (ipshead_id=ipsfreight_ipshead_id)
                  JOIN ipsass ON (ipsass_ipshead_id=ipshead_id)
  WHERE ( (ipsfreight_qtybreak <= _weights.weight)
    AND   ((ipsfreight_warehous_id IS NULL) OR (ipsfreight_warehous_id=_weights.itemsite_warehous_id))
    AND   ((ipsfreight_freightclass_id IS NULL) OR (ipsfreight_freightclass_id=_weights.item_freightclass_id))
    AND   ((ipsfreight_shipzone_id IS NULL) OR (ipsfreight_shipzone_id=_order.shipzone_id))
    AND   ((ipsfreight_shipvia IS NULL) OR (ipsfreight_shipvia=_order.shipvia))
    AND   (_asof BETWEEN ipshead_effective AND (ipshead_expires - 1))
    AND   (COALESCE(LENGTH(ipsass_custtype_pattern), 0) > 0)
    AND   (_order.custtype_code ~ ipsass_custtype_pattern) )
  ORDER BY ipsfreight_qtybreak DESC, price ASC
  LIMIT 1;

  IF (_debug) THEN
    IF (_price.price IS NOT NULL) THEN
      RAISE NOTICE 'Customer Type Pattern Price found, %', _price.price;
    END IF;
  END IF;

  END IF;

  -- Select the lowest price  
  IF ( (_price.price IS NOT NULL) AND ((_sales.price IS NULL) OR (_price.price < _sales.price)) ) THEN
    _freightid := _price.ipsfreight_id;
    _totalprice := _price.price;
  ELSE
    IF ( (_sales.price IS NOT NULL) AND ((_price.price IS NULL) OR (_sales.price <= _price.price)) ) THEN
      _freightid := _sales.ipsfreight_id;
      _totalprice := _sales.price;
    END IF;
  END IF;

  IF (_debug) THEN
    RAISE NOTICE '_freightid = %', _freightid;
    RAISE NOTICE '_totalprice = %', _totalprice;
  END IF;

  -- Get information for the selected ipsfreight
  -- and return
  IF (_freightid IS NULL) THEN
    _row.freightdata_schedule := 'N/A';
    _row.freightdata_from := '';
    _row.freightdata_to := '';
    _row.freightdata_shipvia := '';
    _row.freightdata_freightclass := '';
    _row.freightdata_weight := 0;
    _row.freightdata_uom := '';
    _row.freightdata_price := 0;
    _row.freightdata_type := '';
    _row.freightdata_total := 0;
    _row.freightdata_currency := '';
    RETURN NEXT _row;
  ELSE
    SELECT ipshead_name,
           COALESCE(warehous_code, 'Any') AS warehouse,
           COALESCE(shipzone_name, 'Any') AS shipzone,
           COALESCE(ipsfreight_shipvia, 'Any') AS shipvia,
           COALESCE(freightclass_code, 'Any') AS freightclass,
           uom_name,
           currToCurr(ipshead_curr_id, _order.curr_id, ipsfreight_price, _order.orderdate) AS price,
           CASE WHEN (ipsfreight_type='F') THEN 'Flat Rate'
                ELSE 'Per UOM'
           END AS type
    INTO _freight
    FROM ipsfreight JOIN ipshead ON (ipshead_id=ipsfreight_ipshead_id)
                    LEFT OUTER JOIN uom ON (uom_item_weight)
                    LEFT OUTER JOIN whsinfo ON (warehous_id=ipsfreight_warehous_id)
                    LEFT OUTER JOIN shipzone ON (shipzone_id=ipsfreight_shipzone_id)
                    LEFT OUTER JOIN freightclass ON (freightclass_id=ipsfreight_freightclass_id)
    WHERE (ipsfreight_id=_freightid);

    _row.freightdata_schedule := _freight.ipshead_name;
    _row.freightdata_from := _freight.warehouse;
    _row.freightdata_to := _freight.shipzone;
    _row.freightdata_shipvia := _freight.shipvia;
    _row.freightdata_freightclass := _freight.freightclass;
    _row.freightdata_weight := _weights.weight;
    _row.freightdata_uom := _freight.uom_name;
    _row.freightdata_price := _freight.price;
    _row.freightdata_type := _freight.type;
    _row.freightdata_total := _totalprice;
    _row.freightdata_currency := _order.currAbbr;
    RETURN NEXT _row;
  END IF;

  END LOOP;
  RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION _custom.freightdetail(text, integer, integer, integer, date, text, integer)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION _custom.freightdetail(text, integer, integer, integer, date, text, integer) TO public;
GRANT EXECUTE ON FUNCTION _custom.freightdetail(text, integer, integer, integer, date, text, integer) TO admin;
GRANT EXECUTE ON FUNCTION _custom.freightdetail(text, integer, integer, integer, date, text, integer) TO xtrole;

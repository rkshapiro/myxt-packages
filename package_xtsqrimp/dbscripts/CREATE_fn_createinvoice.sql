-- Function: xtsqrimp.createinvoice()

-- DROP FUNCTION xtsqrimp.createinvoice();

CREATE OR REPLACE FUNCTION xtsqrimp.createinvoice()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
_errors INTEGER;
BEGIN

SELECT count(*) INTO _errors
FROM xtsqrimp.sqrimp
WHERE sqrimp_status <> 'new';

IF _errors > 0 THEN
  RETURN 1;
END IF;

-- Create invoice
INSERT INTO api.invoice
(
    invoice_number,invoice_date, ship_date, order_date, 
    sale_type, customer_number, 
    misc_charge_description, misc_charge, misc_charge_account_number, 
    payment, notes
)

SELECT sqrimp_invcnum,max(sqrimp_date::date),max(sqrimp_date::date),max(sqrimp_date::date),
'RET','LASQUARE134',
'Discount',sum(translate(sqrimp_discounts,'$()','')::numeric)*-1,'2-4810',
sum(translate(sqrimp_netsales,'$()','')::numeric),'Square Import'
FROM xtsqrimp.sqrimp
WHERE sqrimp_status = 'new'
AND sqrimp_qty::numeric > 0
group by sqrimp_invcnum; 

INSERT INTO  api.invoiceline
(
    invoice_number, item_number, site, 
    qty_ordered, qty_billed, update_inventory, net_unit_price, tax_type
)

SELECT sqrimp_invcnum,sqrimp_pricepointname,'LA1',
sum(sqrimp_qty::numeric),sum(sqrimp_qty::numeric),true,(sum(translate(sqrimp_grosssales,'$()','')::numeric)/sum(sqrimp_qty::numeric)),
gettaxtypeid('Tax Exempt')
FROM xtsqrimp.sqrimp
JOIN item on item_number = sqrimp_pricepointname
WHERE sqrimp_qty::numeric > 0
AND sqrimp_status = 'new'
GROUP BY sqrimp_invcnum,sqrimp_pricepointname;

-- create TAX item
INSERT INTO  api.invoiceline
(
    invoice_number, item_number, site, 
    qty_ordered, qty_billed, update_inventory, net_unit_price, tax_type
)

SELECT sqrimp_invcnum,'TAX','LA1',
1,1,true,(sum(translate(sqrimp_tax,'$()','')::numeric)),
gettaxtypeid('Tax Exempt')
FROM xtsqrimp.sqrimp
JOIN item on item_number = sqrimp_pricepointname
WHERE sqrimp_qty::numeric > 0
AND sqrimp_status = 'new'
GROUP BY sqrimp_invcnum;

-- create credit memo for returns
INSERT INTO api.creditmemo
(apply_to, memo_date, 
reason_code, customer_number,
notes, misc_charge_description, 
misc_charge_amount, misc_charge_credit_account)

SELECT sqrimp_invcnum,sqrimp_date::date,'ONLINE','LASQUARE134',
'Square Return','Discount',sum(translate(sqrimp_discounts,'$()','')::numeric)*-1,'2-4810'
FROM xtsqrimp.sqrimp
WHERE sqrimp_qty::numeric < 0
GROUP BY sqrimp_invcnum,sqrimp_date;


INSERT INTO api.creditmemoline
(memo_number, item_number, recv_site, reason_code, 
qty_returned, qty_to_credit, net_unit_price, notes)

SELECT cmhead_number,sqrimp_pricepointname,'LA1','ONLINE',
sum(sqrimp_qty::numeric),sum(sqrimp_qty::numeric),
(sum(translate(sqrimp_grosssales,'$()','')::numeric)/sum(sqrimp_qty::numeric)),
'Square Return'
FROM xtsqrimp.sqrimp
JOIN cmhead ON cmhead_invcnumber = sqrimp_invcnum
WHERE sqrimp_qty::numeric < 0
GROUP BY cmhead_number,sqrimp_pricepointname;

-- create TAX credit
INSERT INTO api.creditmemoline
(memo_number, item_number, recv_site, reason_code, 
qty_returned, qty_to_credit, net_unit_price, notes)

SELECT cmhead_number,'TAX','LA1','ONLINE',
-1,-1,
sum(translate(sqrimp_tax,'$()','')::numeric)*-1,
'Square Return'
FROM xtsqrimp.sqrimp
JOIN cmhead ON cmhead_invcnumber = sqrimp_invcnum
WHERE sqrimp_qty::numeric < 0
GROUP BY cmhead_number;

-- create cash receipt
INSERT INTO api.cashreceipt
(customer_number, funds_type, check_document_number, 
currency, amount_received, post_to, 
apply_balance_as, notes)

SELECT 'LASQUARE134','R','Square Import','USD',
SUM(translate(sqrimp_netsales,'$()','')::numeric)+sum(translate(sqrimp_tax,'$()','')::numeric),
'WCR Fifth Third Checking','Customer Deposit','Square Net Sales plus Taxes from Import on '||current_date
FROM xtsqrimp.sqrimp
WHERE sqrimp_qty::numeric > 0
AND sqrimp_status = 'new'
ORDER BY 1;

-- set event
INSERT INTO evntlog (evntlog_evnttime, evntlog_username, evntlog_evnttype_id,evntlog_ordtype)
    SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,'S'
    FROM evntnot, evnttype
    WHERE ( (evntnot_evnttype_id=evnttype_id)
     AND (evnttype_name='SqrImportComplete'));

  RETURN 0;
  
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtsqrimp.createinvoice()
  OWNER TO admin;
-- Function: xtimp.xpstdjrnlimport()

-- DROP FUNCTION xtimp.xpstdjrnlimport();

CREATE OR REPLACE FUNCTION xtimp.xpstdjrnlimport()
  RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2012 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r  RECORD;
  _result INTEGER;
  _memonumber TEXT;

BEGIN 

-- check that the GL interface is off
 PERFORM setmetric('InterfaceAPToGL','f');
 PERFORM setmetric('InterfaceARToGL','f');
 
-- Get spaces and NULLs out

UPDATE xtimp.xpstdjrnl SET xpstdjrnl_credit = 0 WHERE xpstdjrnl_credit IS NULL;
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_debit = 0 WHERE xpstdjrnl_debit IS NULL;
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_credit = 0 WHERE xpstdjrnl_credit = '';
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_debit = 0 WHERE xpstdjrnl_debit = '';
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_credit = 0 WHERE xpstdjrnl_credit = ' ';
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_debit = 0 WHERE xpstdjrnl_debit = ' ';
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_credit = 0 WHERE xpstdjrnl_credit = '  ';
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_debit = 0 WHERE xpstdjrnl_debit = '  ';
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_credit = 0 WHERE xpstdjrnl_credit = '   ';
UPDATE xtimp.xpstdjrnl SET xpstdjrnl_debit = 0 WHERE xpstdjrnl_debit = '   ';

--Journal

INSERT INTO public.stdjrnl
(stdjrnl_name, stdjrnl_descrip, stdjrnl_notes)
SELECT DISTINCT 
    xpstdjrnl_name, xpstdjrnl_descrip, xpstdjrnl_journal_notes 
FROM
    xtimp.xpstdjrnl 
WHERE 
    xpstdjrnl_import_user IS NULL AND xpstdjrnl_import_date IS NULL;

--Journal Items

INSERT INTO public.stdjrnlitem
(stdjrnlitem_stdjrnl_id, stdjrnlitem_accnt_id, stdjrnlitem_amount, stdjrnlitem_notes)
SELECT
(SELECT stdjrnl_id FROM public.stdjrnl WHERE stdjrnl_name = xpstdjrnl_name),
getglaccntid(xpstdjrnl_account),
CASE 
     -- Asset
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'A'   
          AND xpstdjrnl_credit > '0' 
     THEN CAST(xpstdjrnl_credit AS numeric)  
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'A'   
          AND xpstdjrnl_debit > '0'  
     THEN CAST(xpstdjrnl_debit AS numeric) * -1    
     -- Liab
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'L'   
          AND xpstdjrnl_credit > '0'  
     THEN CAST(xpstdjrnl_credit AS numeric)  
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'L'   
          AND xpstdjrnl_debit > '0' 
     THEN CAST(xpstdjrnl_debit AS numeric) * -1
     -- Equity
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'Q'   
          AND xpstdjrnl_credit > '0'  
     THEN CAST(xpstdjrnl_credit AS numeric)  
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'Q'   
          AND xpstdjrnl_debit > '0'  
     THEN CAST(xpstdjrnl_debit AS numeric) * -1
     -- Rev
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'R'   
          AND xpstdjrnl_credit > '0'  
     THEN CAST(xpstdjrnl_credit AS numeric) 
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'R'   
          AND xpstdjrnl_debit > '0'  
     THEN CAST(xpstdjrnl_debit AS numeric)  * -1
     -- Exp
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'E'   
          AND xpstdjrnl_credit > '0'  
     THEN CAST(xpstdjrnl_credit AS numeric)
     WHEN
         (SELECT accnt_type FROM accnt WHERE accnt_id = (SELECT getglaccntid(xpstdjrnl_account))) = 'E'   
          AND xpstdjrnl_debit > '0'  
     THEN CAST(xpstdjrnl_debit AS numeric) * -1
     -- Error
     ELSE 0 END,
     xpstdjrnl_entry_notes
FROM xtimp.xpstdjrnl 
WHERE 
     xpstdjrnl_import_user IS NULL AND xpstdjrnl_import_date IS NULL;

-- Set as imported
UPDATE xtimp.stdjrnl SET stdjrnl_import_date = current_date WHERE stdjrnl_import_date IS NULL;
UPDATE xtimp.stdjrnl SET stdjrnl_import_user = current_user WHERE stdjrnl_import_user IS NULL;

RAISE NOTICE  'xtimp std journal import completed';
RETURN(TRUE);
END; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION xtimp.xpstdjrnlimport()
  OWNER TO admin;
-- View: _report.new_member_membership_date

-- DROP VIEW _report.new_member_membership_date;

CREATE OR REPLACE VIEW _report.new_member_membership_date AS 
 SELECT 
	crmacct.crmacct_owner_username,
        CASE
            WHEN custinfo.cust_custtype_id = ANY (ARRAY[19, 36, 37, 40, 42, 44]) THEN 'member'::text
            ELSE 'customer'::text
        END AS cust_member, 
        custinfo.cust_id, 
        custinfo.cust_active,
        custinfo.cust_custtype_id, 
        custtype.custtype_code, 
        custinfo.cust_number, 
        custinfo.cust_name, 
        charass.charass_value::date AS charass_value, 
        invchead.firstinvoicedate, 
        cohead.firstorderdate, 
        _report.getfiscalyear(COALESCE(charass.charass_value::date, invchead.firstinvoicedate, cohead.firstorderdate)) AS fiscalyear, 
        _report.getfiscalquarter(COALESCE(charass.charass_value::date, invchead.firstinvoicedate, cohead.firstorderdate)) AS fiscalquarter, 
        _report.getfiscalmonth(COALESCE(charass.charass_value::date, invchead.firstinvoicedate, cohead.firstorderdate)) AS fiscalmonth
   FROM public.custinfo
   JOIN public.custtype ON custinfo.cust_custtype_id = custtype.custtype_id
   JOIN public.crmacct ON custinfo.cust_id = crmacct.crmacct_cust_id
   LEFT JOIN 
   ( 
	SELECT 
		charass.charass_target_id, 
		charass.charass_value
	FROM public.charass
	WHERE charass.charass_char_id = 42) charass ON charass.charass_target_id = custinfo.cust_id
   LEFT JOIN 
   ( 
	SELECT 
		cohead.cohead_cust_id, 
		min(coitem.coitem_scheddate) AS firstorderdate
	FROM public.cohead
	JOIN public.coitem ON cohead.cohead_id = coitem.coitem_cohead_id
	WHERE coitem.coitem_status <> 'X'::bpchar
	GROUP BY cohead.cohead_cust_id
   ) cohead ON custinfo.cust_id = cohead.cohead_cust_id
   LEFT JOIN 
   ( 
	SELECT 
		invchead.invchead_cust_id, 
		min(invchead.invchead_invcdate) AS firstinvoicedate
	FROM public.invchead
	GROUP BY invchead.invchead_cust_id
   ) invchead ON custinfo.cust_id = invchead.invchead_cust_id
   WHERE 
	custinfo.cust_active = true 
	AND _report.getfiscalyear(COALESCE(charass.charass_value::date, invchead.firstinvoicedate, cohead.firstorderdate)) > 2008
  ORDER BY custinfo.cust_name;

ALTER TABLE _report.new_member_membership_date OWNER TO admin;
GRANT ALL ON TABLE _report.new_member_membership_date TO admin;
GRANT ALL ON TABLE _report.new_member_membership_date TO xtrole;
GRANT SELECT, REFERENCES ON TABLE _report.new_member_membership_date TO public;
COMMENT ON VIEW _report.new_member_membership_date
  IS '20141003:rek
This is an estimate of the new membership date. 
I use charass MEMBERSHIP START date
and if that is missing, the earliest cohead order date.
Dates have been transformed into Fiscal Periods. July->June.';

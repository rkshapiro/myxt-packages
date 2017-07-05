-- View: _report.contact_list

-- DROP VIEW _report.contact_list;

CREATE OR REPLACE VIEW _report.contact_list AS 
 SELECT 
	crmacct.crmacct_number AS "Account Number", 
	crmacct.crmacct_name AS "Account Name", 
	custtype.custtype_code AS "Customer Type", 
	cntct.cntct_honorific AS "Honorific", 
	cntct.cntct_first_name AS "First Name", 
	cntct.cntct_last_name AS "Last Name", 
	cntct.cntct_phone AS "Primary Phone", 
	cntct.cntct_phone2 AS "Secondary Phone", 
	cntct.cntct_fax AS "FAX Number", 
	cntct.cntct_email AS "Email", 
	cntct.cntct_title AS "Title", 
	addr.addr_line1 AS "Address 1", 
	addr.addr_line2 AS "Address 2", 
	addr.addr_line3 AS "Address 3", 
	addr.addr_city AS "City", 
	addr.addr_state AS "State", 
	addr.addr_postalcode AS "Zip", 
	zipcodes.zipcodes_county AS "County", 
	CASE
		WHEN count(cntcteml.cntcteml_id) > 1 THEN 'X'::text
		ELSE ' '::text
	END AS "Multiple Email Flag", 
	COALESCE(charass.charass_value,'  ') AS "Contact Type", --20141022:rek I need to pass two space because SSRS will not accept Nulls
	CASE
		WHEN crmacct.crmacct_cust_id IS NOT NULL THEN 'customer'::text
		WHEN crmacct.crmacct_prospect_id IS NOT NULL THEN 'prospect'::text
		WHEN crmacct.crmacct_partner_id IS NOT NULL THEN 'partner'::text
		WHEN crmacct.crmacct_competitor_id IS NOT NULL THEN 'competitor'::text
		ELSE 'other'::text
	END AS "CRM Account Type", 
	CASE
		WHEN charass.charass_value ~ 'SOS'::text THEN 'SOS'::text
		ELSE ' '::text
	END AS "SOS Flag"
   FROM cntct
   JOIN crmacct ON crmacct.crmacct_id = cntct.cntct_crmacct_id
   LEFT JOIN custinfo ON crmacct.crmacct_cust_id = custinfo.cust_id
   LEFT JOIN addr ON cntct.cntct_addr_id = addr.addr_id
   LEFT JOIN cntcteml ON cntcteml.cntcteml_cntct_id = cntct.cntct_id
   LEFT JOIN custtype ON custinfo.cust_custtype_id = custtype.custtype_id
   LEFT JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode
   LEFT JOIN charass ON charass.charass_target_id = cntct.cntct_id
   LEFT JOIN char ON charass.charass_char_id = char.char_id
  WHERE crmacct.crmacct_parent_id IS NULL 
  AND crmacct.crmacct_active = true 
  AND cntct.cntct_active = true 
  AND NOT (crmacct.crmacct_id = ANY (ARRAY[605, 5837, 1336, 6744, 6526, 6749, 6747])) 
  AND ("char".char_name = 'CONTACT TYPE'::text OR charass.charass_id IS NULL)
  GROUP BY crmacct.crmacct_number, crmacct.crmacct_name, custtype.custtype_code, cntct.cntct_honorific, cntct.cntct_first_name, cntct.cntct_last_name, cntct.cntct_phone, cntct.cntct_phone2, cntct.cntct_fax, cntct.cntct_email, cntct.cntct_title, addr.addr_line1, addr.addr_line2, addr.addr_line3, addr.addr_city, addr.addr_state, addr.addr_postalcode, zipcodes.zipcodes_county, cntct.cntct_id, crmacct.crmacct_cntct_id_1, crmacct.crmacct_cntct_id_2, crmacct.crmacct_cust_id, crmacct.crmacct_prospect_id, charass.charass_value, crmacct.crmacct_partner_id, crmacct.crmacct_competitor_id;

ALTER TABLE _report.contact_list OWNER TO mfgadmin;
GRANT ALL ON TABLE _report.contact_list TO mfgadmin;
GRANT ALL ON TABLE _report.contact_list TO xtrole;
COMMENT ON VIEW _report.contact_list IS 'used by contact list spreadsheet';


-- View: itemsrcupdate_export

DROP VIEW IF EXISTS itemsrcupdate_export;

CREATE OR REPLACE VIEW itemsrcupdate_export AS 
 SELECT 
    item_number AS itemsrcupdate_item_number,
    vend_number AS itemsrcupdate_vend_number,
    itemsrc_vend_item_number AS itemsrcupdate_vend_item_number,
    itemsrc_active AS itemsrcupdate_active,
    itemsrc_default AS itemsrcupdate_default,
    itemsrc_vend_uom AS itemsrcupdate_vend_uom,
    itemsrc_invvendoruomratio AS itemsrcupdate_invvendoruomratio,
    itemsrc_minordqty AS itemsrcupdate_minordqty,
    itemsrc_multordqty AS itemsrcupdate_multordqty,
    itemsrc_ranking AS itemsrcupdate_ranking,
    itemsrc_leadtime AS itemsrcupdate_leadtime,
    itemsrc_comments AS itemsrcupdate_comments,
    itemsrc_vend_item_descrip AS itemsrcupdate_vend_item_descrip,
    itemsrc_manuf_name AS itemsrcupdate_manuf_name,
    itemsrc_manuf_item_number AS itemsrcupdate_manuf_item_number,
    itemsrc_manuf_item_descrip AS itemsrcupdate_manuf_item_descrip,
    itemsrc_upccode AS itemsrcupdate_upccode,
    contrct_number AS itemsrcupdate_contract_number,
    itemsrc_effective AS itemsrcupdate_effective,
    itemsrc_expires AS itemsrcupdate_expires,
    itemsrcp_qtybreak AS itemsrcupdate_qtybreak,
    itemsrcp_type AS itemsrcupdate_type,
    CASE 
      WHEN itemsrcp_warehous_id = (-1) THEN 'All'
      ELSE warehous_code
    END AS itemsrcupdate_pricing_site,
    itemsrcp_dropship AS itemsrcupdate_dropship,
    itemsrcp_price AS itemsrcupdate_price,
    curr_abbr AS itemsrcupdate_curr,
    itemsrcp_discntprcnt AS itemsrcupdate_discntprcnt,
    itemsrcp_fixedamtdiscount AS itemsrcupdate_fixedamtdiscount,
    itemsrcp_updated AS itemsrcupdate_itemsrcp_updated
   FROM itemsrc
   JOIN itemsrcp ON itemsrcp_itemsrc_id = itemsrc_id
   JOIN item ON itemsrc_item_id = item_id
   JOIN vendinfo ON itemsrc_vend_id = vend_id
   JOIN curr_symbol ON itemsrcp_curr_id = curr_id
   LEFT JOIN contrct ON itemsrc_contrct_id = contrct_id
   LEFT JOIN whsinfo ON itemsrcp_warehous_id = warehous_id;

ALTER TABLE itemsrcupdate_export
  OWNER TO admin;
GRANT ALL ON TABLE itemsrcupdate_export TO admin;
GRANT SELECT ON TABLE itemsrcupdate_export TO public;
GRANT ALL ON TABLE itemsrcupdate_export TO xtrole;
COMMENT ON VIEW itemsrcupdate_export
  IS 'for creating item source update files';
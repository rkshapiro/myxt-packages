-- View: _jobtrack.xt_item

DROP VIEW IF EXISTS _jobtrack.xt_item;

CREATE OR REPLACE VIEW _jobtrack.xt_item AS 
SELECT 
	item.item_number::character varying(255) AS item_number, 
	item.item_active AS active, 
	item.item_descrip1::character varying(255) AS description1, 
	item.item_descrip2::character varying(255) AS description2, 
        CASE
            WHEN item.item_type = 'P'::bpchar THEN 'Purchased'::text
            WHEN item.item_type = 'M'::bpchar THEN 'Manufactured'::text
            WHEN item.item_type = 'J'::bpchar THEN 'Job'::text
            WHEN item.item_type = 'K'::bpchar THEN 'Kit'::text
            WHEN item.item_type = 'F'::bpchar THEN 'Phantom'::text
            WHEN item.item_type = 'R'::bpchar THEN 'Reference'::text
            WHEN item.item_type = 'S'::bpchar THEN 'Costing'::text
            WHEN item.item_type = 'T'::bpchar THEN 'Tooling'::text
            WHEN item.item_type = 'O'::bpchar THEN 'Outside Process'::text
            WHEN item.item_type = 'L'::bpchar THEN 'Planning'::text
            WHEN item.item_type = 'B'::bpchar THEN 'Breeder'::text
            WHEN item.item_type = 'C'::bpchar THEN 'Co-Product'::text
            WHEN item.item_type = 'Y'::bpchar THEN 'By-Product'::text
            ELSE NULL::text
        END::character varying(255) AS item_type, 
        item.item_maxcost AS maximum_desired_cost, 
        classcode.classcode_code::character varying(255) AS class_code, 
        i.uom_name::character varying(255) AS inventory_uom, 
        item.item_picklist AS pick_list_item, 
        item.item_fractional AS fractional, 
        item.item_config AS configured, 
        item.item_sold AS item_is_sold, 
        prodcat.prodcat_code::character varying(255) AS product_category, 
        item.item_exclusive AS exclusive, 
        item.item_listprice AS list_price, 
        p.uom_name::character varying(255) AS list_price_uom, 
        item.item_upccode::character varying(255) AS upc_code, 
        item.item_prodweight AS product_weight, 
        item.item_packweight AS packaging_weight, 
        item.item_comments::character varying(255) AS notes, 
        item.item_extdescrip::character varying(255) AS ext_description,
        itemsite.itemsite_qtyonhand AS qtyonhand,
        (SELECT warehous_code from whsinfo where warehous_id = itemsite_warehous_id)::character varying(255) AS site,
        itemCharValue(item_id,'FINDTYPE')::character varying(255) AS findtype,
        itemCharValue(item_id,'FINDSUBTYPE')::character varying(255) AS findsubtype,
        itemCharValue(item_id,'METALTYPE')::character varying(255) AS metaltype,
        itemCharValue(item_id,'METALCOLOR')::character varying(255) AS metalcolor,
        itemCharValue(item_id,'KARAT')::character varying(255) AS karat,
        itemCharValue(item_id,'FINDSHAPE')::character varying(255) AS findshape,
        itemCharValue(item_id,'STONETYPE')::character varying(255) AS stonetype,
        itemCharValue(item_id,'STONESAT')::character varying(255) AS stonesat,
        itemCharValue(item_id,'STONECOLOR')::character varying(255) AS stonecolor,
        itemCharValue(item_id,'STONESIZE')::character varying(255) AS stonesize,
        itemCharValue(item_id,'STONESHAPE')::character varying(255) AS stoneshape,
        itemCharValue(item_id,'FACETSTYLE')::character varying(255) AS facetstyle,
        itemCharValue(item_id,'STONEQUALITY')::character varying(255) AS stonequality,
        itemCharValue(item_id,'TRANSPARENCY')::character varying(255) AS transparency,
        itemCharValue(item_id,'CLARITY')::character varying(255) AS clarity,
        itemCharValue(item_id,'DIAMONDCOLOR')::character varying(255) AS diamondcolor
   FROM item
   JOIN itemsite ON itemsite_item_id = item_id
   JOIN classcode ON item.item_classcode_id = classcode.classcode_id
   JOIN uom i ON item.item_inv_uom_id = i.uom_id
   JOIN uom p ON item.item_price_uom_id = p.uom_id
   LEFT JOIN prodcat ON item.item_prodcat_id = prodcat.prodcat_id
  ORDER BY item.item_number::character varying(255);

ALTER TABLE _jobtrack.xt_item
  OWNER TO admin;
GRANT ALL ON TABLE _jobtrack.xt_item TO admin;
GRANT SELECT ON TABLE _jobtrack.xt_item TO public;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE _jobtrack.xt_item TO xtrole;
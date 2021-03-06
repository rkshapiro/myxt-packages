-- View: itemupdate_export

DROP VIEW IF EXISTS itemupdate_export;

CREATE OR REPLACE VIEW itemupdate_export AS 
 SELECT item.item_number AS item_number,
    item.item_descrip1 AS description1,
    item.item_descrip2 AS description2,
    item.item_maxcost AS maximum_desired_cost,
    classcode.classcode_code AS class_code,
    item.item_sold AS item_is_sold,
    prodcat.prodcat_code AS product_category,
    item.item_listprice AS list_price,
    item.item_listcost AS list_cost,
    item.item_prodweight AS product_weight,
    item.item_packweight AS packaging_weight,
    replace(item.item_comments,E'\n',' | ') AS notes,
    replace(item.item_extdescrip,E'\n',' | ')  AS ext_description
   FROM item
     LEFT JOIN prodcat ON item.item_prodcat_id = prodcat.prodcat_id
     LEFT JOIN classcode ON item.item_classcode_id = classcode.classcode_id 
  ORDER BY item.item_number;

ALTER TABLE itemupdate_export
  OWNER TO admin;
GRANT ALL ON TABLE itemupdate_export TO admin;
GRANT ALL ON TABLE itemupdate_export TO xtrole;
COMMENT ON VIEW itemupdate_export
  IS 'Item Update Export';
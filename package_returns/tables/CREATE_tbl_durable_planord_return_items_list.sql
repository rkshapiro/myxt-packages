-- Table: durable_planord_return_items_list

DROP TABLE IF EXISTS durable_planord_return_items_list;

CREATE TABLE durable_planord_return_items_list
(
  parent_item_id integer,
  parent_item_number text,
  parent_descript text,
  child_item_id integer,
  uom_descrip text,
  item_type character(1),
  item_classcode text,
  child_number text,
  child_desc text,
  qty_ret bigint,
  planord_duedate date,
  planord_reqd_qty bigint,
  xtindentrole integer,
  jindex numeric,
  iindex integer,
  grp integer,
  return_date date
)
WITH (
  OIDS=FALSE
);
ALTER TABLE durable_planord_return_items_list
  OWNER TO admin;
GRANT ALL ON TABLE durable_planord_return_items_list TO admin;
GRANT SELECT ON TABLE durable_planord_return_items_list TO public;

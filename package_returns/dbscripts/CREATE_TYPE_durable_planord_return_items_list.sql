-- Type: durable_planord_return_items_list

-- DROP TYPE durable_planord_return_items_list;

CREATE TYPE durable_planord_return_items_list AS
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
);
ALTER TYPE durable_planord_return_items_list
  OWNER TO admin;
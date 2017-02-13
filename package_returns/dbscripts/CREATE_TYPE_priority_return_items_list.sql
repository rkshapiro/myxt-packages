-- Type: priority_return_items_list

-- DROP TYPE priority_return_items_list;

CREATE TYPE priority_return_items_list AS
(
  planord_duedate date,
  return_authorization text,
  return_date date,
  cust_number text,
  cust_name text,
  child_item_id integer,
  child_number text,
  child_desc text,
  parent_item_id integer,
  parent_number text,
  parent_desc text,
  kit_returns integer,
  item_returns integer,
  index integer,
  xtindentrole integer
);
ALTER TYPE priority_return_items_list
  OWNER TO admin;
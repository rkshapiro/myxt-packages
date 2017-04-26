-- Type: return_items_list

DROP TYPE IF EXISTS return_items_list;

CREATE TYPE return_items_list AS
   (child_item_id integer,
    parent_item_id integer,
    bomitem_qtyper integer,
    bomitem_expires date,
    bomitem_rev_id integer,
    bomitem_uom_id integer,
    xtindentrole integer,
    uom_descrip text,
    parent_number text,
    parent_desc text,
    item_type character(1),
    item_classcode_id integer,
    child_number text,
    child_desc text,
    "index" numeric,
    returned bigint,
    qty_ret bigint);
ALTER TYPE return_items_list OWNER TO "admin";

-- Type: _report.deferred_revenue_detail_type

DROP TYPE _report.deferred_revenue_detail_type CASCADE;

CREATE TYPE _report.deferred_revenue_detail_type AS
   (def_revenue_detail_source text,
    def_revenue_detail_doc_id integer,
    def_revenue_detail_doc_number text,
    def_revenue_detail_cust_id integer,
    def_revenue_detail_cust_number text,
    def_revenue_detail_cust_name text,
    def_revenue_detail_doc_date date,
    def_revenue_detail_registered integer,
    def_revenue_detail_doc_type text,
    def_revenue_detail_amount numeric,
    def_revenue_detail_ord integer,
    def_revenue_detail_description text,
    def_revenue_detail_prj_id integer,
    def_revenue_detail_prj_number text,
    def_revenue_detail_item_number text);
ALTER TYPE _report.deferred_revenue_detail_type
  OWNER TO admin;
COMMENT ON TYPE _report.deferred_revenue_detail_type
  IS 'Orbit 1025 type for deferred revenue detail';

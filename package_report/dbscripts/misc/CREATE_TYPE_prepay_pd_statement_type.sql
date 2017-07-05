-- Type: prepay_pd_statement_type

DROP TYPE IF EXISTS prepay_pd_statement_type CASCADE;

CREATE TYPE prepay_pd_statement_type AS
   (pd_statement_doc_id integer,
    pd_statement_doc_number text,
    pd_statement_cust_id integer,
    pd_statement_cust_number text,
    pd_statement_cust_name text,
    pd_statement_doc_date date,
    pd_statement_registered integer,
    pd_statement_doc_type text,
    pd_statement_amount numeric,
    pd_statement_ord integer,
    pd_statement_description text,
    pd_statement_prj_id integer,
    pd_statement_prj_number text);
ALTER TYPE prepay_pd_statement_type
  OWNER TO admin;
COMMENT ON TYPE prepay_pd_statement_type
  IS 'Orbit 1025 type for prepaid pd statement function';

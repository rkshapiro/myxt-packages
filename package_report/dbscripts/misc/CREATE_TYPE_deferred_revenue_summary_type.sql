-- Type: _report.deferred_revenue_summary_type

DROP TYPE _report.deferred_revenue_summary_type CASCADE;

CREATE TYPE _report.deferred_revenue_summary_type AS
   (cust_id integer,
    cust_number text,
    cust_name text,
    startbalance numeric,
    periodcashmemppd numeric,
    periodcashppd numeric,
    periodregistrations numeric,
    endbalance numeric);
ALTER TYPE _report.deferred_revenue_summary_type
  OWNER TO admin;
COMMENT ON TYPE _report.deferred_revenue_summary_type
  IS 'Orbit 1025 type for deferred revenue summary';

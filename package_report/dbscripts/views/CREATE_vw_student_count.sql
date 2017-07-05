-- View: _report.student_count

-- DROP VIEW _report.student_count;

CREATE OR REPLACE VIEW _report.student_count AS 
 SELECT aquery.cust_id, aquery.cust_number, aquery.cust_name, aquery.zipcodes_county, aquery.zipcodes_state, aquery.student_count, aquery.grade, aquery.sort_order, aquery.level, aquery.impact_created
   FROM (        (        (        (        (        (        (        (        (        (        (        (        (         SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_pre_k AS student_count, 'Pre K' AS grade, 1 AS sort_order, 'Early Childhood' AS level, impact.impact_created
                                                                                                                   FROM _cpo.impact
                                                                                                              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                                                                         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                                                                    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                                                                               JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode
                                                                                                        UNION 
                                                                                                                 SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_kindergarten AS student_count, 'K' AS grade, 2 AS sort_order, 'Early Childhood' AS level, impact.impact_created
                                                                                                                   FROM _cpo.impact
                                                                                                              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                                                                         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                                                                    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                                                                               JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                                                                                UNION 
                                                                                                         SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_1 AS student_count, '1' AS grade, 3 AS sort_order, 'Elementary' AS level, impact.impact_created
                                                                                                           FROM _cpo.impact
                                                                                                      JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                                                                 JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                                                            JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                                                                       JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                                                                        UNION 
                                                                                                 SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_2 AS student_count, '2' AS grade, 4 AS sort_order, 'Elementary' AS level, impact.impact_created
                                                                                                   FROM _cpo.impact
                                                                                              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                                                         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                                                    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                                                               JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                                                                UNION 
                                                                                         SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_3 AS student_count, '3' AS grade, 5 AS sort_order, 'Elementary' AS level, impact.impact_created
                                                                                           FROM _cpo.impact
                                                                                      JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                                                 JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                                            JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                                                       JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                                                        UNION 
                                                                                 SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_4 AS student_count, '4' AS grade, 6 AS sort_order, 'Elementary' AS level, impact.impact_created
                                                                                   FROM _cpo.impact
                                                                              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                                         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                                    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                                               JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                                                UNION 
                                                                         SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_5 AS student_count, '5' AS grade, 7 AS sort_order, 'Elementary' AS level, impact.impact_created
                                                                           FROM _cpo.impact
                                                                      JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                                 JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                            JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                                       JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                                        UNION 
                                                                 SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_6 AS student_count, '6' AS grade, 8 AS sort_order, 'Middle School' AS level, impact.impact_created
                                                                   FROM _cpo.impact
                                                              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                                    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                               JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                                UNION 
                                                         SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_7 AS student_count, '7' AS grade, 9 AS sort_order, 'Middle School' AS level, impact.impact_created
                                                           FROM _cpo.impact
                                                      JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                                 JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                            JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                                       JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                        UNION 
                                                 SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_8 AS student_count, '8' AS grade, 10 AS sort_order, 'Middle School' AS level, impact.impact_created
                                                   FROM _cpo.impact
                                              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                                    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                               JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                                UNION 
                                         SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_9 AS student_count, '9' AS grade, 11 AS sort_order, 'High School' AS level, impact.impact_created
                                           FROM _cpo.impact
                                      JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                                 JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                            JOIN addr ON cntct.cntct_addr_id = addr.addr_id
                       JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                        UNION 
                                 SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_10 AS student_count, '10' AS grade, 12 AS sort_order, 'High School' AS level, impact.impact_created
                                   FROM _cpo.impact
                              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
                    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
               JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
                UNION 
                         SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_11 AS student_count, '11' AS grade, 13 AS sort_order, 'High School' AS level, impact.impact_created
                           FROM _cpo.impact
                      JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
                 JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
            JOIN addr ON cntct.cntct_addr_id = addr.addr_id
       JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode)
        UNION 
                 SELECT custinfo.cust_id, custinfo.cust_number, custinfo.cust_name, zipcodes.zipcodes_county, zipcodes.zipcodes_state, impact.impact_students_12 AS student_count, '12' AS grade, 14 AS sort_order, 'High School' AS level, impact.impact_created
                   FROM _cpo.impact
              JOIN custinfo ON impact.impact_cust_id = custinfo.cust_id
         JOIN cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
    JOIN addr ON cntct.cntct_addr_id = addr.addr_id
   JOIN _asset.zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode) aquery
   JOIN ( SELECT impact.impact_cust_id, max(impact.impact_created) AS maxcreationdate
           FROM _cpo.impact
          GROUP BY impact.impact_cust_id) maxdate ON aquery.cust_id = maxdate.impact_cust_id AND aquery.impact_created = maxdate.maxcreationdate
  ORDER BY aquery.cust_id, aquery.sort_order;

ALTER TABLE _report.student_count OWNER TO "admin";
GRANT ALL ON TABLE _report.student_count TO "admin";
GRANT ALL ON TABLE _report.student_count TO xtrole;
GRANT ALL ON TABLE _report.student_count TO public;
COMMENT ON VIEW _report.student_count IS 'Used by Customer Dashboard Report';


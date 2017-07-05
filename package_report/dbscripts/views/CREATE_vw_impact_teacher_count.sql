-- View: _report.impact_teacher_count

-- DROP VIEW _report.impact_teacher_count;

CREATE OR REPLACE VIEW _report.impact_teacher_count AS 
 SELECT unp.impact_teacher_cust_id,
    custinfo.cust_name,
    zipcodes.zipcodes_county,
    zipcodes.zipcodes_state,
        CASE unp.grade
            WHEN 'impact_teachers_pre_k'::text THEN 'PreK'::text
            WHEN 'impact_teachers_kindergarten'::text THEN 'K'::text
            WHEN 'impact_teachers_1'::text THEN '1'::text
            WHEN 'impact_teachers_2'::text THEN '2'::text
            WHEN 'impact_teachers_3'::text THEN '3'::text
            WHEN 'impact_teachers_4'::text THEN '4'::text
            WHEN 'impact_teachers_5'::text THEN '5'::text
            WHEN 'impact_teachers_6'::text THEN '6'::text
            WHEN 'impact_teachers_7'::text THEN '7'::text
            WHEN 'impact_teachers_8'::text THEN '8'::text
            WHEN 'impact_teachers_9'::text THEN '9'::text
            WHEN 'impact_teachers_10'::text THEN '10'::text
            WHEN 'impact_teachers_11'::text THEN '11'::text
            WHEN 'impact_teachers_12'::text THEN '12'::text
            ELSE NULL::text
        END AS grade,
        CASE unp.grade
            WHEN 'impact_teachers_pre_k'::text THEN 'Early Childhood'::text
            WHEN 'impact_teachers_kindergarten'::text THEN 'Early Childhood'::text
            WHEN 'impact_teachers_1'::text THEN 'Elementary'::text
            WHEN 'impact_teachers_2'::text THEN 'Elementary'::text
            WHEN 'impact_teachers_3'::text THEN 'Elementary'::text
            WHEN 'impact_teachers_4'::text THEN 'Elementary'::text
            WHEN 'impact_teachers_5'::text THEN 'Elementary'::text
            WHEN 'impact_teachers_6'::text THEN 'Middle School'::text
            WHEN 'impact_teachers_7'::text THEN 'Middle School'::text
            WHEN 'impact_teachers_8'::text THEN 'Middle School'::text
            WHEN 'impact_teachers_9'::text THEN 'High School'::text
            WHEN 'impact_teachers_10'::text THEN 'High School'::text
            WHEN 'impact_teachers_11'::text THEN 'High School'::text
            WHEN 'impact_teachers_12'::text THEN 'High School'::text
            ELSE NULL::text
        END AS level,
    unp.teachercount,
        CASE unp.grade
            WHEN 'impact_teachers_pre_k'::text THEN 1
            WHEN 'impact_teachers_kindergarten'::text THEN 2
            WHEN 'impact_teachers_1'::text THEN 3
            WHEN 'impact_teachers_2'::text THEN 4
            WHEN 'impact_teachers_3'::text THEN 5
            WHEN 'impact_teachers_4'::text THEN 6
            WHEN 'impact_teachers_5'::text THEN 7
            WHEN 'impact_teachers_6'::text THEN 8
            WHEN 'impact_teachers_7'::text THEN 9
            WHEN 'impact_teachers_8'::text THEN 10
            WHEN 'impact_teachers_9'::text THEN 11
            WHEN 'impact_teachers_10'::text THEN 12
            WHEN 'impact_teachers_11'::text THEN 13
            WHEN 'impact_teachers_12'::text THEN 14
            ELSE NULL::integer
        END AS sortorder,
    unp.impact_teacher_created,
    unp.impact_teacher_total AS totalteachers
   FROM ( SELECT impact.impact_teacher_cust_id,
            unnest(ARRAY['impact_teachers_pre_k'::text, 'impact_teachers_kindergarten'::text, 'impact_teachers_1'::text, 'impact_teachers_2'::text, 'impact_teachers_3'::text, 'impact_teachers_4'::text, 'impact_teachers_5'::text, 'impact_teachers_6'::text, 'impact_teachers_7'::text, 'impact_teachers_8'::text, 'impact_teachers_9'::text, 'impact_teachers_10'::text, 'impact_teachers_11'::text, 'impact_teachers_12'::text]) AS grade,
            unnest(ARRAY[impact.impact_teacher_teacher_pre_k, impact.impact_teacher_teacher_kindergarten, impact.impact_teacher_teacher_1, impact.impact_teacher_teacher_2, impact.impact_teacher_teacher_3, impact.impact_teacher_teacher_4, impact.impact_teacher_teacher_5, impact.impact_teacher_teacher_6, impact.impact_teacher_teacher_7, impact.impact_teacher_teacher_8, impact.impact_teacher_teacher_9, impact.impact_teacher_teacher_10, impact.impact_teacher_teacher_11, impact.impact_teacher_teacher_12]) AS teachercount,
            impact.impact_teacher_created,
            impact.impact_teacher_total
           FROM _cpo.impact_teacher impact) unp
     JOIN ( SELECT impact_teacher.impact_teacher_cust_id,
            max(impact_teacher.impact_teacher_created) AS maxcreationdate
           FROM _cpo.impact_teacher
          GROUP BY impact_teacher.impact_teacher_cust_id) maxdate ON unp.impact_teacher_cust_id = maxdate.impact_teacher_cust_id AND unp.impact_teacher_created = maxdate.maxcreationdate
     JOIN custinfo custinfo ON unp.impact_teacher_cust_id = custinfo.cust_id
     JOIN cntct cntct ON custinfo.cust_corrcntct_id = cntct.cntct_id
     JOIN addr addr ON cntct.cntct_addr_id = addr.addr_id
     JOIN _asset.zipcodes zipcodes ON addr.addr_postalcode = zipcodes.zipcodes_zipcode
  WHERE custinfo.cust_active = true AND (custinfo.cust_custtype_id <> ALL (ARRAY[26, 35])) AND NOT (custinfo.cust_id = ANY (ARRAY[1476, 6562, 6574, 6959, 9154, 9150, 9152, 9154]));

ALTER TABLE _report.impact_teacher_count
  OWNER TO admin;
GRANT ALL ON TABLE _report.impact_teacher_count TO admin;
GRANT ALL ON TABLE _report.impact_teacher_count TO xtrole;
GRANT SELECT, REFERENCES ON TABLE _report.impact_teacher_count TO public;
COMMENT ON VIEW _report.impact_teacher_count
  IS 'used by impact report';

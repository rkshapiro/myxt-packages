-- View: _report.impact_student_count

-- DROP VIEW _report.impact_student_count;

CREATE OR REPLACE VIEW _report.impact_student_count AS 

SELECT 
	unp.impact_cust_id,
	cust_name, 
	zipcodes_county, 
	zipcodes_state, 
	CASE grade
		WHEN 'impact_students_pre_k' THEN 'PreK' 
		WHEN 'impact_students_kindergarten' THEN 'K' 
		WHEN 'impact_students_1' THEN '1' 
		WHEN 'impact_students_2' THEN '2' 
		WHEN 'impact_students_3' THEN '3' 
		WHEN 'impact_students_4' THEN '4' 
		WHEN 'impact_students_5' THEN '5' 
		WHEN 'impact_students_6' THEN '6' 
		WHEN 'impact_students_7' THEN '7' 
		WHEN 'impact_students_8' THEN '8' 
		WHEN 'impact_students_9' THEN '9' 
		WHEN 'impact_students_10' THEN '10'
		WHEN 'impact_students_11' THEN '11' 
		WHEN 'impact_students_12' THEN '12' 
	END AS grade,
	CASE grade 
		WHEN 'impact_students_pre_k' THEN 'Early Childhood' 
		WHEN 'impact_students_kindergarten' THEN 'Early Childhood' 
		WHEN 'impact_students_1' THEN 'Elementary' 
		WHEN 'impact_students_2' THEN 'Elementary' 
		WHEN 'impact_students_3' THEN 'Elementary' 
		WHEN 'impact_students_4' THEN 'Elementary'
		WHEN 'impact_students_5' THEN 'Elementary' 
		WHEN 'impact_students_6' THEN 'Middle School' 
		WHEN 'impact_students_7' THEN 'Middle School' 
		WHEN 'impact_students_8' THEN 'Middle School' 
		WHEN 'impact_students_9' THEN 'High School' 
		WHEN 'impact_students_10' THEN 'High School' 
		WHEN 'impact_students_11' THEN 'High School' 
		WHEN 'impact_students_12' THEN 'High School' 
	END AS LEVEL,
	studentCount,
	CASE grade 
		WHEN 'impact_students_pre_k' THEN 1 
		WHEN 'impact_students_kindergarten' THEN 2 
		WHEN 'impact_students_1' THEN 3 
		WHEN 'impact_students_2' THEN 4 
		WHEN 'impact_students_3' THEN 5 
		WHEN 'impact_students_4' THEN 6 
		WHEN 'impact_students_5' THEN 7 
		WHEN 'impact_students_6' THEN 8
		WHEN 'impact_students_7' THEN 9 
		WHEN 'impact_students_8' THEN 10 
		WHEN 'impact_students_9' THEN 11 
		WHEN 'impact_students_10' THEN 12 
		WHEN 'impact_students_11' THEN 13 
		WHEN 'impact_students_12' THEN 14 
	END AS sortOrder,
	impact_created, 
	impact_students_in_district AS TotalStudents
FROM
(
	select 
		impact_cust_id,
		unnest(
			ARRAY[
			'impact_students_pre_k', 
			'impact_students_kindergarten', 
			'impact_students_1', 
			'impact_students_2', 
			'impact_students_3', 
			'impact_students_4', 
			'impact_students_5', 
			'impact_students_6', 
			'impact_students_7', 
			'impact_students_8', 
			'impact_students_9', 
			'impact_students_10', 
			'impact_students_11', 
			'impact_students_12']
			) as grade,
		unnest(
			ARRAY[impact_students_pre_k, 
			impact_students_kindergarten, 
			impact_students_1, 
			impact_students_2, 
			impact_students_3, 
			impact_students_4, 
			impact_students_5, 
			impact_students_6, 
			impact_students_7, 
			impact_students_8, 
			impact_students_9, 
			impact_students_10, 
			impact_students_11, 
			impact_students_12]
			) as studentCount,
		impact_created,
		impact_students_in_district
	from _report.impact impact
 ) unp
 INNER JOIN
	(SELECT        
		impact.impact_cust_id, 
		max(impact.impact_created) AS maxcreationdate
	 FROM            
		_report.impact
	 GROUP BY 
		impact.impact_cust_id
	) AS maxdate ON unp.impact_cust_id = maxdate.impact_cust_id 
		AND unp.impact_created = maxdate.maxcreationdate 
INNER JOIN
	 public.custinfo custinfo 
		ON unp.impact_cust_id = custinfo.cust_id 
INNER JOIN
	 public.cntct cntct 
		ON custinfo.cust_corrcntct_id = cntct.cntct_id 
INNER JOIN
	 public.addr addr 
		ON cntct.cntct_addr_id = addr.addr_id
INNER JOIN
	 _asset.zipcodes zipcodes 
		ON addr.addr_postalcode::text = zipcodes.zipcodes_zipcode::text
WHERE        
	custinfo.cust_active = '1' 
	AND (custinfo.cust_custtype_id NOT IN (26, 35));


ALTER TABLE _report.impact_student_count OWNER TO "admin";
GRANT ALL ON TABLE _report.impact_student_count TO "admin";
GRANT ALL ON TABLE _report.impact_student_count TO xtrole;
GRANT SELECT, REFERENCES ON TABLE _report.impact_student_count TO public;
COMMENT ON VIEW _report.impact_student_count IS 'used by membership renewal update report';

-- View: salesline_rental_period

-- DROP VIEW salesline_rental_period;

CREATE OR REPLACE VIEW salesline_rental_period AS 
 SELECT charass.charass_target_id AS salesline_coitem_id, charass.charass_value AS rental_period, 
        CASE
            WHEN charass.charass_value = 'QTR'::text OR charass.charass_value = '9 weeks'::TEXT THEN 9 * 7
            WHEN charass.charass_value = 'TRI'::text OR charass.charass_value = '12 weeks'::TEXT THEN 12 * 7
            WHEN charass.charass_value ~ 'SEM'::text OR charass.charass_value = '18 weeks'::TEXT THEN 18 * 7
            WHEN charass.charass_value ~ 'YEAR'::text OR charass.charass_value = '40 weeks'::TEXT THEN 40 * 7
            ELSE 63
        END AS rental_duration
   FROM charass
   JOIN "char" ON charass.charass_char_id = "char".char_id
  WHERE "char".char_name = 'RENTAL PERIOD'::text AND charass.charass_target_type = 'SI'::text;

ALTER TABLE salesline_rental_period OWNER TO mfgadmin;
GRANT ALL ON TABLE salesline_rental_period TO mfgadmin;
GRANT ALL ON TABLE salesline_rental_period TO xtrole;
COMMENT ON VIEW salesline_rental_period IS 'used by auto-return authorization process';


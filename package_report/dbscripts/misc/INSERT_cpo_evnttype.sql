DELETE FROM evnttype WHERE evnttype_name = 'CPOCustProfileSubmitted';

INSERT INTO evnttype (evnttype_name, evnttype_descrip, evnttype_module)
VALUES ('CPOCustProfileSubmitted', 'User has submitted their profile through Customer Profile Online.', 'report');
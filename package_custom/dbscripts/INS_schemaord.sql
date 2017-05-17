DELETE FROM schemaord WHERE schemaord_name = '_custom';
INSERT INTO schemaord(schemaord_name, schemaord_order)
    VALUES ('_custom', 40);

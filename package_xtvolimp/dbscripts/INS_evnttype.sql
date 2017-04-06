DELETE FROM evnttype WHERE evnttype_name = 'SOImportComplete';
INSERT INTO evnttype(
            evnttype_name, evnttype_descrip, evnttype_module)
    VALUES ('SOImportComplete', 'Volusion Sales Order Import Complete', 'S/O');

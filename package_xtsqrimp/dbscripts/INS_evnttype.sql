DELETE FROM evnttype WHERE evnttype_name = 'SqrImportComplete';
INSERT INTO evnttype(
            evnttype_name, evnttype_descrip, evnttype_module)
    VALUES ('SqrImportComplete', 'Square Import Complete', 'S/O');

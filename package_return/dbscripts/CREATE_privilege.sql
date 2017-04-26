-- change the privilege to be in the _return package
DELETE FROM priv WHERE priv_name = 'ViewPendingReturn';
INSERT INTO priv(priv_module, priv_name, priv_descrip)
VALUES ('_return', 'ViewPendingReturn', 'Allowed to view ViewPendingReturn');

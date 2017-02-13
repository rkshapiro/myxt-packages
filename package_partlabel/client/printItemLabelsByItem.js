
  /*
This file is part of the xtmfg Package for xTuple ERP,
and is Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.  It
is licensed to you under the xTuple End-User License Agreement ("the
EULA"), the full text of which is available at www.xtuple.com/EULA.
While the EULA gives you access to source code and encourages your
involvement in the development process, this Package is not free
software.  By using this software, you agree to be bound by the
terms of the EULA.
*/

debugger;

_print = mywindow.findChild("_print");
_item  = mywindow.findChild("_item");
_close = mywindow.findChild("_close");
_report = mywindow.findChild("_report");

_report.populate("SELECT labelform_id, labelform_name,* FROM labelform ORDER BY 2;");
_print.clicked.connect(print);
_close.clicked.connect(mywindow,"close");


function print()
{
	var params = new Object;
    params.form_id = _report.id();
    var qry = toolbox.executeQuery("SELECT labelform_report_name AS report_name "
                                +"  FROM labelform "
                                +" WHERE((labelform_id=<? value('form_id') ?>) );", params);

	if (qry.first())
	{
        var params2 = new Object;
        params2.itemid = _item.id();

        var qry2 = toolbox.executeQuery("SELECT 1 FROM item WHERE item_id = <? value('itemid') ?>",params2);
		toolbox.printReport(qry.value("report_name"), params2);
	}
	else
	{
		QMessageBox.critical(mywindow, qsTr("Cannot Print Item Label"),
                       qsTr("Could not locate the label form report definition '%1'.").arg(_report.currentText));
	}
}
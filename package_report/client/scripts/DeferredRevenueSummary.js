/* This file is part of the Registration Management Package for xTuple ERP, and is
 * Copyright (c) 1999-2015 by OpenMFG LLC, d/b/a xTuple.
 * It is licensed to you under the xTuple End-User License Agreement
 * ("the EULA"), the full text of which is available at www.xtuple.com/EULA
 * While the EULA gives you access to source code and encourages your
 * involvement in the development process, this Package is not free software.
 * By using this software, you agree to be bound by the terms of the EULA.
 */
debugger;

//include("regmgmt");
//regmgmt.dspDeferredRevenueSummary = new Object;

var 	_dates = mywindow.findChild("_dates");
	_dates.setStartNull(qsTr("Earliest"),mainwindow.startOfTime(),true);
	_dates.setEndNull(qsTr("Latest"),mainwindow.endOfTime(),true);

function getParams()
{
	var params = new Object;
	params.startDate = _dates.startDate;
	params.endDate   = _dates.endDate;
	return params;
}

function query()
{
	var params = getParams();
	var qry = toolbox.executeDbQuery("AAA_ASSET","deferredRevenueSummary",params);
	mywindow.findChild("_list").populate(qry);
}

function tick()
{
	if(mywindow.findChild("_update").checked)
	{
		query();
	}
}


	mywindow.findChild("_close").clicked.connect(mywindow,"close");
	mywindow.findChild("_query").clicked.connect(mywindow,query);
	mywindow.findChild("_print").clicked.connect(mywindow,print);
	mainwindow.tick.connect(tick);
	var list = mywindow.findChild("_list");


	list.addColumn("Cust Id",75,    1,   false,  "cust_id"   );
  	list.addColumn("Cust Number", 100,    1,   true,  "cust_number"  );
  	list.addColumn("Cust Name",  -1,     1, true,  "cust_name" );
  	list.addColumn("Start Balance", 100,    1, true,  "startbalance" );
  	list.addColumn("Period Cash", 100,    1,   true,  "periodcash"  );
  	list.addColumn("Period Registrations", 200,    1,   true,  "periodregistrations" );
  	list.addColumn("End Balance", 100,  1,   true,  "endbalance"  );
	

/*try
{


  mywindow.setWindowTitle(qsTr("Deferred Revenue Summary"));
  mywindow.setListLabel(qsTr("Summary"));
  mywindow.setMetaSQLOptions("AAA_ASSET", "deferredRevenueSummary");
  mywindow.setParameterWidgetVisible(true);


		
  mywindow.parameterWidget().append(qsTr("Period Start"), "bopd" , ParameterWidget.Date); 
  mywindow.parameterWidget().append(qsTr("Period End"), "eopd", ParameterWidget.Date); 
  
  
  mywindow.list().addColumn(qsTr("Cust Id"), XTreeWidget.orderColumn,    Qt.AlignLeft,   false,  "cust_id"   );
  mywindow.list().addColumn(qsTr("Cust Number"), XTreeWidget.orderColumn,    Qt.AlignLeft,   true,  "cust_number"  );
  mywindow.list().addColumn(qsTr("Cust Name"),  XTreeWidget.orderColumn,     Qt.AlignLeft, true,  "cust_name" );
  mywindow.list().addColumn(qsTr("Start Balance"), XTreeWidget.qtyColumn,    Qt.AlignLeft, true,  "startbalance" );
  mywindow.list().addColumn(qsTr("Period Cash"), XTreeWidget.qtyColumn,    Qt.AlignLeft,   true,  "periodcash"  );
  mywindow.list().addColumn(qsTr("Period Registrations"), XTreeWidget.qtyColumn,    Qt.AlignLeft,   true,  "periodregistrations" );
  mywindow.list().addColumn(qsTr("End Balance"), -1,  Qt.AlignLeft,   true,  "endbalance"  );


  
  

//  mywindow.setUseAltId(true);
}
catch (e)
{
  QMessageBox.critical(mywindow, "dspDeferredRevenueSummary",
                       "dspDeferredRevenueSummary.js exception: " + e);  
} */

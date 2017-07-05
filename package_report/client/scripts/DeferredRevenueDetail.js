/* This file is part of the Registration Management Package for xTuple ERP, and is
 * Copyright (c) 1999-2015 by OpenMFG LLC, d/b/a xTuple.
 * It is licensed to you under the xTuple End-User License Agreement
 * ("the EULA"), the full text of which is available at www.xtuple.com/EULA
 * While the EULA gives you access to source code and encourages your
 * involvement in the development process, this Package is not free software.
 * By using this software, you agree to be bound by the terms of the EULA.
 */
debugger;


	var 	_dates = mywindow.findChild("_dates");
	_dates.setStartNull(qsTr("Earliest"),mainwindow.startOfTime(),true);
	_dates.setEndNull(qsTr("Latest"),mainwindow.endOfTime(),true);

function getParams()
{
	var params = new Object;

        if(mywindow.findChild("_cust").id() > 0)
		{	
	params.cust_id = mywindow.findChild("_cust").id();
		} 
	
	params.startDate = _dates.startDate;
	params.endDate   = _dates.endDate;
	return params;
}
	
	

function query()
{
	var params = getParams();
	
	var qry = toolbox.executeDbQuery("AAA_ASSET","deferredRevenueDetail",params);
	
	mywindow.findChild("_list").populate(qry);
}

	mywindow.findChild("_close").clicked.connect(mywindow,"close");
	mywindow.findChild("_query").clicked.connect(mywindow,query);
	var list = mywindow.findChild("_list");




	list.addColumn("Cust Id", 50,    1,     false,  "def_revenue_detail_cust_id"   );
  	list.addColumn("Cust Number", 100,    1, true,  "def_revenue_detail_cust_number"  );
	list.addColumn("Cust Name",  -1,    1, true,  "def_revenue_detail_cust_name" );
	list.addColumn("Source",  150,    1, true,  "def_revenue_detail_source" );
	list.addColumn("Doc #",  100,     1, true,  "def_revenue_detail_doc_number" );
  	list.addColumn("Doc Date",  100,     1, true,  "def_revenue_detail_doc_date" );
 	list.addColumn("Doc Type",  100,     1, true,  "def_revenue_detail_doc_type" );
 	list.addColumn("Registered",  100,     1, true,  "def_revenue_detail_registered" );
  	list.addColumn("Amount",  100,     1, true,  "def_revenue_detail_amount" );
  	list.addColumn("Description",  -1,    1, true,  "def_revenue_detail_description" );
  	list.addColumn("Project",  65,     1, true,  "def_revenue_detail_prj_number" );

        

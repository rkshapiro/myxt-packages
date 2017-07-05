/* This file is part of the Registration Management Package for xTuple ERP, and is
 * Copyright (c) 1999-2015 by OpenMFG LLC, d/b/a xTuple.
 * It is licensed to you under the xTuple End-User License Agreement
 * ("the EULA"), the full text of which is available at www.xtuple.com/EULA
 * While the EULA gives you access to source code and encourages your
 * involvement in the development process, this Package is not free software.
 * By using this software, you agree to be bound by the terms of the EULA.
 */
debugger;


	var _cust = mywindow.findChild("_cust");
	

function getParams()
{
	var params = new Object;
	params.cust_id = _cust.id();
	return params;
}
	
	

function query()
{
	var params = getParams();
	
	var qry = toolbox.executeDbQuery("AAA_ASSET","PDStatement",params);
	
	mywindow.findChild("_list").populate(qry);
}

function print()
{
	toolbox.printReport("AAA_ASSET_PDStatement",getParams());
}

	mywindow.findChild("_close").clicked.connect(mywindow,"close");
	mywindow.findChild("_query").clicked.connect(query);
	mywindow.findChild("_print").clicked.connect(print);
	var list = mywindow.findChild("_list");



        list.addColumn("Doc Id", 		XTreeWidget.orderColumn,    	Qt.AlignLeft,   false,  "pd_statement_doc_id"   );
  	list.addColumn("Doc #",  		XTreeWidget.orderColumn, 	Qt.AlignLeft,   true,  "pd_statement_doc_number"   );
  	list.addColumn("Cust Id", 		XTreeWidget.orderColumn,    	Qt.AlignLeft,   false,  "pd_statement_cust_id"   );
  	list.addColumn("Cust Number", 	XTreeWidget.orderColumn,    	Qt.AlignLeft,   true,  "pd_statement_cust_number"  );
  	list.addColumn("Cust Name",  	-1,    	Qt.AlignLeft, true,  "pd_statement_cust_name" );
 	list.addColumn("Doc Date", 		XTreeWidget.dateColumn,     	Qt.AlignLeft, true,  "pd_statement_doc_date" );
  	list.addColumn("Registered", 	XTreeWidget.orderColumn,    	Qt.AlignLeft,   true,  "pd_statement_registered"  );
  	list.addColumn("Doc Type", 		XTreeWidget.orderColumn,    	Qt.AlignLeft,   true,  "pd_statement_doc_type"  );
	list.addColumn("Amount", 		XTreeWidget.orderColumn,    	Qt.AlignCenter,true,  "pd_statement_amount"  ); 
  	list.addColumn("Sort Order", 		XTreeWidget.orderColumn,    	Qt.AlignCenter,false,  "pd_statement_ord"  ); 
  	list.addColumn("Description", 	-2,    	Qt.AlignLeft,   true,  "pd_statement_description"  );
  	list.addColumn("Project ID", 	XTreeWidget.orderColumn,    	Qt.AlignLeft,   false,  "pd_statement_prj_id"  );
  	list.addColumn("Project", 		XTreeWidget.orderColumn,    	Qt.AlignLeft,   true,  "pd_statement_prj_number"  );
	


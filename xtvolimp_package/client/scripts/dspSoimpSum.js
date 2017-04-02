debugger; 
// Window Title
mywindow.setWindowTitle(qsTr("Display Web Orders"));
// Specificy which query to use
mywindow.setMetaSQLOptions('WEB','DisplaySummarizedSOIMP');

// Set automatic query on start
mywindow.setQueryOnStartEnabled(false);
var _queryBtn = mywindow.findChild("_queryBtn");
_queryBtn.clicked.connect(queryclick);

// Set automatic query on start
mywindow.setAutoUpdateEnabled(true);

// Make the search visible
mywindow.setSearchVisible(true);

// Alt ID
mywindow.setUseAltId(true);

// Add in the columns
var _list = mywindow.list();

_list.addColumn(qsTr("Order Number"), -1, Qt.AlignLeft, true, "soimp_order_number");
_list.addColumn(qsTr("Item Number"), -1, Qt.AlignLeft, true, "soimp_item_number");
_list.addColumn(qsTr("Errors"), -1, Qt.AlignLeft, true, "error_msg");
_list.addColumn(qsTr("Customer"), -1, Qt.AlignLeft, true, "soimp_customer_number");
_list.addColumn(qsTr("Billto First"), -1, Qt.AlignLeft, true, "soimp_billto_cntct_first_name");
_list.addColumn(qsTr("Billto Last"), -1, Qt.AlignLeft, true, "soimp_billto_cntct_last_name");
_list.addColumn(qsTr("Billto Phone"), -1, Qt.AlignLeft, true, "soimp_billto_cntct_phone");
_list.addColumn(qsTr("Order Notes"), -1, Qt.AlignLeft, true, "soimp_delivery_note");
_list.addColumn(qsTr("Source"), -1, Qt.AlignLeft, true, "soimp_source");

// Add filter criteria
// This says we want to use the parameter widget to filter results

mywindow.setParameterWidgetVisible(true);

// gets called when the user right clicks on a line item 

function populateMenu(pMenu, selected, column) 

{ 
   //if (_list.id() == "") { return; } 
   var menuItem1 = pMenu.addAction(qsTr("Delete SO Pending Import"), privileges.check("MaintainSalesOrders")); 
   pMenu.addSeparator(); 
    menuItem1.triggered.connect(deleteSo); 
    pMenu.addSeparator(); 
} 

function deleteSo() 
{ 
  var params = new Object; 
  params.soimp_id =_list.altId(); 
  qry = toolbox.executeDbQuery("WEB", "DeleteSoimpOrder", params);
  mywindow.sFillList();

}

_list["populateMenu(QMenu*,XTreeWidgetItem*,int)"].connect(populateMenu); 


// ADD BUTTON TO MANUALY RUN IMPORT

var _list = mywindow.findChild("_list");

var layout = mywindow.findChild("_toolBar");
var newbutton1 = toolbox.createWidget("QPushButton", mywindow, "_importButton");
newbutton1.text="Manual Volusion Import";
if (layout) {
layout.addWidget(newbutton1);
newbutton1.clicked.connect(manualClickedWeb);
}

function manualClickedWeb()
{
if (_list) {
// _list.expandAll();
var params = new Object;
qry = toolbox.executeDbQuery("WEB", "ImportSOsFromSoimp", params);
QMessageBox.warning(mywindow, "Volusion Import Complete", "Import Complete. Please click Query to see errors and Open Sales Order for new orders.");
mywindow.sFillList();
}
}

function queryclick()
{
   var params = new Object;
   qry = toolbox.executeDbQuery("WEB", "DisplaySummarizedSOIMP", params);
   if (qry.size() == 0){
       QMessageBox.warning(mywindow, "No Errors", "Import Complete. See Open Sales Order for new orders.");
	}
}

mywindow.parameterWidget().append(qsTr("Customer"), "cust_id", ParameterWidget.Customer);
mywindow.parameterWidget().append(qsTr("Item"), "item_id", ParameterWidget.Item);

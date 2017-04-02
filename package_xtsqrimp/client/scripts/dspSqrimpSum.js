debugger; 
// dspSqrimpSum
// Window Title
mywindow.setWindowTitle(qsTr("Display Square Import Errors"));
// Specificy which query to use
mywindow.setMetaSQLOptions('WEB','DisplaySummarizedSqrIMP');

// Set automatic query on start
mywindow.setQueryOnStartEnabled(false);
var _queryBtn = mywindow.findChild("_queryBtn");
_queryBtn.clicked.connect(queryclick);

// Set automatic query on start
mywindow.setAutoUpdateEnabled(true);

// Make the search visible
//mywindow.setSearchVisible(true);

// Alt ID
mywindow.setUseAltId(true);

// Add in the columns
var _list = mywindow.list();

_list.addColumn(qsTr("Invoice Number"), -1, Qt.AlignLeft, true, "sqrimp_invcnum");
_list.addColumn(qsTr("Item Number"), -1, Qt.AlignLeft, true, "sqrimp_pricepointname");
_list.addColumn(qsTr("Item Description"), -1, Qt.AlignLeft, true, "sqrimp_item");
_list.addColumn(qsTr("Errors"), -1, Qt.AlignLeft, true, "sqrimp_status");
_list.addColumn(qsTr("Invoice Date"), -1, Qt.AlignLeft, true, "sqrimp_date");
_list.addColumn(qsTr("Quantity"), -1, Qt.AlignLeft, true, "sqrimp_qty");
_list.addColumn(qsTr("Gross Sales"), -1, Qt.AlignLeft, true, "sqrimp_grosssales");
_list.addColumn(qsTr("Discounts"), -1, Qt.AlignLeft, true, "sqrimp_discounts");
_list.addColumn(qsTr("Net Sales"), -1, Qt.AlignLeft, true, "sqrimp_netsales");
_list.addColumn(qsTr("Tax"), -1, Qt.AlignLeft, true, "sqrimp_tax");

// Add filter criteria
// This says we want to use the parameter widget to filter results

//mywindow.setParameterWidgetVisible(true);

// gets called when the user right clicks on a line item 

function populateMenu(pMenu, selected, column) 

{ 
   //if (_list.id() == "") { return; } 
   var menuItem1 = pMenu.addAction(qsTr("Delete Square Import Error"), privileges.check("EditAROpenItem")); 
   pMenu.addSeparator(); 
    menuItem1.triggered.connect(deleteError); 
    pMenu.addSeparator(); 
} 

function deleteError() 
{ 
  var params = new Object; 
  params.soimp_id =_list.altId(); 
  qry = toolbox.executeDbQuery("WEB", "DeleteSqrimpError", params);
  mywindow.sFillList();

}

_list["populateMenu(QMenu*,XTreeWidgetItem*,int)"].connect(populateMenu); 


// ADD BUTTON TO MANUALY RUN IMPORT

/*var _list = mywindow.findChild("_list");

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
}*/

function queryclick()
{
   var params = new Object;
   qry = toolbox.executeDbQuery("WEB", "DisplaySummarizedSqrIMP", params);
   if (qry.size() == 0){
       QMessageBox.warning(mywindow, "No Errors", "See the AR Workbench for Invoice, Credit Memo, and Cash Receipt to be posted.");
	}
}

//mywindow.parameterWidget().append(qsTr("Customer"), "cust_id", ParameterWidget.Customer);
//mywindow.parameterWidget().append(qsTr("Item"), "item_id", ParameterWidget.Item);

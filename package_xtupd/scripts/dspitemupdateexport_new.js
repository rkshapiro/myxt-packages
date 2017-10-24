debugger; 
// Window Title
mywindow.setWindowTitle(qsTr("Export Items for Update"));
// Specificy which query to use
mywindow.setMetaSQLOptions('xtupd','itemupdateexport');

// Set automatic query on start
mywindow.setQueryOnStartEnabled(false);

// Set automatic query on start
mywindow.setAutoUpdateEnabled(true);

// Make the search visible
mywindow.setSearchVisible(true);

// Alt ID
mywindow.setUseAltId(true);

// Add in the columns
var _list = mywindow.list();
_list.addColumn(qsTr("Item Number"), -1, Qt.AlignLeft, true, "item_number");
_list.addColumn(qsTr("Description Line 1"), -1, Qt.AlignLeft, true, "description1");
_list.addColumn(qsTr("Description Line 2"), -1, Qt.AlignLeft, true, "description2");
_list.addColumn(qsTr("Maxmimum Desired Cost"), -1, Qt.AlignLeft, true, "maximum_desired_cost");
_list.addColumn(qsTr("Class Code"), -1, Qt.AlignLeft, true, "class_code");
_list.addColumn(qsTr("Sold"), -1, Qt.AlignLeft, true, "item_is_sold");
_list.addColumn(qsTr("Product Category"), -1, Qt.AlignLeft, true, "product_category");
_list.addColumn(qsTr("List Price"), -1, Qt.AlignLeft, true, "list_price");
_list.addColumn(qsTr("Wholesale Price"), -1, Qt.AlignLeft, true, "list_cost");
_list.addColumn(qsTr("Product Weight"), -1, Qt.AlignLeft, true, "product_weight");
_list.addColumn(qsTr("Packaging Weight"), -1, Qt.AlignLeft, true, "packaging_weight");
_list.addColumn(qsTr("Note"), -1, Qt.AlignLeft, true, "notes");
_list.addColumn(qsTr("Extended Description"), -1, Qt.AlignLeft, true, "ext_description");

itemupdateexport = new Object;

// Add filter criteria
// This says we want to use the parameter widget to filter results

mywindow.setParameterWidgetVisible(true);

// create variable for the parameter widget
var _pw = mywindow.parameterWidget(); 

// add a class code to the widget. parameters are (displayed option, selected value, list of class codes)
_pw.appendComboBox(qsTr("Class Code"), "classcode_id", XComboBox.ClassCodes);

// add product category to the widget. parameters are (displayed option, selected value, list of class codes)
_pw.appendComboBox(qsTr("Product Category"), "prodcat_id", XComboBox.ProductCategories);

_pw.applyDefaultFilterSet(); 

// capture any parameter widget selections. These will be passed into the metasql
itemupdateexport.getParams = function()
{

var params = _parameterWidget.parameters();

 return params;
}

itemupdateexport.errorCheck = function (q)
{
  if (q.lastError().type != QSqlError.NoError)
  {
    toolbox.messageBox("critical", mywindow,
                        qsTr("Database Error"), q.lastError().text);
    return false;
  }

  return true;
}

// Other parameter widget enumerator values:
// 
// Crmacct User Text Date XComBox Contact Multiselect 
// GLAccount Exists CheckBox Project Customer Site Vendor Item 
// Employee Shipto SalesOrder WorkOrder PurchaseOrder TransferOrder
//
// URL for the Doc: (380):
// http://www.xtuple.org/sites/default/files/dev/380/html/class_parameter_widget.html 
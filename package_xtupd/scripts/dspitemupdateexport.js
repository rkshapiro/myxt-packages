debugger; 
// Window Title
mywindow.setWindowTitle(qsTr("Display Item Update Export"));
// Specificy which query to use
mywindow.setMetaSQLOptions('xtupd','itemupdateexport');

// Set automatic query on start
mywindow.setQueryOnStartEnabled(true);

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

// Add filter criteria
// This says we want to use the parameter widget to filter results

mywindow.setParameterWidgetVisible(true);

_list["populateMenu(QMenu*,XTreeWidgetItem*,int)"].connect(populateMenu); 

mywindow.parameterWidget().applyDefaultFilterSet();

// Other parameter widget enumerator values:
// 
// Crmacct User Text Date XComBox Contact Multiselect 
// GLAccount Exists CheckBox Project Customer Site Vendor Item 
// Employee Shipto SalesOrder WorkOrder PurchaseOrder TransferOrder
//
// URL for the Doc: (380):
// http://www.xtuple.org/sites/default/files/dev/380/html/class_parameter_widget.html 
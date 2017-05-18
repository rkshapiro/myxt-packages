debugger;

try
{
  mywindow.setMetaSQLOptions("items", "detail");

  mywindow.list().addColumn(qsTr("Description Line 1"),XTreeWidget.itemColumn, Qt.AlignLeft,true, "item_descrip1");
  mywindow.list().addColumn(qsTr("Description Line 2"),XTreeWidget.itemColumn, Qt.AlignLeft,true, "item_descrip2");
  mywindow.list().addColumn(qsTr("Maximum Desired Cost "),XTreeWidget.moneyColumn, Qt.AlignLeft,true, "item_maxcost");
  mywindow.list().addColumn(qsTr("Item Is Sold"),XTreeWidget.itemColumn, Qt.AlignLeft,true, "item_sold");
  mywindow.list().addColumn(qsTr("List Price "),XTreeWidget.moneyColumn, Qt.AlignLeft,true, "item_listprice");
  mywindow.list().addColumn(qsTr("Wholesale Price "),XTreeWidget.moneyColumn, Qt.AlignLeft,true, "item_listcost");
  mywindow.list().addColumn(qsTr("Product Weight in LB"),XTreeWidget.qtyColumn, Qt.AlignLeft,true, "item_prodweight");
  mywindow.list().addColumn(qsTr("Package Weight in LB"),XTreeWidget.qtyColumn, Qt.AlignLeft,true, "item_packweight");
  mywindow.list().addColumn(qsTr("Notes"),-1, Qt.AlignLeft,true, "item_comments");
  mywindow.list().addColumn(qsTr("Extended Description"),-1, Qt.AlignLeft,true, "item_extdescrip");
}
catch (e)
{
  QMessageBox.critical(mywindow, "items",
                       "items.js exception: " + e);
}

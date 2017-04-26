//dspInventoryAvailability
//20170403:rks adding planned order and wip quantities

var _list = mywindow.findChild("_list");

_list.addColumn("WIP", XTreeWidget.qtyColumn, Qt.AlignRight, true, "wip");

_list.addColumn("Planned Order", XTreeWidget.qtyColumn, Qt.AlignRight, true, "planord");
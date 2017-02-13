//dspPlannedOrders
//20150211:rek Orbit 803, adding WIP and Returns columns

var _list = mywindow.findChild("_list");

_list.addColumn("Class Code", -1, Qt.AlignLeft, true, "itemClasscode");

_list.addColumn("WIP?", -1, Qt.AlignLeft, true, "wip");

_list.addColumn("Returns?", -1, Qt.AlignLeft, true, "ret");

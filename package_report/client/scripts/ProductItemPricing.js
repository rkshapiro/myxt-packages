debugger;

var _list = mywindow.findChild("_list");
var _item = mywindow.findChild("_item");
var _query = mywindow.findChild("queryButton");
var _print = mywindow.findChild("printButton").clicked.connect(print);;
var _rev = mywindow.findChild("_revision");

_query.clicked.connect(updatePrice);

_list.addColumn("Seq #",      -1, Qt.AlignLeft,  true, "bomdata_bomwork_seqnumber");
_list.addColumn("Item Number",-1, Qt.AlignLeft,  true, "bomdata_item_number");
_list.addColumn("Description",-1, Qt.AlignLeft,  true, "bomdata_itemdescription");
_list.addColumn("Classcode", -1, Qt.AlignCenter, true, "classcode_code");
_list.addColumn("UOM",         -1, Qt.AlignCenter,true, "bomdata_uom_name");
//_list.addColumn("Batch Sz.",   -1, Qt.AlignRight, true, "bomdata_batchsize");
//_list.addColumn("Fxd. Qty.",   -1, Qt.AlignRight, true, "bomdata_qtyfxd");
_list.addColumn("Qty. Per",    -1, Qt.AlignRight, true, "bomdata_qtyper");
//_list.addColumn("Scrap %",   -1, Qt.AlignRight, true, "bomdata_scrap");
//_list.addColumn("Effective",  -1, Qt.AlignCenter,true, "bomdata_effective");
//_list.addColumn("Expires",    -1, Qt.AlignCenter,true, "bomdata_expires");
_list.addColumn("Unit Cost",  -1, Qt.AlignRight, true, "unitcost");
_list.addColumn("Ext. Cost",  -1,Qt.AlignRight, true, "extendedcost");
_list.addColumn("Cost Updated", -1, Qt.AlignRight, true, "itemcost_updated");
_list.addColumn("Current List Price", -1, Qt.AlignRight, true, "currentlistprice");
_list.addColumn("Calculated List Price", -1, Qt.AlignRight, true, "calculatedlistprice");

_updatebutton = mywindow.findChild("pushButton");

_updatebutton.clicked.connect(updatePrice);

_markUp = mywindow.findChild("MarkupLineEdit");
_durableLife = mywindow.findChild("yearsLineEdit");
_useActualCosts = mywindow.findChild("_useActualCosts");

_list["populateMenu(QMenu *, QTreeWidgetItem *, int)"].connect(GridMenuPopulate);


function updatePrice()
{	
	var _useActualCosts = mywindow.findChild("_useActualCosts");
	//var _item = 	mywindow.findChild("_item");	

	var params = new Object;
		params.item_id = _item.id();
		params.markup = _markUp.text
		params.years = _durableLife.text
		params.indentedBOM = 1;
		if(_useActualCosts.checked)
			params.useActualCosts = 1;
		else
    			params.useStandardCosts = 1;

	var qry = toolbox.executeDbQuery("report", "ProductItemPricing", params);

	mywindow.findChild("_list").populate(qry);
	_list.expandAll();
}

function print()
{
	updatePrice();
	var params = new Object;
		params.item_id = _item.id();
		params.markup = _markUp.text
		params.years = _durableLife.text
		params.revision_id = _rev.id();
		if(_useActualCosts.checked)
			params.useActualCosts = 1;
		else
    			params.useStandardCosts = 1;
		
	toolbox.printReport("ProductItemPricingReport", params);
}

function UpdateItemListPrice()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object;
	params.item_id = _item.id();	

	var newdlg = toolbox.openWindow("itemListPrice",0, Qt.WindowModal, Qt.Dialog);
	newdlg.visible = "true";
	var tmp = toolbox.lastWindow().set(params);
	
	var wtf = "weeeeeee";
}

function MaintainItemCosts()
{
	if (_list.id() == -1)
	{
		return;
	}

	//var _item = 	mywindow.findChild("_item");
	var params = new Object;
	params.item_id = _list.id();

	var newdlg = toolbox.openWindow("maintainItemCosts", 0, Qt.WindowModal, Qt.Dialog);
	var tmp = toolbox.lastWindow().set(params);

	var wtf = "weeeeeee";
}

function ViewItemCosting()
{
	if (_list.id() == -1)
	{
		return;
	}

	//var _item = 	mywindow.findChild("_item");
	var params = new Object;
	params.item_id = _list.id();
	params.run = true;

	var newdlg = toolbox.openWindow("dspItemCostSummary", 0, Qt.WindowModal, Qt.Dialog);
	var tmp = toolbox.lastWindow().set(params);

	var wtf = "weeeeeee";
}

function GridMenuPopulate(pMenu, pItem, pCol)
{
	if (_list.id() == -1)
	{
		return;
	}
	
	pMenu.clear();

	var listActmnuView = toolbox.menuAddAction(pMenu, qsTr("Maintain Item Costs..."), true);
	listActmnuView.triggered.connect(MaintainItemCosts);

	var listActmnuView1 = toolbox.menuAddAction(pMenu, qsTr("View Item Costs..."), true);
	listActmnuView1.triggered.connect(ViewItemCosting);

	
		
	var listActmnuView2 = toolbox.menuAddAction(pMenu, qsTr("Update List Price..."), true);
	listActmnuView2.triggered.connect(UpdateItemListPrice);
	
	
	
	
    
}

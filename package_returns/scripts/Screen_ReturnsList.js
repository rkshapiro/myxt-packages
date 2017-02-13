debugger;
var _dates = mywindow.findChild("_dates");
var _item = mywindow.findChild("_item");
var _list = mywindow.findChild("_list");
var _query = mywindow.findChild("_query");
var _sum = mywindow.findChild("_sum");
var _cbIncludeClosed = mywindow.findChild("_cbIncludeClosed");

mywindow.setWindowTitle("Returns List");

mywindow.findChild("_close").clicked.connect(mywindow, "close");
mywindow.findChild("_query").clicked.connect(query);
mywindow.findChild("_print").clicked.connect(print);

_list.addColumn("RA #", 40, 1, true, "authorization_number");
_list.addColumn("Cust #", 80, 1, true, "cust_number");
_list.addColumn("Cust Name", 200, 1, true, "cust_name");
_list.addColumn("Item #", 80, 1, true, "item_number")
_list.addColumn("Item Descr.", 100, 1, true, "item_descrip1")
_list.addColumn("Return Date", 80, 1, true, "return_date");
_list.addColumn("Qty Auth.", 80, 1, true, "raitem_qtyauthorized");
_list.addColumn("Qty Recvd", 80, 1, true, "raitem_qtyreceived");
_list.addColumn("Status", 80, 1, true, "raitem_status");
_list["populateMenu(QMenu *, QTreeWidgetItem *, int)"].connect(GridMenuPopulate);
_list["itemDoubleClicked(QTreeWidgetItem *, int)"].connect(GridRowDoubleClicked);

_dates.setStartVisible(false);
_item.setFocus();

function set(params)
{
  if("item_id" in params)
    _item.setId(params.item_id);  

  _item.setReadOnly(true);

  if (params.enddate != "")
  {
	var _minDate = new Date(params.enddate);
	  _dates.setEndDate(_minDate);
  }

  this.query();
}

function getParams()
{
  var params = new Object;
    
  if (_dates.endDate != "Invalid Date")
    params.cutoff_date     = (_dates.endDate.getMonth() + 1) + "/" + _dates.endDate.getDate() + "/" + (_dates.endDate.getYear() + 1900);
    
params.item_number = _item.itemNumber();				

    return params;
}

function query()
{
	mywindow.findChild("_sum").text = "Total Returns ";
	if(_item.isValid())
	{
  		var params = getParams();
  		var qry = toolbox.executeDbQuery("RETURN", "returns_list", params);
  		mywindow.findChild("_list").populate(qry);

  		var qty = 0;
		if (qry.size() > 0)
		{
  			qry.first();
  
  			qty = qry.value(16);
  			qty = qty - qry.value(18);

  			while (qry.next()) {
	         
        			qty = qty + qry.value(16);
				qty = qty - qry.value(18);         
	
     			}

  			mywindow.findChild("_sum").text = "Total Returns " + qty.toString();
		}
	}
}

function print()
{
	toolbox.printReport("Return_List", getParams());
}

function viewSO()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.rahead_id=_list.id();
	params.mode= "view";
	var newdlg = toolbox.openWindow("returnAuthorization", 0, 0, 0);
	newdlg.set(params);
}

function GridRowDoubleClicked(pItem, pCol)
{
	viewSO();
}

function GridMenuPopulate(pMenu, pItem, pCol)
{
	if (_list.id() == -1)
	{
		return;
	}
	

	var listActmnuView = toolbox.menuAddAction(pMenu, qsTr("View..."), true);
	listActmnuView.triggered.connect(mnuView);

	var listActSep1 = toolbox.menuAddSeparator(pMenu);

    
}


function mnuEdit()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.rahead_id=_list.id();
	params.mode= "view";
	var newdlg = toolbox.openWindow("returnAuthorization", 0, 0, 0);
	newdlg.set(params);
}

function mnuView()
{
	viewSO();
}



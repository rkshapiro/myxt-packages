debugger;
var _dates = mywindow.findChild("_dates");
var _cust = mywindow.findChild("_cust");
var _shipvia = mywindow.findChild("_shipvia");
var _list = mywindow.findChild("_list");
var _cbIncludeClosed = mywindow.findChild("_cbIncludeClosed");

_dates.setStartNull(qsTr("Earliest"), mainwindow.startOfTime(), true);
_dates.setEndNull(qsTr("Latest"),     mainwindow.endOfTime(),   true);

mywindow.findChild("_close").clicked.connect(mywindow, "close");
mywindow.findChild("_query").clicked.connect(query);
mywindow.findChild("_print").clicked.connect(print);

_list.addColumn("Order #", 60, 1, true, "cohead_number");
_list.addColumn("Cust. #", 100, 1, true, "cust_number");
_list.addColumn("Customer", 256, 1, true, "cust_name");
_list.addColumn("Ship-To", 200, 1, true, "cohead_shiptoname")
_list.addColumn("Scheduled", 60, 4, true, "coitem_scheddate")
_list.addColumn("Hold", 40, 1, true, "cohead_holdtype");
_list.addColumn("Ship Via", 200, 1, true, "cohead_shipvia");
_list.addColumn("Status", 60, 4, true, "order_status");
_list["populateMenu(QMenu *, QTreeWidgetItem *, int)"].connect(GridMenuPopulate);
_list["itemDoubleClicked(QTreeWidgetItem *, int)"].connect(GridRowDoubleClicked);

function getParams()
{
  var params = new Object;
    params.startdate   = (_dates.startDate.getMonth() + 1) + "/" + _dates.startDate.getDate() + "/" + (_dates.startDate.getYear() + 1900);
    params.enddate     = (_dates.endDate.getMonth() + 1) + "/" + _dates.endDate.getDate() + "/" + (_dates.endDate.getYear() + 1900);
    if (_cust.id() >= 0)
	{
		params.cust_id = _cust.id();
		params.customer = _cust.name();
	}

	if (_shipvia.id() >= 0)
	{
		params.ShipVia = _shipvia.text;
	}

	if (_cbIncludeClosed.checked)
	{
		params.include_closed = '1';
	}

    return params;
}

function query()
{
  var params = getParams();
  var qry = toolbox.executeDbQuery("RETURN", "detail_logistics", params);
  mywindow.findChild("_list").populate(qry);
}

function print()
{
	toolbox.printReport("Logistics", getParams());
}

function viewSO()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.sohead_id=_list.id();
	params.mode= "view";
	var newdlg = toolbox.openWindow("salesOrder", 0, 0, 0);
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

	var listActmnuEdit = toolbox.menuAddAction(pMenu, qsTr("Edit..."), true);
	listActmnuEdit.triggered.connect(mnuEdit);

	var listActmnuView = toolbox.menuAddAction(pMenu, qsTr("View..."), true);
	listActmnuView.triggered.connect(mnuView);

	var listActSep1 = toolbox.menuAddSeparator(pMenu);

    try
    {
        var enableEDI = false;
        var params = new Object;
        params.sohead_id = _list.id();

        var qry = toolbox.executeQuery("SELECT xtbatch.getEdiProfileId('SO'," + ' <? value("params.sohead_id") ?>) AS result;', params);
        if (qry.first())
		{
			enableEDI = (qry.value("result") >= 0);
		}
        else if (qry.lastError().type != QSqlError.NoError)
		{
			throw new Error(qry.lastError.text);
		}

		var listActmnuSendEmail = toolbox.menuAddAction(pMenu, qsTr("Send Electronic Acknowledgment..."), true);
        listActmnuSendEmail.enabled = enableEDI && (mywindow.checkSitePrivs == null || mywindow.checkSitePrivs());
		listActmnuSendEmail.triggered.connect(mnuSendEmail);
    }
    catch(e)
	{
      QMessageBox.critical(mywindow, qsTr("Processing Error"), e.message());
    }
}


function mnuEdit()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.sohead_id=_list.id();
	params.mode= "edit";
	var newdlg = toolbox.openWindow("salesOrder", 0, 0, 0);
	newdlg.set(params);
}

function mnuView()
{
	viewSO();
}

function mnuSendEmail()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object;
	params.sohead_id = _list.id();

	var newdlg = toolbox.openWindow("submitEDI", mywindow,
									mywindow.windowModality,
									mywindow.windowFlags);
	var tmp    = toolbox.lastWindow().set(params);
	if (tmp == 0)
	{
	  newdlg.exec();
	}
}

debugger;

var _item = mywindow.findChild("_item");
var _list = mywindow.findChild("_list");
var _cut = mywindow.findChild("_cutoff");
var _rad = mywindow.findChild("_rad");
var _top = mywindow.findChild("_top");
var _summary = mywindow.findChild("_summary");
var _cbIncludeClosed = mywindow.findChild("_cbIncludeClosed");

mywindow.findChild("_close").clicked.connect(mywindow, "close");
mywindow.findChild("_query").clicked.connect(query);
mywindow.findChild("_print").clicked.connect(print);
mywindow.findChild("_rad").toggled.connect(query);
mywindow.findChild("_top").toggled.connect(query);

mywindow.setWindowTitle("Returns By Item");

/*_list.addColumn("Child item id", 40, 1, true, "child_item_id");*/
_list.addColumn("Child item #", -1, 1, true, "child_number");
_list.addColumn("Child desc.", -1, 1, true, "child_desc");
/*_list.addColumn("Parent item id", 40, 1, true, "parent_item_id")*/
_list.addColumn("Parent item #", -1, 1, true, "parent_number")
_list.addColumn("Parent desc.", -1, 1, true, "parent_desc");
_list.addColumn("uom", -1, 1, true, "uom_descrip");
_list.addColumn("Qty Req.", -1, 1, true, "bomitem_qtyper");
_list.addColumn("Parent Ret.", -1, 1, true, "returned");
_list.addColumn("Total Ret.", -1, 1, true, "qty_ret");
_list["populateMenu(QMenu *, QTreeWidgetItem *, int)"].connect(GridMenuPopulate);
_list["itemDoubleClicked(QTreeWidgetItem *, int)"].connect(GridRowDoubleClicked);

_cut.setStartVisible(false);
_cut.setEndCaption("Cutoff Date");


function getParams()
{
  var params = new Object;
        
  params.item_number = _item.itemNumber();		

   if (_cut.endDate != "Invalid Date")
   {
	params.cutoff_date = (_cut.endDate.getMonth() + 1) + "/" + _cut.endDate.getDate() + "/" + (_cut.endDate.getYear() + 1900);
   }

    if (_rad.checked)
    {
	params.rad = 0;
    }

    if (_top.checked)
    {
	params.top = 0;	
    }	
		
    return params;
}

function query()
{
	mywindow.findChild("_summary").text = "Total Returns ";
	if(_item.isValid())
	{
	  var params = getParams();
	  var qry = toolbox.executeDbQuery("RETURN", "RA_detail", params);
	  mywindow.findChild("_list").populate(qry);

	  var qty = 0;
	  if (qry.size() > 0)
	  {
	  	qry.first();
  
	  	if (qry.value(6) == 0) /* only use xtindentrole = 0*/
	  	{
  			qty = qry.value(16);
	  	}

	  	while (qry.next()) {
			if (qry.value(6) == 0)
			{         
        	 	qty = qty + qry.value(16);         
			}
     	 	}

		mywindow.findChild("_summary").text = "Total Returns " + qty.toString();
		}
	  }
  
}

function print()
{
	toolbox.printReport("Returns_By_Item", getParams());
}

function viewSO()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.item_id=_list.id();
	if (_cut.endDate != "Invalid Date")
	{
		params.enddate = (_cut.endDate.getMonth() + 1) + "/" + _cut.endDate.getDate() + "/" + (_cut.endDate.getYear() + 1900);
	}
	params.mode= "view";
	var newdlg = toolbox.openWindow("ReturnsList", 0, 0, 0);
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
	var listActmnuBOM = toolbox.menuAddAction(pMenu, qsTr("BOM..."), true);
	listActmnuView.triggered.connect(mnuView);
	listActmnuBOM.triggered.connect(mnuBOM);

	var listActSep1 = toolbox.menuAddSeparator(pMenu);

    
}

function mnuBOM()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.item_id=_list.id();

	params.mode= "view";
	var newdlg = toolbox.openWindow("dspIndentedBOM", 0, 0, 0);
	newdlg.set(params);
}

function mnuView()
{
	viewSO();
}



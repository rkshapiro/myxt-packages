//debugger;

var _so = mywindow.findChild("_so");

var _newReturndate = mywindow.findChild("_newReturndate");
var _item = mywindow.findChild("_item");

var _btnupdate = mywindow.findChild("_btnUpdate");
var _btncancel = mywindow.findChild("_btnCancel");
var _btnquery = mywindow.findChild("_btnQuery");
var _labshipto = mywindow.findChild("_labShipto");


_btnupdate.clicked.connect(changeDate);
_btnquery.clicked.connect(query);
_btncancel.clicked.connect(mywindow.close);

var _list = mywindow.findChild("_list");
_list.addColumn("Coitem Id", 25, 1, false, "salesline_coitem_id");
_list.addColumn("Item Number", 50, 1, true, "item_number");
_list.addColumn("Description", 150, 1, true, "description");
_list.addColumn("Return Date", 25, 1, true, "return_date");

function query()
{
	var qry = toolbox.executeQuery("SELECT salesline_coitem_id,sl.item_number AS item_number,i.item_descrip1 AS description,return_date FROM salesline_return_date sl JOIN item i ON i.item_number = sl.item_number WHERE  order_number = '"
	+ _so.number
	+ "' ORDER BY salesline_coitem_id;");
	
    mywindow.findChild("_list").populate(qry);	
    _labshipto.setText(_so.to().toString());
}

function changeDate()
{
    if (_so.id() <= 0)
    {
    QMessageBox.critical(mywindow, qsTr("Processing Error"), "A Sales Order number is required.  Please try again.");
    return; 
    }

    if (_newReturndate.isNull())
    {
    QMessageBox.critical(mywindow, qsTr("Processing Error"), "Return date is missing.");
    return; 
    }
    
    _snewReturndate = (_newReturndate.date.getMonth()+1) + "/" + _newReturndate.date.getDate() + "/" + _newReturndate.date.getFullYear();
    
    if (_item.id() > 0)
    {

    //var qry = toolbox.executeDbQuery("RETURN", "newReturndate", params);
    var qry = toolbox.executeQuery(
    "UPDATE charass SET charass_value = '" 
    + _snewReturndate 
    + "' WHERE charass_target_type = 'SI' AND charass_char_id = getcharid('RETURN DATE','I') AND charass_target_id IN (SELECT coitem_id FROM cohead JOIN coitem ON coitem_cohead_id = cohead_id JOIN itemsite ON coitem_itemsite_id = itemsite_id JOIN item on itemsite_item_id = item_id WHERE cohead_id = " 
    + _so.id().toString() 
    + " AND coitem_linenumber = (SELECT DISTINCT coitem_linenumber FROM coitem WHERE coitem_cohead_id = cohead_id AND coitem_itemsite_id = getitemsiteid('ASSET1','" 
    + _item.number 
    + "')));");

    // create Return Date Override comment
    var qry2 = toolbox.executeQuery(
    "SELECT postComment('RETURN DATE Override','SI',coitem_id,'"
    + _snewReturndate
    + "') FROM cohead JOIN coitem ON coitem_cohead_id = cohead_id JOIN itemsite ON coitem_itemsite_id = itemsite_id JOIN item on itemsite_item_id = item_id JOIN charass ON charass_target_id = coitem_id AND charass_char_id = getcharid('RETURN DATE','I') WHERE cohead_id = " 
    + _so.id().toString() 
    + " AND coitem_linenumber = (SELECT DISTINCT coitem_linenumber FROM coitem WHERE coitem_cohead_id = cohead_id AND coitem_itemsite_id = getitemsiteid('ASSET1','" 
    + _item.number 
    + "'));");


    } else {

    //var qry = toolbox.executeDbQuery("RETURN", "newReturndate", params);
    var qry = toolbox.executeQuery(
    "UPDATE charass SET charass_value = '" 
    + _snewReturndate 
    + "' WHERE charass_target_type = 'SI' AND charass_char_id = getcharid('RETURN DATE','I') AND charass_target_id IN (SELECT coitem_id FROM cohead JOIN coitem ON coitem_cohead_id = cohead_id WHERE cohead_id = " 
    + _so.id().toString() 
    + ");");

    // create Return Date Override comment
    var qry2 = toolbox.executeQuery(
    "SELECT postcomment('RETURN DATE Override','SI',coitem_id,'"
    + _snewReturndate
    + "') FROM cohead JOIN coitem ON coitem_cohead_id = cohead_id JOIN charass ON charass_target_id = coitem_id AND charass_char_id = getcharid('RETURN DATE','I') WHERE cohead_id = " 
    + _so.id().toString() 
    + ";");
    
    }
    
    QMessageBox.information(mywindow, qsTr("Notice"), "Sales Order " + _so.number + " has been updated");
}











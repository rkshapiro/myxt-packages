var _itemlocdist = mywindow.findChild("_itemlocdist");
var _qtyRemaining = mywindow.findChild("_qtyBalance");
var _itemlocdistid;
var _itemlocseries;

function set(input) {
  _itemlocdistid = input.itemlocdist_id;
  _itemlocseries = input.itemlocseries;

  var itemlocqry = " SELECT itemlocdist_qty, itemsite_controlmethod, "
    			+" itemsite_perishable, itemsite_warrpurc, itemsite_lsseq_id, "
    			+" invhist_ordtype, invhist_ordnumber, lsseq_number, invhist_transtype "
  			+" FROM itemlocdist "
    			+" JOIN itemsite ON (itemlocdist_itemsite_id=itemsite_id) "
    			+" JOIN invhist ON (itemlocdist_invhist_id=invhist_id) "
    			+" JOIN lsseq ON (itemsite_lsseq_id=lsseq_id) "
  			+" WHERE (itemlocdist_id=<? value('itemlocdist_id') ?>); ";

  var qry = toolbox.executeQuery(itemlocqry, input);

  if (qry.first()) {
    if (qry.value("invhist_ordtype") == "WO" && qry.value("invhist_transtype") == "RM" && qry.value("lsseq_number") == "WO") {
      var _delete = mywindow.findChild("_delete");
      var _new = mywindow.findChild("_new");
      _new.visible = false;
      _delete.visible = false;
    }
    else if (qry.value("lsseq_number") == "WO") {
      var params = {};
      var rows = _itemlocdist.findItems("*", 5); 

      for (var i = 0; i < rows.length; i++) {
        var deltext = "SELECT deleteItemlocdist(<? value('itemlocdist_id') ?>);"
        params.itemlocdist_id = rows[i].id();
        var delQry = toolbox.executeQuery(deltext, params);
      }

      mywindow.sFillList();
      var newparams = {};
      newparams.itemlocdist_id = _itemlocdistid;
      newparams.itemloc_series = _itemlocseries;
      newparams.qtyRemaining = _qtyRemaining.text;
      var newwnd = toolbox.openWindow("createLotSerial", mywindow, Qt.WindowModal);
      newwnd.set(newparams);
      var result = newwnd.exec();
      if(result != 0) {
        mywindow.sFillList();
      }
    }
  }
}
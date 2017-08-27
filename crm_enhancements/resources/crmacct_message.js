 /*
This file is part of the xtmfg Package for xTuple ERP,
and is Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.  It
is licensed to you under the xTuple End-User License Agreement ("the
EULA"), the full text of which is available at www.xtuple.com/EULA.
While the EULA gives you access to source code and encourages your
involvement in the development process, this Package is not free
software.  By using this software, you agree to be bound by the
terms of the EULA.
*/

debugger;

_crmacct  = mywindow.findChild("_crmacct");
_close = mywindow.findChild("_close");
_cancel = mywindow.findChild("_cancel");
_save = mywindow.findChild("_save");
_message = mywindow.findChild("_message");
_crmacct.setFocus();

var _crmacctid = -1;
var _messageid = -1;

_save.clicked.connect(createmessage);
_close.clicked.connect(mywindow,"close");
_cancel.clicked.connect(cancelmessage);

function createmessage()
{
  var params = new Object;
  params.crmacctid = _crmacct.id();
  params.msgtext = _message.plainText;

  var qry = toolbox.executeQuery("SELECT postcomment('Message','CRMA',<? value('crmacctid') ?>,<? value('msgtext') ?>) AS messageid", params);
  
  if (qry.first())
  {
    _messageid = qry.value("messageid");
	_message.clear();
	_crmacct.clear();
	_crmacct.setFocus();
  }
   else if (qry.lastError().type != QSqlError.NoError)
  {
    QMessageBox.critical(mywindow,qsTr("Database Error"), qry.lastError().text);
    return false;
  }
}

function cancelmessage()
{
  if (_messageid != -1 )
  {
   if ( QMessageBox.question(mywindow,qsTr("Delete Message"),qsTr("Do you want to delete the Saved Message?"),
		QMessageBox.Yes,
		QMessageBox.No | QMessageBox.Default) == QMessageBox.Yes)
		{
		var params = new Object;
		params.messageid = _messageid;
		var qry = toolbox.executeQuery("DELETE FROM comment WHERE comment_id = <? value('messageid') ?>",params);

		if (qry.lastError().type != QSqlError.NoError)
		{
			QMessageBox.critical(mywindow,qsTr("Database Error"), qry.lastError().text);
			return false;
		}
		QMessageBox.information(mywindow,qsTr("Notice"),qsTr("The last Saved Message has been deleted."));
		}
  }
  mywindow.close();
}
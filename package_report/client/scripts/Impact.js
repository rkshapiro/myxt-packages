debugger;
/* 
Impact processing - this script is used to add , edit and view the _cpo.impact table
 20150318:rek Initial draft
*/

function Clear()
{
	mywindow.findChild("_cust").setId(-1);
}

function getParams()
{
	var params = new Object;
	params.cust_id = mywindow.findChild("_cust").id();
	
	if (_list.id() >= 0)
	{
		params.impact_id = _list.id();
		
	}

	params.current_user = _cuser;

	// hand the parameter list back to the caller
	return params;
}



function getRole()
{
	// first check CUSTSERV
	var qry = toolbox.executeQuery("SELECT COUNT (*) as cnt FROM public.grp, public.usrgrp " +
	"WHERE usrgrp.usrgrp_grp_id = grp.grp_id AND usrgrp.usrgrp_username = '" + _cuser + "'" +
	" AND (grp_name = 'CUSTSERV_ADMIN' OR grp_name = 'ADMIN')");
	qry.first();

	var count = qry.value(0);

	if ( count != 0)
		_canEdit = true;

	// then check ADMIN

	var qry1 = toolbox.executeQuery("SELECT COUNT (*) as cnt FROM public.grp, public.usrgrp " +
	"WHERE usrgrp.usrgrp_grp_id = grp.grp_id AND usrgrp.usrgrp_username = '" + _cuser + "'" +
	" AND grp_name = 'ADMIN'");
	qry1.first();

	var count1 = qry1.value(0);

	if ( count1 != 0)
		_canDelete = true;
}

function checkInsert()
{
	if (!_canEdit)
	{
		mywindow.findChild("_btnAdd").enabled = false;
		mywindow.findChild("_btnAddp").enabled = false;
		mywindow.findChild("_editStudent").enabled = false;
		mywindow.findChild("_editTeacher").enabled = false;
	}
}

function getToday()
{
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	if(dd<10) {
	    dd='0'+dd
	} 

	if(mm<10) {
	    mm='0'+mm
	} 

	_today = yyyy+'-'+mm+'-'+dd;
}

function getCurrentUser()
{
	var qry = toolbox.executeQuery("SELECT current_user");
	qry.first();
	var currentuser = qry.value("current_user");

	return currentuser;
}

// check if the first row is the current fiscal year
// then disable inserts
function checkFirstRow()
{
	var params = getParams();
	var _fisyearcheck = "";

	// check student

	var qry = toolbox.executeQuery("SELECT " +		
		"fiscal_year " +		
		"FROM _cpo.impact " +
		"WHERE impact_cust_id = <? value(\"cust_id\") ?> ORDER BY impact_lastupdated DESC;" 				
		, params);

	if (qry.size() > 0)
	{
		qry.first();
		_fisyearcheck = (qry.value(0));	
	}

	if (_fisyearcheck == _fiscalyear)
	{
		mywindow.findChild("_btnAdd").setDisabled(true);
		
	}

	// check teacher

	var qry1 = toolbox.executeQuery("SELECT " +		
		"fiscal_year " +		
		"FROM _cpo.impact_teacher " +
		"WHERE impact_teacher_cust_id = <? value(\"cust_id\") ?> ORDER BY impact_teacher_lastupdated DESC;" 				
		, params);

	var _fisyearcheck = "";

	if (qry1.size() > 0)
	{
		qry1.first();
		_fisyearcheck = (qry1.value(0));	
	}

	if (_fisyearcheck == _fiscalyear)
	{
		
		mywindow.findChild("_btnAddp").setDisabled(true);
	}
		
}

function getFiscalyear()
{
	var qry = toolbox.executeQuery("SELECT _report.getschoolyear(current_date) as fiscalyear");
	qry.first();
	_fiscalyear = qry.value("fiscalyear");
	
}

// Now define a query, run it, and populate the _list with the results.
function query()
{
	
	
	var params = getParams(); // get selection criteria from the window

	// Note: Because multiple item groups can reference one item, we just pick the first item group that comes back and use that for the query.
	var qry = toolbox.executeQuery("SELECT " +
		"impact_id, " +
		"impact_cust_id AS cust_id, " +
		"impact_created as date_created, " +
		"impact_lastupdated as date_updated, " +
		"impact_students_pre_k as pre_k, " +		
		"impact_students_kindergarten as kindergarten, " +		
		"impact_students_1 as grade_1, " +
		"impact_students_2 as grade_2, " +
		"impact_students_3 as grade_3, " +
		"impact_students_4 as grade_4, " +
		"impact_students_5 as grade_5, " +
		"impact_students_6 as grade_6, " +
		"impact_students_7 as grade_7, " +
		"impact_students_8 as grade_8, " +
		"impact_students_9 as grade_9, " +
		"impact_students_10 as grade_10, " +
		"impact_students_11 as grade_11, " +
		"impact_students_12 as grade_12, " +
		"impact_students_undergraduate as undergraduate, " +
		"impact_students_graduate as graduate, " +
		"impact_students_out_of_school as out_of_school, " +
		"impact_teachers_in_district as teachers_in_district, " +
		"impact_students_in_district as students_in_district, " +
		"impact_reduced_lunch as reduced_lunch, " +
		"impact_students_total, " +
		"fiscal_year, " +		
		"created_by_user, " +
		"modified_by_user  " +
		"FROM _cpo.impact " +
		"WHERE impact_cust_id = <? value(\"cust_id\") ?> " +
		"ORDER BY impact_lastupdated DESC;"
		
		, params);

	// populate the _list XTreeWidget with the query results saved in qry.
	mywindow.findChild("_list").populate(qry);

	checkInsert();
	
	var _btnEdit = mywindow.findChild("_editStudent");
	if (qry.size() == 0)
	{		
		_btnEdit.enabled = false;
	}
	else if (_canEdit)
	{
		_btnEdit.enabled = true;
	}

	var qry1 = toolbox.executeQuery("SELECT " +
		"impact_teacher_id, " +
		"impact_teacher_cust_id , " +
		"impact_teacher_created , " +
		"impact_teacher_lastupdated , " +
		"impact_teacher_teacher_pre_k , " +		
		"impact_teacher_teacher_kindergarten , " +		
		"impact_teacher_teacher_1 , " +
		"impact_teacher_teacher_2 , " +
		"impact_teacher_teacher_3 , " +
		"impact_teacher_teacher_4 , " +
		"impact_teacher_teacher_5 , " +
		"impact_teacher_teacher_6 , " +
		"impact_teacher_teacher_7 , " +
		"impact_teacher_teacher_8 , " +
		"impact_teacher_teacher_9 , " +
		"impact_teacher_teacher_10 , " +
		"impact_teacher_teacher_11 , " +
		"impact_teacher_teacher_12,  " +
		"impact_teacher_undergraduate, " +
		"impact_teacher_graduate, " + 
		"impact_teacher_out_of_school, " + 
        "impact_teacher_total, " +
		"impact_teacher_reduced_lunch, " + 
		"fiscal_year, " + 		
        "created_by_user, " + 
		"modified_by_user " +
		"FROM _cpo.impact_teacher " +
		"WHERE impact_teacher_cust_id = <? value(\"cust_id\") ?> " +
		"ORDER BY impact_teacher_lastupdated DESC;"
		
		, params);

		// populate the _list XTreeWidget with the query results saved in qry.
	mywindow.findChild("_listp").populate(qry1);
	
	var _btnEditT = mywindow.findChild("_editTeacher");
	if (qry1.size() == 0) 
	{		
		_btnEditT.enabled = false;
	}
	else if (_canEdit)
	{
		_btnEditT.enabled = true;
	}


	// if the first row is the current fiscal year, disable inserts

	checkFirstRow();

	
}



function print()
{

	
}



/* This function checks whether the _update widget is checked or not. If
_update is checked when tick() gets called then it will repopulate _list.
*/

function tick()
{
	if (mywindow.findChild("_update").checked)
	{
		query();
	}
}

function deleteItem()
{
	if (_list.id() == -1)
	{
		return;
	}

	var id = _list.id().toString();

	var params = new Object();
	var qry = toolbox.executeQuery("DELETE FROM _cpo.impact WHERE  impact_id =" + _list.id().toString(), params);
	query(); // Refresh our display

	// need to add to comments. 

	var qry1 = toolbox.executeQuery("INSERT into _cpo.impact_comment " +
		"(impact_comment_impact_id,impact_comment_comment) " +
		"VALUES(" + id + ",'Deleted');");
}

function deleteTeacherItem()
{
	if (_lisp.id() == -1)
	{
		return;
	}

	var id = _lisp.id().toString();
	var params = new Object();
	var qry = toolbox.executeQuery("DELETE FROM _cpo.impact_teacher WHERE  impact_teacher_id =" 
		+ _lisp.id().toString(), params);
	query(); // Refresh our display

	// need to add to comments. 

	var qry1 = toolbox.executeQuery("INSERT into _cpo.impact_teacher_comment " +
		"(impact_teacher_comment_impact_teacher_id,impact_teacher_comment_comment) " +
		"VALUES(" + id + ",'Deleted');");
}

function GridRowDoubleClicked(pItem, pCol)
{
	if (_list.currentItem().text(2).substring(0,10) != _today)
	{
		return;
	}
	editItem();
}

function GridTeacherRowDoubleClicked(pItem, pCol)
{
	if (_lisp.currentItem().text(2).substring(0,10) != _today)
	{
		return;
	}

	editTeacherItem();
}

function mnuViewStudentComments()
{
	if (_list.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.id = _list.id();

	var newdlg = toolbox.openWindow("Impact_Student_Comment", mywindow, Qt.WindowModal, Qt.Sheet);
	var tmp = toolbox.lastWindow().set(params);
}

function mnuViewTeacherComments()
{
	if (_lisp.id() == -1)
	{
		return;
	}

	var params = new Object();
	params.id = _lisp.id();

	var newdlg = toolbox.openWindow("Impact_Teacher_Comment", mywindow, Qt.WindowModal, Qt.Sheet);
	var tmp = toolbox.lastWindow().set(params);
}


function GridMenuPopulate(pMenu, pItem, pCol)
{
	if (_list.id() == -1)
	{
		return;
	}


	 if ((_canEdit) && (_list.currentItem().text(2) == _fiscalyear))
	{
		var listActmnuEdit = toolbox.menuAddAction(pMenu, qsTr("Edit..."), true);
		listActmnuEdit.triggered.connect(mnuEdit);

		var listActSep1 = toolbox.menuAddSeparator(pMenu);

		if ( _canDelete)
		{
			var listActmnuView = toolbox.menuAddAction(pMenu, qsTr("Delete"), true);
			listActmnuView.triggered.connect(mnuDeleteItem);
		}

		var listActSep2 = toolbox.menuAddSeparator(pMenu);
	} 

	var listActmnuView3 = toolbox.menuAddAction(pMenu, qsTr("View Comments"), true);
	listActmnuView3.triggered.connect(mnuViewStudentComments);
}

function GridTeacherMenuPopulate(pMenu, pItem, pCol)
{
	if (_lisp.id() == -1)
	{
		return;
	}

	

	 if ((_canEdit) && (_lisp.currentItem().text(2) == _fiscalyear))
	{
		var listActmnuEdit = toolbox.menuAddAction(pMenu, qsTr("Edit..."), true);
		listActmnuEdit.triggered.connect(mnuTeacherEdit);

		var listActSep1 = toolbox.menuAddSeparator(pMenu);

		if ( _canDelete)
		{
			var listActmnuView = toolbox.menuAddAction(pMenu, qsTr("Delete"), true);
			listActmnuView.triggered.connect(mnuDeleteTeacherItem);
		}
		var listActSep2 = toolbox.menuAddSeparator(pMenu);
	} 

	var listActmnuView3 = toolbox.menuAddAction(pMenu, qsTr("View Comments"), true);
	listActmnuView3.triggered.connect(mnuViewTeacherComments);
}

function editItem()
{
	if (!_canEdit) 
	{
		QMessageBox.critical(mywindow, qsTr("Permission Denied"), qsTr("You do not have permission to edit Student Impact Items. Please notify a xTuple administrator that you need to be added to the CUSTSERV role in order to edit Student Impact Items."));
		return;
		return; // We could have gotten here by double-clicking the row.
	}


	if (_list.id() == -1)
	{
		return;
	}

	if (_list.currentItem().text(2) != _fiscalyear)
	{
		QMessageBox.critical(mywindow, qsTr("Fiscal Year"), qsTr("You can not edit items from previous fiscal years."));
		return;		
	}

	var params = new Object();
	params.cust_id = mywindow.findChild("_cust").id();
	params.impact_id=_list.id();
	params.currentuser = _cuser;
	params.status = "Edit";
	params.fiscalyear = _fiscalyear;
	

	var newdlg = toolbox.openWindow("Impact_Student", mywindow, Qt.WindowModal, Qt.Sheet);
	var tmp = toolbox.lastWindow().set(params);

	// exec() the QDialog
	var result = newdlg.exec();
	
	if (result == 1)
	{
	   // We clicked OK, so refresh the data.
	   query();
	} 
}

function editTeacherItem()
{
	if (!_canEdit) 
	{
		QMessageBox.critical(mywindow, qsTr("Permission Denied"), qsTr("You do not have permission to edit Teacher Impact Items. Please notify a xTuple administrator that you need to be added to the CUSTSERV role in order to edit Teacher Impact Items."));
		return; // We could have gotten here by double-clicking the row.
	}


	if (_lisp.id() == -1)
	{
		return;
	}

	if (_lisp.currentItem().text(2) != _fiscalyear)
	{
		QMessageBox.critical(mywindow, qsTr("Fiscal Year"), qsTr("You can not edit items from previous fiscal years."));
		return;
	}

	var params = new Object();
	params.cust_id = mywindow.findChild("_cust").id();
	params.impact_id=_lisp.id();
	params.currentuser = _cuser;
	params.status = "Edit";
	params.fiscalyear = _fiscalyear;
	

	var newdlg = toolbox.openWindow("Impact_Teacher", mywindow, Qt.WindowModal, Qt.Sheet);
	var tmp = toolbox.lastWindow().set(params);

	// exec() the QDialog
	var result = newdlg.exec();
	
	if (result == 1)
	{
	   // We clicked OK, so refresh the data.
	   query();
	} 
}


function mnuEdit()
{
	editItem();
}

function mnuTeacherEdit()
{
	editTeacherItem();
}

function addItem()
{
	if (!_canEdit)
	{
		QMessageBox.critical(mywindow, qsTr("Permission Denied"), qsTr("You do not have permission to add Student Impact Items. Please notify a xTuple administrator that you need to be added to the CUSTSERV role in order to add Student Impact Items."));
		return;
	}
	var params = new Object();
	params.cust_id = mywindow.findChild("_cust").id();
	params.status = "New";
	params.currentuser = _cuser;
	params.fiscalyear = _fiscalyear;
	

	var newdlg = toolbox.openWindow("Impact_Student", mywindow, Qt.WindowModal, Qt.Sheet);
	//var tmp = toolbox.lastWindow().set(getParams());
	var tmp = toolbox.lastWindow().set(params);

	// exec() the QDialog
	var result = newdlg.exec();

	if (result == 1)
	{
	   // We clicked OK, so refresh the data.
	   query();
	} 

}

function addTeacherItem()
{
	if (!_canEdit)
	{
		QMessageBox.critical(mywindow, qsTr("Permission Denied"), qsTr("You do not have permission to add Student Impact Items. Please notify a xTuple administrator that you need to be added to the CUSTSERV role in order to add Student Impact Items."));
		return;
	}

	var params = new Object();
	params.cust_id = mywindow.findChild("_cust").id();
	params.currentuser = _cuser;
	params.status = "New";
	params.fiscalyear = _fiscalyear;
	

	var newdlg = toolbox.openWindow("Impact_Teacher", mywindow, Qt.WindowModal, Qt.Sheet);
	//var tmp = toolbox.lastWindow().set(getParams());
	var tmp = toolbox.lastWindow().set(params);

	// exec() the QDialog
	var result = newdlg.exec();

	if (result == 1)
	{
	   // We clicked OK, so refresh the data.
	   query();
	} 

}

function mnuDeleteItem()
{
	 var ans = QMessageBox.question(mywindow, qsTr("Delete Standard Item?"),
                               qsTr("Are you sure you want to delete the Student Impact data from this customer?"),
                               QMessageBox.Yes | QMessageBox.No);

	if (ans == QMessageBox.Yes)
	{
		deleteItem();
	} 
}

function mnuDeleteTeacherItem()
{
	 var ans = QMessageBox.question(mywindow, qsTr("Delete Standard Item?"),
                               qsTr("Are you sure you want to delete the Teacher Impact data from this customer?"),
                               QMessageBox.Yes | QMessageBox.No);

	if (ans == QMessageBox.Yes)
	{
		deleteTeacherItem();
	} 
}




/* Now we have to set up the display and connect the various objects together
in a way that will make the display work when users click the buttons.

First connect the buttons to the appropriate functions. Windows know how to
close themselves so connect the _close button to the generic close function.
*/
mywindow.findChild("_close").clicked.connect(mywindow, "close");


/*mywindow.findChild("_print").clicked.connect(print);*/

mywindow.findChild("_btnAdd").clicked.connect(addItem);
mywindow.findChild("_btnAddp").clicked.connect(addTeacherItem);

// connect the _query button to the functions defined above
mywindow.findChild("_query").clicked.connect(query);
mywindow.findChild("_queryp").clicked.connect(query);

mywindow.findChild("_query").hide();
mywindow.findChild("_queryp").hide();

mywindow.findChild("_cust").valid.connect(query);

// connect the _edit buttons to the functions defined above
mywindow.findChild("_editStudent").clicked.connect(editItem);
mywindow.findChild("_editTeacher").clicked.connect(editTeacherItem);

/* xTuple ERP has an internal repeating timer. Connect the tick() function to
this timer so the _list gets updated automatically if the user so desires.
*/
//mainwindow.tick.connect(tick);

/* When _list gets created by the window, it is empty - no rows and no columns.
Define the columns here and let query() create the rows. addColumn() takes
the following arguments:
1) column title text
2) column width in pixels
3) default column alignment - see the Qt docs for Qt::Alignment
4) default visibility - is this column visible when the window is first shown
5) column name from the query to put in this column of the display
*/
var _list = mywindow.findChild("_list");

_list.addColumn("Impact Id", 100, 1, false, "impact_id"); 
_list.addColumn("Cust Id", 100, 1, false, "cust_id"); 
_list.addColumn("Fiscal year", 100, 1, true, "fiscal_year");

_list.addColumn("Created By", 100, 1, true, "created_by_user");
_list.addColumn("Date Created", 100, 1, true, "date_created"); 
_list.addColumn("Modified By", 100, 1, true, "modified_by_user");
_list.addColumn("Date Updated", 100, 1, true, "date_updated"); 
_list.addColumn("Pre K", 50, 1, true, "pre_k"); 
_list.addColumn("Kindergarten", 80, 1, true, "kindergarten"); 
_list.addColumn("Gr-1", 50, 1, true, "grade_1"); 
_list.addColumn("Gr-2", 50, 1, true, "grade_2"); 
_list.addColumn("Gr-3", 50, 1, true, "grade_3"); 
_list.addColumn("Gr-4", 50, 1, true, "grade_4"); 
_list.addColumn("Gr-5", 50, 1, true, "grade_5"); 
_list.addColumn("Gr-6", 50, 1, true, "grade_6"); 
_list.addColumn("Gr-7", 50, 1, true, "grade_7"); 
_list.addColumn("Gr-8", 50, 1, true, "grade_8"); 
_list.addColumn("Gr-9", 50, 1, true, "grade_9"); 
_list.addColumn("Gr-10", 60, 1, true, "grade_10"); 
_list.addColumn("Gr-11", 60, 1, true, "grade_11"); 
_list.addColumn("Gr-12", 60, 1, true, "grade_12"); 
_list.addColumn("Undergraduate", 80, 1, true, "undergraduate"); 
_list.addColumn("Graduate", 80, 1, true, "graduate"); 
_list.addColumn("Out of School", 80, 1, true, "out_of_school"); 
//_list.addColumn("Teachers in District", 120, 1, true, "teachers_in_district"); 
//_list.addColumn("Students in District", 120, 1, true, "students_in_district"); 
_list.addColumn("Reduced Lunch", 100, 1, true, "reduced_lunch"); 
_list.addColumn("Provided Total", 200, 1, true, "impact_students_total"); 

var _lisp = mywindow.findChild("_listp");

_lisp.addColumn("Impact Id", 100, 1, false, "impact_teacher_id"); 
_lisp.addColumn("Cust Id", 100, 1, false, "impact_teacher_cust_id"); 
_lisp.addColumn("Fiscal year", 100, 1, true, "fiscal_year");

_lisp.addColumn("Created By", 100, 1, true, "created_by_user");
_lisp.addColumn("Date Created", 100, 1, true, "impact_teacher_created"); 
_lisp.addColumn("Modified By", 100, 1, true, "modified_by_user");
_lisp.addColumn("Date Updated", 100, 1, true, "impact_teacher_lastupdated"); 
_lisp.addColumn("Pre K", 50, 1, true, "impact_teacher_teacher_pre_k"); 
_lisp.addColumn("Kindergarten", 80, 1, true, "impact_teacher_teacher_kindergarten"); 
_lisp.addColumn("Gr-1", 50, 1, true, "impact_teacher_teacher_1"); 
_lisp.addColumn("Gr-2", 50, 1, true, "impact_teacher_teacher_2"); 
_lisp.addColumn("Gr-3", 50, 1, true, "impact_teacher_teacher_3"); 
_lisp.addColumn("Gr-4", 50, 1, true, "impact_teacher_teacher_4"); 
_lisp.addColumn("Gr-5", 50, 1, true, "impact_teacher_teacher_5"); 
_lisp.addColumn("Gr-6", 50, 1, true, "impact_teacher_teacher_6"); 
_lisp.addColumn("Gr-7", 50, 1, true, "impact_teacher_teacher_7"); 
_lisp.addColumn("Gr-8", 50, 1, true, "impact_teacher_teacher_8"); 
_lisp.addColumn("Gr-9", 50, 1, true, "impact_teacher_teacher_9"); 
_lisp.addColumn("Gr-10", 60, 1, true, "impact_teacher_teacher_10"); 
_lisp.addColumn("Gr-11", 60, 1, true, "impact_teacher_teacher_11"); 
_lisp.addColumn("Gr-12", 60, 1, true, "impact_teacher_teacher_12");
_lisp.addColumn("Undergraduate", 80, 1, true, "impact_teacher_undergraduate"); 
_lisp.addColumn("Graduate", 80, 1, true, "impact_teacher_graduate"); 
_lisp.addColumn("Out of School", 80, 1, true, "impact_teacher_out_of_school"); 
_lisp.addColumn("Reduced Lunch", 100, 1, true, "impact_teacher_reduced_lunch"); 
_lisp.addColumn("Provided Total", 200, 1, true, "impact_teacher_total"); 


_list["populateMenu(QMenu *, QTreeWidgetItem *, int)"].connect(GridMenuPopulate);
_list["itemDoubleClicked(QTreeWidgetItem *, int)"].connect(GridRowDoubleClicked);

_lisp["populateMenu(QMenu *, QTreeWidgetItem *, int)"].connect(GridTeacherMenuPopulate);
_lisp["itemDoubleClicked(QTreeWidgetItem *, int)"].connect(GridTeacherRowDoubleClicked);

var _today = "";
var _fiscalyear = "";

getToday();

// get the current fiscal year
getFiscalyear();

var _cuser = getCurrentUser();

// _cuser = "rklodowski"  // for testing non edit users

var _canEdit = false;
var _canDelete = false;

getRole();





// and that's it


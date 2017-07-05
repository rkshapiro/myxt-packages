debugger;

var _lblCustomer = mywindow.findChild("_lblCustomer");

var _preKStudentsLineEdit = mywindow.findChild("preKStudentsLineEdit");
var _kindergartenStudentsLineEdit = mywindow.findChild("kindergartenStudentsLineEdit");
var _1stGradeStudentsLineEdit = mywindow.findChild("s1stGradeStudentsLineEdit");
var _2ndGradeStudentsLineEdit = mywindow.findChild("s2ndGradeStudentsLineEdit");
var _3rdGradeStudentsLineEdit = mywindow.findChild("s3rdGradeStudentsLineEdit");
var _4thGradeStudentsLineEdit = mywindow.findChild("s4thGradeStudentsLineEdit");
var _5thGradeStudentsLineEdit = mywindow.findChild("s5thGradeStudentsLineEdit");
var _6thGradeStudentsLineEdit = mywindow.findChild("s6thGradeStudentsLineEdit");
var _7thGradeStudentsLineEdit = mywindow.findChild("s7thGradeStudentsLineEdit");
var _8thGradeStudentsLineEdit = mywindow.findChild("s8thGradeStudentsLineEdit");
var _9thGradeStudentsLineEdit = mywindow.findChild("s9thGradeStudentsLineEdit");
var _10thGradeStudentsLineEdit = mywindow.findChild("s10thGradeStudentsLineEdit");
var _11thGradeStudentsLineEdit = mywindow.findChild("s11thGradeStudentsLineEdit");
var _12thGradeStudentsLineEdit = mywindow.findChild("s12thGradeStudentsLineEdit");

var _ungraduateTeachersLineEdit = mywindow.findChild("ungraduateTeachersLineEdit");
var _graduateTeachersLineEdit = mywindow.findChild("graduateTeachersLineEdit");
var _outOfSchoolTeachersLineEdit = mywindow.findChild("outOfSchoolTeachersLineEdit");
var _reducedLunchTeachersLineEdit = mywindow.findChild("reducedLunchTeachersLineEdit");
var _totalTeachersLineEdit = mywindow.findChild("totalTeachersLineEdit");

var _commentLineEdit = mywindow.findChild("commentLineEdit");

var _status = "";

var _currentuser = "";
var _cust_id = 0;

var _fiscal_year;

var _created_by_user;
var _modified_by_user;

var _btnOK = mywindow.findChild("_btnOK");
_btnOK.clicked.connect(btnOK_Click);

var _btnCancel = mywindow.findChild("_btnCancel");
_btnCancel.clicked.connect(mywindow.close);



function btnOK_Click()
{
	var params = new Object();
	if ( _status == "New")
	{
	var qry = toolbox.executeQuery(
		"SELECT * FROM _cpo.impact_teacher( " +
		_cust_id + "," +
		_preKStudentsLineEdit.text + "," +
		_kindergartenStudentsLineEdit.text + "," +
		_1stGradeStudentsLineEdit.text + "," +
		_2ndGradeStudentsLineEdit.text + "," +
		_3rdGradeStudentsLineEdit.text + "," +
		_4thGradeStudentsLineEdit.text + "," +
		_5thGradeStudentsLineEdit.text + "," +
		_6thGradeStudentsLineEdit.text + "," +
		_7thGradeStudentsLineEdit.text + "," +
		_8thGradeStudentsLineEdit.text + "," +
		_9thGradeStudentsLineEdit.text + "," +
		_10thGradeStudentsLineEdit.text + "," +
		_11thGradeStudentsLineEdit.text + "," +
		_12thGradeStudentsLineEdit.text + "," +
		_ungraduateTeachersLineEdit.text + "," +
		_graduateTeachersLineEdit.text + "," +
		_outOfSchoolTeachersLineEdit.text + "," +
		_reducedLunchTeachersLineEdit.text + "," +
		_totalTeachersLineEdit.text + "," +
		"'" + _fiscal_year + "'," +
		0 +
		",'" + _created_by_user + "'," +
		"'" + _modified_by_user + "');");

	qry.first();
	var primkey = qry.value(0);

	// here we add the comment row

	var qry1 = toolbox.executeQuery("INSERT into _cpo.impact_teacher_comment " +
		"(impact_teacher_comment_impact_teacher_id,impact_teacher_comment_comment) " +
		"VALUES(" +	primkey.toString() + ",'" + _commentLineEdit.text + "');");
	}
	else
	{
		var qry = toolbox.executeQuery(
		"UPDATE _cpo.impact_teacher " +
			"SET  impact_teacher_lastupdated = current_timestamp, " +
			"impact_teacher_teacher_pre_k = " + _preKStudentsLineEdit.text + "," +
			"impact_teacher_teacher_kindergarten = " + _kindergartenStudentsLineEdit.text + "," +
			"impact_teacher_teacher_1 = " + _1stGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_2 = " + _2ndGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_3 = " + _3rdGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_4 = " + _4thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_5 = " + _5thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_6 = " + _6thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_7 = " + _7thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_8 = " + _8thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_9 = " + _9thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_10 = " + _10thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_11 = " + _11thGradeStudentsLineEdit.text + "," +
			"impact_teacher_teacher_12 = " + _12thGradeStudentsLineEdit.text + "," +

			"impact_teacher_undergraduate = " + _ungraduateTeachersLineEdit.text + "," +
			"impact_teacher_graduate = " + _graduateTeachersLineEdit.text + "," +
			"impact_teacher_out_of_school = " + _outOfSchoolTeachersLineEdit.text + "," +
			"impact_teacher_total = " + _totalTeachersLineEdit.text + "," +
			"impact_teacher_reduced_lunch = " + _reducedLunchTeachersLineEdit.text + "," +
			"modified_by_user = '" + _modified_by_user + "' " +			
		" WHERE impact_teacher_id = " + _impact_id.toString() + ";", params);

		var qry1 = toolbox.executeQuery("INSERT into _cpo.impact_teacher_comment " +
		"(impact_teacher_comment_impact_teacher_id,impact_teacher_comment_comment) " +
		"VALUES(" +	_impact_id.toString() + ",'" + _commentLineEdit.text + "');");

		var test = "Ok";
	}
	mydialog.done(1);
	mywindow.close();
}

function set(input)
{
  if ("cust_id" in input)
{
	_cust_id = input.cust_id;
	_status = input.status;
	_created_by_user = input.currentuser;
	_modified_by_user = input.currentuser;
	_fiscal_year = input.fiscalyear;
	

	var params = new Object();
	var qry = toolbox.executeQuery("SELECT cust_name FROM custinfo WHERE cust_id=" + _cust_id.toString() + ";" , params);
	qry.first(); // Move to the first record that's returned.
	_lblCustomer.text = qry.value("cust_name");	

}

  
if ( _status == "Edit")
{
  if ("impact_id" in input)
  {
	_impact_id = input.impact_id; 

	var params = new Object();
	var qry = toolbox.executeQuery("SELECT * from _cpo.impact_teacher WHERE impact_teacher_id = " + _impact_id.toString());
	qry.first(); // Move to the first record that's returned.
	_preKStudentsLineEdit.text = qry.value("impact_teacher_teacher_pre_k");
	_kindergartenStudentsLineEdit.text = qry.value("impact_teacher_teacher_kindergarten");
	_1stGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_1");
	_2ndGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_2");
	_3rdGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_3");
	_4thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_4");
	_5thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_5");
	_6thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_6");
	_7thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_7");
	_8thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_8");
	_9thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_9");
	_10thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_10");
	_11thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_11");
	_12thGradeStudentsLineEdit.text = qry.value("impact_teacher_teacher_12");

	_ungraduateTeachersLineEdit.text = qry.value("impact_teacher_undergraduate");
	_graduateTeachersLineEdit.text = qry.value("impact_teacher_graduate");
	_outOfSchoolTeachersLineEdit.text = qry.value("impact_teacher_out_of_school");
	_reducedLunchTeachersLineEdit.text = qry.value("impact_teacher_reduced_lunch");
	_totalTeachersLineEdit.text = qry.value("impact_teacher_total");
  }
}


  return 0;
}

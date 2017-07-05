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
var _undergraduateStudentsLineEdit = mywindow.findChild("undergraduateStudentsLineEdit");
var _graduateStudentsLineEdit = mywindow.findChild("graduateStudentsLineEdit");
var _outOfSchoolStudentsLineEdit = mywindow.findChild("outOfSchoolStudentsLineEdit");
//var _teachersInDistrictLineEdit = mywindow.findChild("teachersInDistrictLineEdit");
//var _studentsInDistrictLineEdit = mywindow.findChild("studentsInDistrictLineEdit");
var _reducedLunchStudentsLineEdit = mywindow.findChild("reducedLunchStudentsLineEdit");
var _impactTotalStudentsLineEdit = mywindow.findChild("impactTotalStudentsLineEdit");

var _commentLineEdit = mywindow.findChild("commentLineEdit");

var _btnOK = mywindow.findChild("_btnOK");
_btnOK.clicked.connect(btnOK_Click);

var _btnCancel = mywindow.findChild("_btnCancel");
_btnCancel.clicked.connect(mywindow.close);

var _status = "";

var _currentuser = "";
var _cust_id = 0;

var _fiscal_year;

var _created_by_user;
var _modified_by_user;



function btnOK_Click()
{
	

	var params = new Object();

	if ( _status == "New")
	{
		var qry = toolbox.executeQuery(
		"SELECT * FROM _cpo.impact( " +
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
		_undergraduateStudentsLineEdit.text + "," +
		_graduateStudentsLineEdit.text + "," +
		_outOfSchoolStudentsLineEdit.text + "," +
		//_teachersInDistrictLineEdit.text + "," +
		//_studentsInDistrictLineEdit.text + "," +
		_reducedLunchStudentsLineEdit.text + "," +
		_impactTotalStudentsLineEdit.text + ",'" +
		_fiscal_year + "'," + 
		0 + ",'" +
		_created_by_user + "','" +
		_modified_by_user + "'" +
		");");

		qry.first();
		var primkey = qry.value(0);

		var qry1 = toolbox.executeQuery("INSERT into _cpo.impact_comment " +
		"(impact_comment_impact_id,impact_comment_comment) " +
		"VALUES(" +	primkey.toString() + ",'" + _commentLineEdit.text + "');");

		var test = "Ok";

	}
	else
	{
		var qry = toolbox.executeQuery(
		"UPDATE _cpo.impact " +
			"SET  impact_lastupdated = current_timestamp, " +
			"impact_students_pre_k = " + _preKStudentsLineEdit.text + "," +
			"impact_students_kindergarten = " + _kindergartenStudentsLineEdit.text + "," +
			"impact_students_1 = " + _1stGradeStudentsLineEdit.text + "," +
			"impact_students_2 = " + _2ndGradeStudentsLineEdit.text + "," +
			"impact_students_3 = " + _3rdGradeStudentsLineEdit.text + "," +
			"impact_students_4 = " + _4thGradeStudentsLineEdit.text + "," +
			"impact_students_5 = " + _5thGradeStudentsLineEdit.text + "," +
			"impact_students_6 = " + _6thGradeStudentsLineEdit.text + "," +
			"impact_students_7 = " + _7thGradeStudentsLineEdit.text + "," +
			"impact_students_8 = " + _8thGradeStudentsLineEdit.text + "," +
			"impact_students_9 = " + _9thGradeStudentsLineEdit.text + "," +
			"impact_students_10 = " + _10thGradeStudentsLineEdit.text + "," +
			"impact_students_11 = " + _11thGradeStudentsLineEdit.text + "," +
			"impact_students_12 = " + _12thGradeStudentsLineEdit.text + "," +
			"impact_students_undergraduate = " + _undergraduateStudentsLineEdit.text + "," +
			"impact_students_graduate = " + _graduateStudentsLineEdit.text + "," +
			"impact_students_out_of_school = " + _outOfSchoolStudentsLineEdit.text + "," +
			//"impact_teachers_in_district = " + _teachersInDistrictLineEdit.text + "," +
			//"impact_students_in_district = " + _studentsInDistrictLineEdit.text + "," +
			"impact_reduced_lunch = " + _reducedLunchStudentsLineEdit.text + "," +
			"impact_students_total = " + _impactTotalStudentsLineEdit.text + "," +
			"modified_by_user = '" + _modified_by_user + "' " +
			"WHERE impact_id = " + _impact_id.toString() + ";", params);

		var qry1 = toolbox.executeQuery("INSERT into _cpo.impact_comment " +
		"(impact_comment_impact_id,impact_comment_comment) " +
		"VALUES(" +	_impact_id.toString() + ",'" + _commentLineEdit.text + "');");
	
	}

	mydialog.done(1);
	mywindow.close();
}

function set(input)
{
	_modified_by_user = input.currentuser;
	_created_by_user = input.currentuser;
	_fiscal_year = input.fiscalyear;
	

  if ("cust_id" in input)
	{
		_cust_id = input.cust_id;
		_status = input.status;
		_currentuser = input.currentuser;

		var params = new Object();
		var qry = toolbox.executeQuery("SELECT cust_name FROM custinfo WHERE cust_id=" + _cust_id.toString() + ";" 
			, params);
		qry.first(); // Move to the first record that's returned.
		_lblCustomer.text = qry.value("cust_name");	

	}

  
  if ( _status == "Edit")
{
  if ("impact_id" in input)
  {
	_impact_id = input.impact_id; 

	var params = new Object();
	var qry = toolbox.executeQuery("SELECT * from _cpo.impact WHERE impact_id = " + _impact_id.toString());
	qry.first(); // Move to the first record that's returned.
	_preKStudentsLineEdit.text = qry.value("impact_students_pre_k");
	_kindergartenStudentsLineEdit.text = qry.value("impact_students_kindergarten");
	_1stGradeStudentsLineEdit.text = qry.value("impact_students_1");
	_2ndGradeStudentsLineEdit.text = qry.value("impact_students_2");
	_3rdGradeStudentsLineEdit.text = qry.value("impact_students_3");
	_4thGradeStudentsLineEdit.text = qry.value("impact_students_4");
	_5thGradeStudentsLineEdit.text = qry.value("impact_students_5");
	_6thGradeStudentsLineEdit.text = qry.value("impact_students_6");
	_7thGradeStudentsLineEdit.text = qry.value("impact_students_7");
	_8thGradeStudentsLineEdit.text = qry.value("impact_students_8");
	_9thGradeStudentsLineEdit.text = qry.value("impact_students_9");
	_10thGradeStudentsLineEdit.text = qry.value("impact_students_10");
	_11thGradeStudentsLineEdit.text = qry.value("impact_students_11");
	_12thGradeStudentsLineEdit.text = qry.value("impact_students_12");
	_undergraduateStudentsLineEdit.text = qry.value("impact_students_undergraduate");
	_graduateStudentsLineEdit.text = qry.value("impact_students_graduate");
	_outOfSchoolStudentsLineEdit.text = qry.value("impact_students_out_of_school");
	//_teachersInDistrictLineEdit.text = qry.value("impact_teachers_in_district");
	//_studentsInDistrictLineEdit.text = qry.value("impact_students_in_district");
	_reducedLunchStudentsLineEdit.text = qry.value("impact_reduced_lunch");	
	_impactTotalStudentsLineEdit.text = qry.value("impact_students_total");
  }
}


  return 0;
}

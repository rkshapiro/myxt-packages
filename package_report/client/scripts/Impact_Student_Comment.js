debugger;

var _list = mywindow.findChild("_results");

var _id = 0;

function set(input)
{
	_id = input.id;
	query();
}

function query()
{
	var params = new Object();
	var qry = toolbox.executeQuery("SELECT * FROM _cpo.impact_comment WHERE impact_comment_impact_id=" + _id.toString() + ";" , params);

	_list.populate(qry);
}

_list.addColumn("Comment Id", 100, 1, true, "impact_comment_id"); 
_list.addColumn("Impact Id", 100, 1, true, "impact_comment_impact_id"); 
_list.addColumn("Created Date", 100, 1, true, "impact_comment_created");
_list.addColumn("Username", 100, 1, true, "impact_comment_user");
_list.addColumn("Comment", 300, 1, true, "impact_comment_comment");
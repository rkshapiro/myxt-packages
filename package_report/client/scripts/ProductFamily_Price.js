debugger;

var result = mywindow.findChild("_results")
var itemgroup = mywindow.findChild("_itemgroup")
mywindow.findChild("_query").clicked.connect(query);
mywindow.findChild("_print").clicked.connect(print);
mywindow.findChild("_close").clicked.connect(mywindow, "close");

result.addColumn("Product Family", 100, 1, false, "itemgrp_name");
result.addColumn("Item Number", 80, 1, true, "item_number");
result.addColumn("Item Description", 200, 1, true, "item_descrip1");
result.addColumn("Classcode", 100, 1, true, "classcode_code");
result.addColumn("Rental Period", 100, 1, true, "rental_period");
result.addColumn("Current Member Price", 150, 4, true, "current_member_price");
//result.addColumn("Current NonMember Price", 150, 4, true, "current_nonmember_price")
result.addColumn("Future Member Price", 150, 4, true, "future_member_price")
//result.addColumn("Future NonMember Price", 150, 4, true, "future_nonmember_price");

loadItemGroups();

function loadItemGroups()
{
	var qry = toolbox.executeQuery("Select itemgrp_id,itemgrp_name from public.itemgrp ORDER BY itemgrp_name", null);

	itemgroup.populate(qry);
}

function getParams()
{
	var params = new Object;
	
	params.itemgrp_id = itemgroup.id();

	// hand the parameter list back to the caller
	return params;
}

function query()
{
	var params = getParams();
	
	var qry = toolbox.executeDbQuery("report", "product_family_price", params);
	result.populate(qry);
}

function print()
{
	toolbox.printReport("ProductFamilyPrices", getParams());
}
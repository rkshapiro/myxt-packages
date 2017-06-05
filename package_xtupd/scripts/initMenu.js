debugger;
var example = new Object;
var example15 = new Object;

// Create functions to launch our display windows

example15.menuDisplay = function()
{
  try {
    toolbox.newDisplay("dspitemupdateexport", 0, Qt.NonModal, Qt.Window);
  } catch (e) {
    print("initMenu::dspitemupdateexport() exception @ " + e.lineNumber + ": " + e);
  }
}


example.init = function()
{
  // Get system menu
  var inventoryMenu = mainwindow.findChild("menu.im");
  var accountingMenu = mainwindow.findChild("menu.accnt");
  var productsMenu = mainwindow.findChild("menu.prod");
  var salesMenu = mainwindow.findChild("menu.sales");
  var purchMenu = mainwindow.findChild("menu.purch");
  var crmMenu = mainwindow.findChild("menu.crm");
  var sysMenu = mainwindow.findChild("menu.sys");

  // Create new actions for the system menu

  var tmpaction15 = sysMenu.addAction(qsTr("Item Update Export..."),mainwindow);
  tmpaction15.enabled = privileges.value("ImportXML");

  // Give them names. This can be accessed by hotkeys!

  tmpaction15.objectName = "sys.itemupdateexport";

  // Connect the menu actions to the display functions

  tmpaction15.triggered.connect(example15.menuDisplay);

}
// Run the init function
example.init(); 

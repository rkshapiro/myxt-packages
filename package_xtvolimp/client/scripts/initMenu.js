debugger;
include("xtvolimp");
var xtvolimp = new Object;
var xtvolimp15 = new Object;

// Create functions to launch our display windows

xtvolimp15.menuDisplay = function()
     {
      toolbox.newDisplay("dspSoimpSum");
     }


xtvolimp.init = function()
{
  // Get system menu
  var inventoryMenu = mainwindow.findChild("menu.im");
  var accountingMenu = mainwindow.findChild("menu.accnt");
  var productsMenu = mainwindow.findChild("menu.prod");
  var salesMenu = mainwindow.findChild("menu.sales");
  var purchMenu = mainwindow.findChild("menu.purch");
  var crmMenu = mainwindow.findChild("menu.crm");

  // Create new actions for the system menu

  tmpaction15 = salesMenu.addAction(qsTr("Display Online Orders"), mainwindow);
  tmpaction15.enabled = privileges.value("ViewAROpenItems");


  // Give them names. This can be accessed by hotkeys!

  tmpaction15.objectName = "sys.soimpsummorders";

  // Connect the menu actions to the display functions

  tmpaction15.triggered.connect(xtvolimp15.menuDisplay);

}
// Run the init function
xtvolimp.init(); 

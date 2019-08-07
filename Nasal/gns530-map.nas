##
## Garmin GNS 530 GPS
#  Author: Julio Santa Cruz <bartacruz@gmail.com>
#  License: GNU GPL
##
#
var placement= "GNS530.screen";
var gns_display = {};
var started = 0;
var start_node = props.globals.getNode("/systems/electrical/outputs/gps", 1);
var timer = nil;

var powered = props.globals.initNode("/instrumentation/gns-530/powered", 0, "BOOL");

var _list = setlistener("/sim/fdm-initialized", func() {
    props.globals.initNode("/instrumentation/gns-530/powered", 0, "BOOL");
    create();
    set_status(0);
    timer = maketimer(1,loop);
    timer.start();
    removelistener(_list); # run ONCE
}); # fdm-initialized listener callback

var loop = func() {
	if (started==0 and start_node.getValue() >= 8) {
	    print("------- GPS STARTED ----");
	    set_status(1);
	} elsif (started == 1 and start_node.getValue() < 8) {
		print("------- GPS ENDED ----");
		set_status(0);
	}
}
var set_status = func(status) {
	val = status == 1;
	started = val;
	powered.setValue(val);
	gns_display.map.setVisible(val);
	gns_display.COM.group.setVisible(val);
	gns_display.VLOC.group.setVisible(val);
	gns_display.VOR.group.setVisible(val);
	_set_comvloc(props.globals.getNode("/instrumentation/gns-530/comvloc") == 1); # hack
}
var create = func() {
    print("GNS530 Starting...");
	gns_display.canvas = canvas.new({
        "name": "GNS530",
        "size": [1024, 1024],
        "view": [1024, 1024],
        "mipmapping": 1
    });
    gns_display.canvas.addPlacement({"node": placement});
    
    create_map();
    create_freq_panel("COM",10,10);
    create_freq_panel("VLOC",10,250);
    create_vor_panel();
    var transf_3f = func(val) {
    	return sprintf("%.3f",val);
    }
    var transf_slash = func(val) {
    	if (val == nil or val == '' or val == 0) {
    		return "___";
    	}
    	return val;
   	}
   	var transf_nm = func(val) {
   		if (val == nil or val == '' or val == 0) {
    		return "___";
    	}
    	return sprintf("%.1fnm",int(val)/1852);
   		
   	}
    make_listener("instrumentation/comm[0]/frequencies/selected-mhz", gns_display.COM.selected,transf_3f);
    make_listener("instrumentation/comm[0]/frequencies/standby-mhz", gns_display.COM.standby,transf_3f);
    make_listener("instrumentation/nav[0]/frequencies/selected-mhz", gns_display.VLOC.selected,transf_3f);
    make_listener("instrumentation/nav[0]/frequencies/standby-mhz", gns_display.VLOC.standby,transf_3f);
    make_listener("instrumentation/nav[0]/nav-id", gns_display.VOR.navid,transf_slash);
    make_listener("instrumentation/nav[0]/radials/selected-deg", gns_display.VOR.rad,transf_3f);
    make_listener("instrumentation/nav[0]/nav-distance", gns_display.VOR.distance,transf_nm);
    setlistener("/instrumentation/gns-530/buttons/rng-button",rng_button);
    setlistener("/instrumentation/gns-530/buttons/direct-pressed",direct_button);
    setlistener("/instrumentation/gns-530/menu",menu_button);
    setlistener("/instrumentation/gns-530/comvloc",comvloc_button,1);
    print("GNS530 Started");

}

var create_map = func() {
  gns_display.map_group= gns_display.canvas.createGroup();
  gns_display.map_group.setTranslation(    
                           gns_display.canvas.get("view[0]")/2,
                           gns_display.canvas.get("view[1]")/2
                        );
  gns_display.map = gns_display.map_group.createChild("map").setController("Aircraft position").setRange(25);
  var r = func(name,vis=1,zindex=nil) return caller(0)[0];

  # APT and VOR are the layer names
  add_overlay("OSM",1);
  foreach(var type; ['TFC','APT', 'VOR','RWY','APS', 'WPT', 'FLT', ] )
   add_layer(type,4);
}
var add_layer = func(lname,priority=nil) {
  var r = func(name,vis=1,zindex=nil) return caller(0)[0];
  var type=r(lname);
  gns_display.map.addLayer(factory: canvas.SymbolLayer, type_arg: type.name, visible: type.vis, priority: priority,);
}
var add_overlay = func(lname,priority=nil) {
  var r = func(name,vis=1,zindex=nil) return caller(0)[0];
  var type=r(lname);
  gns_display.map.addLayer(factory: canvas.OverlayLayer,type_arg: type.name, visible: type.vis, priority: priority,);
}

var create_freq_panel = func(name,x,y) {
	var panel = {};
	panel.group = gns_display.canvas.createGroup();
    panel.group
        .setColorFill(51,77,161,0.7)
        .setTranslation(x,y);
    panel.bg = panel.group.createChild("path",name ~ "_bg");
    panel.bg.rect(-4,-4,340,230, {"border-radius":10})
                     .set("fill","#334da1");
    panel.label = panel.group.createChild("text",name ~ "_label");
    panel.label.set("fill","#73cdd8")
             .setText(name)
             .setAlignment("left-top")       
             .setTranslation(5,10)
             .setFont("monoMMM_5.ttf")
             #.setFont("LiberationFonts/LiberationMono-Bold.ttf")
             .setFontSize(60, 5.5);
    panel.selected = panel.group.createChild("text",name ~ "_selected");
    panel.selected.setColor(255,255,255)
             .setText("136.975")
             .setAlignment("left-top")       
             .setTranslation(5,80)
             .setFont("monoMMM_5.ttf")
             #.setFont("LiberationFonts/LiberationMono-Bold.ttf")
             .setFontSize(70,1);
    panel.standby_bg = panel.group.createChild("path",name ~ "_standby_bg");
    panel.standby_bg.rect(5,145,320,70, {"border-radius":3})
                     .set("fill","#73cdd8");
    panel.standby = panel.group.createChild("text",name ~ "_standby");
    panel.standby.set("fill","#334da1")
             .setText("118.000")
             .setAlignment("left-top")       
             .setTranslation(5,150)
             #.setFont("BoeingCDU-Large.ttf")
             .setFont("monoMMM_5.ttf")
             .setFontSize(70,1);
	gns_display[name] = panel;
}

var create_vor_panel = func() {
	var panel = {};
	var name = "VOR";
	panel.group = gns_display.canvas.createGroup();
    panel.group
        .setColorFill(51,77,161,0.7)
        .setTranslation(10,490);
    panel.bg = panel.group.createChild("path",name ~ "_bg");
    panel.bg.rect(-4,-4,340,230, {"border-radius":10})
                     .set("fill","#334da1");
    
    var items = [["VOR","navid"],["RAD","rad"],["DIS","distance"]];
    var starty=10;
    var offsety=80;
    foreach (item; items) {
    	var label=panel.group.createChild("text",item[1] ~ "_label");
    	label.set("fill","#73cdd8")
             .setText(item[0])
             .setAlignment("left-top")
             .setTranslation(5,starty)
             .setFont("monoMMM_5.ttf")
             #.setFont("LiberationFonts/LiberationMono-Bold.ttf")
             .setFontSize(50, 1);
        var value = panel.group.createChild("text",item[1]);
    	value.set("fill","#73cdd8")
             .setText("---")
             .setAlignment("left-top")
             .setTranslation(150,starty)
             .setFont("monoMMM_5.ttf")
             #.setFont("LiberationFonts/LiberationMono-Bold.ttf")
             .setFontSize(50, 1);
    
    	panel[item[1] ~ "_label"]=label;
    	panel[item[1]]=value;
    	starty = starty + offsety;
    }
    gns_display[name] = panel;
}

var rng_button = func(node) {
	if (started == 1 ) {
  		var x = gns_display.map.getRange() + int(node.getValue());
  		gns_display.map.setRange(x);
  	}
}
var direct_button = func(node) {
  if (started == 1 and node.getValue() ==1) {
      gns_display.map.getLayer("OSM").toggleVisibility();   
  }
}
var menu_button = func(node) {
	if (started == 1 ) {
		var act = node.getValue() == 1;
		gns_display.COM.group.setVisible(act);
		gns_display.VLOC.group.setVisible(act);
		gns_display.VOR.group.setVisible(act);
	}
}
var comvloc_button = func(node) {
	if (started == 1 ) {
	    # avoid nil value in scalar context.
		var act = node.getValue() == 1;
		_set_comvloc(act);
	}
}
var _set_comvloc = func(act) {
	var colors = ["#73cdd8","#334da1"];
	gns_display.COM.standby_bg.setVisible(!act);
	gns_display.COM.standby.set("fill",colors[!act]);
	gns_display.VLOC.standby_bg.setVisible(act);
	gns_display.VLOC.standby.set("fill",colors[act]);
}
var make_listener = func(path,text,transf=nil) {
    setlistener(path, func(node) {
    	val = node.getValue();
    	if (transf != nil) {
    		val = transf(val);
    	} 
		text.setText(val);
    },1);
}
print("GNS530 Loaded");


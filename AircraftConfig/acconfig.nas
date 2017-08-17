# Aircraft Config Center
# Joshua Davidson (it0uchpods)

# (c) Joshua Davidson (it0uchpods)

var spinning = maketimer(0.05, func {
	var spinning = getprop("/systems/acconfig/spinning");
	if (spinning == 0) {
		setprop("/systems/acconfig/spin", "\\");
		setprop("/systems/acconfig/spinning", 1);
	} else if (spinning == 1) {
		setprop("/systems/acconfig/spin", "|");
		setprop("/systems/acconfig/spinning", 2);
	} else if (spinning == 2) {
		setprop("/systems/acconfig/spin", "/");
		setprop("/systems/acconfig/spinning", 3);
	} else if (spinning == 3) {
		setprop("/systems/acconfig/spin", "-");
		setprop("/systems/acconfig/spinning", 0);
	}
});

setprop("/systems/acconfig/autoconfig-running", 0);
setprop("/systems/acconfig/spinning", 0);
setprop("/systems/acconfig/spin", "-");
setprop("/systems/acconfig/new-revision", "");
setprop("/systems/acconfig/out-of-date", 0);
var main_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/main/dialog", "Aircraft/PA28-Warrior/AircraftConfig/main.xml");
var welcome_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/welcome/dialog", "Aircraft/PA28-Warrior/AircraftConfig/welcome.xml");
var ps_load_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psload/dialog", "Aircraft/PA28-Warrior/AircraftConfig/psload.xml");
var ps_loaded_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psloaded/dialog", "Aircraft/PA28-Warrior/AircraftConfig/psloaded.xml");
var init_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/init/dialog", "Aircraft/PA28-Warrior/AircraftConfig/ac_init.xml");
var help_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/help/dialog", "Aircraft/PA28-Warrior/AircraftConfig/help.xml");
var about_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/about/dialog", "Aircraft/PA28-Warrior/AircraftConfig/about.xml");
var update_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/update/dialog", "Aircraft/PA28-Warrior/AircraftConfig/update.xml");
spinning.start();
init_dlg.open();

http.load("https://raw.githubusercontent.com/it0uchpods/PA28-Warrior/master/revision.txt").done(func(r) setprop("/systems/acconfig/new-revision", r.response));
var revisionFile = (getprop("/sim/aircraft-dir")~"/revision.txt");
var current_revision = io.readfile(revisionFile);

setlistener("/systems/acconfig/new-revision", func {
	if (getprop("/systems/acconfig/new-revision") > current_revision) {
		setprop("/systems/acconfig/out-of-date", 1);
	} else {
		setprop("/systems/acconfig/out-of-date", 0);
	}
});

setlistener("/sim/signals/fdm-initialized", func {
	init_dlg.close();
	if (getprop("/systems/acconfig/out-of-date") == 1) {
		update_dlg.open();
		print("The PA28-Warrior is out of date!");
	} else {
		welcome_dlg.open();
	}
	spinning.stop();
});

var saveSettings = func {
#	aircraft.data.save();
}

saveSettings();

var systemsReset = func {
	systems.elec_init();
	systems.engine_init();
	systems.fuel_init();
    itaf.ap_init();
	libraries.variousReset();
}

################
# Panel States #
################

# Cold and Dark
var colddark = func {
	spinning.start();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	# Initial shutdown, and reinitialization.
	setprop("/controls/flight/flaps", 0.0);
	setprop("/controls/flight/elevator-trim", 0);
	systemsReset();
	if (getprop("/engines/engine[0]/rpm") < 421) {
		colddark_b();
	} else {
		var colddark_eng_off = setlistener("/engines/engine[0]/rpm", func {
			if (getprop("/engines/engine[0]/rpm") < 421) {
				removelistener(colddark_eng_off);
				colddark_b();
			}
		});
	}
}
var colddark_b = func {
	# Continues the Cold and Dark script, after engines fully shutdown.
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Start Eng
var beforestart = func {
	spinning.start();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	# First, we set everything to cold and dark.
	setprop("/controls/flight/flaps", 0.0);
	setprop("/controls/flight/elevator-trim", 0);
	systemsReset();
	
	# Now the Startup!
	setprop("/controls/electrical/battery", 1);
	setprop("/controls/electrical/alternator", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/switches/strobe-lights", 1);
	setprop("/controls/switches/avionics-master", 1);
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Taxi
var taxi = func {
	spinning.start();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	# First, we set everything to cold and dark.
	setprop("/controls/flight/flaps", 0.0);
	setprop("/controls/flight/elevator-trim", 0);
	systemsReset();
	
	# Now the Startup!
	setprop("/controls/electrical/battery", 1);
	setprop("/controls/electrical/alternator", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/switches/strobe-lights", 1);
	setprop("/controls/switches/nav-lights-factor", 1);
	setprop("/controls/switches/avionics-master", 1);
	setprop("/controls/engines/engine[0]/mixture", 1);
	setprop("/controls/engines/engine[0]/throttle", 0.4);
	setprop("/controls/engines/engine[0]/magnetos-switch", 4);
	interpolate("/controls/engines/engine[0]/throttle", 0.15, 3);
	settimer(func {
		setprop("/controls/engines/engine[0]/magnetos-switch", 3);
		setprop("/systems/acconfig/autoconfig-running", 0);
		ps_load_dlg.close();
		ps_loaded_dlg.open();
		spinning.stop();
	}, 3);
}

# Ready to Takeoff
var takeoff = func {
	# The same as taxi, except we set some things afterwards.
	taxi();
	var eng_one_chk_c = setlistener("/engines/engine[0]/rpm", func {
		if (getprop("/engines/engine[0]/rpm") >= 421) {
			removelistener(eng_one_chk_c);
			setprop("/controls/switches/fuel-pump", 1);
			setprop("/controls/switches/landing-light", 1);
			setprop("/controls/flight/elevator-trim", 0.04);
		}
	});
}
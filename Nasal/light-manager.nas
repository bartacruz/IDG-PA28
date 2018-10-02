# provides relative vectors from eye-point to aircraft lights
# in east/north/up coordinates the renderer uses
# Thanks to BAWV12 / Thorsten

var light_manager = {

	run: 0,
	
	lat_to_m: 110952.0,
	lon_to_m: 0.0,

	light1_xpos: 0.0,
	light1_ypos: 0.0,
	light1_zpos: 0.0,
	light1_r: 0.0,
	light1_g: 0.0,
	light1_b: 0.0,
	light1_size: 0.0,
	light1_stretch: 0.0,
	light1_is_on: 0,

	light2_xpos: 0.0,
	light2_ypos: 0.0,
	light2_zpos: 0.0,
	light2_r: 0.0,
	light2_g: 0.0,
	light2_b: 0.0,
	light2_size: 0.0,
	light2_stretch: 0.0,
	light2_is_on: 0,
	
	light3_xpos: 0.0,
	light3_ypos: 0.0,
	light3_zpos: 0.0,
	light3_r: 0.0,
	light3_g: 0.0,
	light3_b: 0.0,
	light3_size: 0.0,
	light3_stretch: 0.0,
	light3_is_on: 0,
	
	light4_xpos: 0.0,
	light4_ypos: 0.0,
	light4_zpos: 0.0,
	light4_r: 0.0,
	light4_g: 0.0,
	light4_b: 0.0,
	light4_size: 0.0,
	light4_stretch: 0.0,
	light4_is_on: 0,
	
	light5_xpos: 0.0,
	light5_ypos: 0.0,
	light5_zpos: 0.0,
	light5_r: 0.0,
	light5_g: 0.0,
	light5_b: 0.0,
	light5_size: 0.0,
	light5_stretch: 0.0,
	light5_is_on: 0,
	
	flcpt: 0,
	prev_view : 1,
	
	nd_ref_light1_x:  props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m", 1),
	nd_ref_light1_y:  props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m", 1),
	nd_ref_light1_z: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m", 1),
	nd_ref_light1_dir: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/dir", 1),

	nd_ref_light2_x: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[1]", 1),
	nd_ref_light2_y: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[1]", 1),
	nd_ref_light2_z: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[1]", 1),
	nd_ref_light2_dir: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/dir[1]", 1),

	nd_ref_light3_x: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[2]", 1),
	nd_ref_light3_y: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[2]", 1),
	nd_ref_light3_z: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[2]", 1),
	nd_ref_light3_dir: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/dir[2]", 1),

	nd_ref_light4_x: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[3]", 1),
	nd_ref_light4_y: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[3]", 1),
	nd_ref_light4_z: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[3]", 1),
	nd_ref_light4_dir: props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/dir[3]", 1),

	init: func {
		# define your lights here

		# lights ########
		# offsets to aircraft center
 
		me.light1_xpos =  20.0;
		me.light1_ypos =  0.0;
		me.light1_zpos =  2.0;
		
		me.light2_xpos =  -8.0;
		me.light2_ypos =  0.0;
		me.light2_zpos =  2.0;
		
		me.light3_xpos =  -2.0;
		me.light3_ypos =  6.0;
		me.light3_zpos =  2.0;
		
		me.light4_xpos =  -2.0;
		me.light4_ypos =  -6.0;
		me.light4_zpos =  2.0;
		
		# color values
		me.light1_r = 0.7;
		me.light1_g = 0.7;
		me.light1_b = 0.7;
		me.light2_r = 0.5;
		me.light2_g = 0.5;
		me.light2_b = 0.5;
		me.light3_r = 0.4;
		me.light3_g = 0.0;
		me.light3_b = 0.0;
		me.light4_r = 0.0;
		me.light4_g = 0.4;
		me.light4_b = 0.0;

		# spot size
		me.light1_size = 4;
		me.light1_stretch = 6;
		me.light2_size = 1.5;
		me.light3_size = 1.5;
		me.light4_size = 1.5;
		me.light5_size = 1.5;
		
		
		setprop("sim/rendering/als-secondary-lights/flash-radius", 13);

		me.start();
	},

	start: func {
		setprop("/sim/rendering/als-secondary-lights/num-lightspots", 5);
 
		setprop("/sim/rendering/als-secondary-lights/lightspot/size", me.light1_size);
		setprop("/sim/rendering/als-secondary-lights/lightspot/size[1]", me.light2_size);
		setprop("/sim/rendering/als-secondary-lights/lightspot/size[2]", me.light3_size);
		setprop("/sim/rendering/als-secondary-lights/lightspot/size[3]", me.light4_size);
 
		setprop("/sim/rendering/als-secondary-lights/lightspot/stretch", me.light1_stretch);
 
		me.run = 1;		
		me.update();
	},

	stop: func {
		me.run = 0;
	},

	update: func {
		if (me.run == 0) {
			return;
		}
		
		als_on = getprop("/sim/rendering/shaders/skydome");
		alt_agl = getprop("/position/altitude-agl-ft");
		type_of_view = getprop("sim/current-view/internal");
		
		if (als_on == 1 and alt_agl < 100.0) {
			land = getprop("/controls/switches/landing-light");
			nav = getprop("/controls/switches/nav-lights-factor");
			beacon = getprop("/controls/switches/beacon");
			
			var apos = geo.aircraft_position();
			var vpos = geo.viewer_position();

			me.lon_to_m = math.cos(apos.lat()*math.pi/180.0) * me.lat_to_m;

			var heading = getprop("/orientation/heading-deg") * math.pi/180.0;

			var lat = apos.lat();
			var lon = apos.lon();
			var alt = apos.alt();

			var sh = math.sin(heading);
			var ch = math.cos(heading);
			
			if (land != 0) {
				me.light1_ypos =  0.0;
				me.light1_on();
			} else {
				me.light1_off();
			}
			
			if (nav != 0) {
				me.light2_on();
				me.light3_on();
				me.light4_on();
			} else {
				me.light2_off();
				me.light3_off();
				me.light4_off();
			}
			

			# light 1 position
	 
			var proj_x = alt_agl;
			var proj_z = alt_agl/10.0;
	 
			apos.set_lat(lat + ((me.light1_xpos + proj_x) * ch + me.light1_ypos * sh) / me.lat_to_m);
			apos.set_lon(lon + ((me.light1_xpos + proj_x)* sh - me.light1_ypos * ch) / me.lon_to_m);
	 
			delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
			delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
			var delta_z = apos.alt()- proj_z - vpos.alt();
	 
			me.nd_ref_light1_x.setValue(delta_x);
			me.nd_ref_light1_y.setValue(delta_y);
			me.nd_ref_light1_z.setValue(delta_z);
			me.nd_ref_light1_dir.setValue(heading);			


	 
			# light 2 position
	 
			apos.set_lat(lat + (me.light2_xpos * ch + me.light2_ypos * sh) / me.lat_to_m);
			apos.set_lon(lon + (me.light2_xpos * sh - me.light2_ypos * ch) / me.lon_to_m);
	 
			delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
			delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
			delta_z = apos.alt() - vpos.alt();
	 
			me.nd_ref_light2_x.setValue(delta_x);
			me.nd_ref_light2_y.setValue(delta_y);
			me.nd_ref_light2_z.setValue(delta_z);
			me.nd_ref_light2_dir.setValue(heading);

	 
			# light 3 position
	 
			apos.set_lat(lat + (me.light3_xpos * ch + me.light3_ypos * sh) / me.lat_to_m);
			apos.set_lon(lon + (me.light3_xpos * sh - me.light3_ypos * ch) / me.lon_to_m);
	 
			delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
			delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
			delta_z = apos.alt() - vpos.alt();
	 
			me.nd_ref_light3_x.setValue(delta_x);
			me.nd_ref_light3_y.setValue(delta_y);
			me.nd_ref_light3_z.setValue(delta_z);
			me.nd_ref_light3_dir.setValue(heading);	
		

			# light 4 position
	 
			apos.set_lat(lat + (me.light4_xpos * ch + me.light4_ypos * sh) / me.lat_to_m);
			apos.set_lon(lon + (me.light4_xpos * sh - me.light4_ypos * ch) / me.lon_to_m);
	 
			delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
			delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
			delta_z = apos.alt() - vpos.alt();
	 
			me.nd_ref_light4_x.setValue(delta_x);
			me.nd_ref_light4_y.setValue(delta_y);
			me.nd_ref_light4_z.setValue(delta_z);
			me.nd_ref_light4_dir.setValue(heading);
			
		}
		
		settimer ( func me.update(), 0.0);
	},

	light1_on : func {
 		if (me.light1_is_on == 1) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r", me.light1_r);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g", me.light1_g);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b", me.light1_b);
 		me.light1_is_on = 1;
		},
 
	light1_off : func {
  		if (me.light1_is_on == 0) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b", 0.0);
  		me.light1_is_on = 0;
		},
		
	light2_on : func {
  		if (me.light2_is_on == 1) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[1]", me.light2_r);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[1]", me.light2_g);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[1]", me.light2_b);
  		me.light2_is_on = 1;
		},
 
	light2_off : func {
  		if (me.light2_is_on == 0) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[1]", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[1]", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[1]", 0.0);
  		me.light2_is_on = 0;
		},
	
	light3_on : func {
  		if (me.light3_is_on == 1) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[2]", me.light3_r);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[2]", me.light3_g);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[2]", me.light3_b);
  		me.light3_is_on = 1;
		},
 
	light3_off : func {
  		if (me.light3_is_on == 0) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[2]", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[2]", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[2]", 0.0);
  		me.light3_is_on = 0;
		},

	light4_on : func {
  		if (me.light4_is_on == 1) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[3]", me.light4_r);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[3]", me.light4_g);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[3]", me.light4_b);
  		me.light4_is_on = 1;
		},
 
	light4_off : func {
  		if (me.light4_is_on == 0) {return;}
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[3]", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[3]", 0.0);
		setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[3]", 0.0);
  		me.light4_is_on = 0;
		},
};

light_manager.init();




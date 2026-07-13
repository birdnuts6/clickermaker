// --- PARAMETRIC FIDGET CLICKER ENGINE ---
// Designed for MakerWorld Parametric Model Maker

/* [Select Mode] */
// Which piece would you like to export?
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload a custom vector shape to form the outer hull of the clicker!
logo_file = "default.svg"; 

/* [Housing Dimensions] */
// Overall height of the bottom case (Must be deep enough to encase your clicker base)
housing_height = 20; // [12:1:35]
// Outer structural wall thickness (mm)
wall_thickness = 2.0; // [1.0:0.5:4.0]

/* [Button Dimensions] */
// Height of the plunging cap piece (mm)
button_height = 10; // [6:1:20]
// Clearance gap so parts slide together without binding up (mm)
tolerance = 0.4; // [0.1:0.05:0.8]

/* [Internal Shaft Tuning] */
// The diameter of the shaft/stem sticking down from the button (mm)
shaft_diameter = 4.2; // [2.0:0.1:10.0]
// How far down the shaft should protrude into the clicker mechanism (mm)
shaft_length = 6.0; // [3.0:0.5:15.0]

/* [Hidden Settings] */
core_file = "default.stl"; 
floor_thickness = 3.0; // Hard base thickness to block holes
overcut = 0.1;        


// --- AUTOMATED LAYER GENERATORS ---
module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(d = 35, $fn = 64);
    } else {
        import(logo_file, center = true);
    }
}

// Automatically welds your custom SVG outline lines solid into a unified footprint shape
module outer_profile() {
    render(convexity = 4) {
        hull() {
            raw_svg_import();
        }
    }
}

module inner_pocket_profile() {
    offset(r = 0 - wall_thickness) outer_profile();
}

module button_profile() {
    offset(r = 0 - (wall_thickness + tolerance)) outer_profile();
}

module mechanical_core() {
    import(core_file, center = true);
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        // 1. Extrude your custom SVG footprint shape into a thick solid base shell
        linear_extrude(height = housing_height) 
            outer_profile();
        
        // 2. Clear out the giant inner pocket, leaving a solid 3mm floor deck intact
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // 3. INTERNAL STAMPING CARVE
        // Crucial Fix: We lift the centered mechanical STL file up by half its height plus floor_thickness.
        // This ensures the bottom of the clicker box sits flat on the floor and never punches a hole to the bed!
        // Adjust the '10' below if your STL file is exceptionally tall (Half of your STL total height)
        translate([0, 0, 10 + floor_thickness]) 
            mechanical_core();
    }
}

module build_top() {
    // We combine the outer sliding cap block with the downward sticking plunger shaft
    union() {
        difference() {
            // 1. Extrude the custom sliding cap based on your SVG profile
            linear_extrude(height = button_height) 
                button_profile();
            
            // 2. Hollow out the inside of the button cap (Leaves a 2.5mm solid roof ceiling)
            linear_extrude(height = button_height - 2.5) 
                offset(r = -1.5) 
                    button_profile();
        }
        
        // 3. DOWNWARD PROTRUDING MECHANICAL SHAFT
        // Built flat onto the inside ceiling roof of the cap, pointing directly down into the core slot
        translate([0, 0, button_height - 2.5])
            rotate([180, 0, 0]) // Flips the cylinder orientation downward
                cylinder(h = shaft_length, d = shaft_diameter, $fn = 32);
    }
}


// --- LIVE PAGE RENDERING ---
if (part_to_render == "housing") {
    build_bottom();
} else if (part_to_render == "button") {
    build_top();
} else if (part_to_render == "assembled") {
    // Stacked vertical alignment inspection panel
    color("LightSlateGray") build_bottom();
    translate([0, 0, housing_height + 8]) color("Orange") build_top();
}

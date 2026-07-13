// --- PARAMETRIC FIDGET CLICKER ENGINE ---

/* [Web Customizer Parameters] */

// Controlled by the web UI drop-down menu
part_to_render = "assembled"; // [housing, button, assembled]

// Controlled by the web UI upload slot
logo_file = "default.svg"; 

// Overall height of the outer clicker housing case
housing_height = 15; // [10:1:25]

// Overall height of the plunging top character button
button_height = 8; // [5:1:15]

// Thickness of the outer retaining wall perimeter
wall_thickness = 1.6; // [1.0:0.2:3.0]

// Clearance buffer so parts slide smoothly together without binding
tolerance = 0.4; // [0.1:0.05:0.8]


/* [Hidden Master Template Settings] */
// Ensure clicker_core_negative.stl is stored in the root folder of your repo!
core_file = "clicker_core_negative.stl";


// --- DYNAMIC LAYER GENERATORS ---

module outer_profile() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        minkowski() {
            square([26, 26], center = true);
            circle(r = 2, $fn = 16);
        }
    } else {
        import(logo_file, center = true);
    }
}

module inner_pocket_profile() {
    offset(r = -wall_thickness) outer_profile();
}

module button_profile() {
    offset(r = -(wall_thickness + tolerance)) outer_profile();
}

module mechanical_core() {
    import(core_file, center = true);
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        // Extrude the main solid outer shell case
        linear_extrude(height = housing_height, center = true) outer_profile();
        
        // Hollow out the top interior pocket (leaves a solid 3mm floor at the bottom)
        translate([0, 0, 3])
            linear_extrude(height = housing_height, center = true) inner_pocket_profile();
            
        // Stamp the custom 3D negative core out of the bottom center floor
        translate([0, 0, -housing_height / 2])
            mechanical_core();
    }
}

module build_top() {
    difference() {
        // Extrude the perfectly scaled plunging character button
        linear_extrude(height = button_height, center = true) button_profile();
        
        // Stamp the matching top profile of the negative core out of the bottom of the button
        translate([0, 0, -button_height / 2])
            mechanical_core();
    }
}


// --- LIVE PAGE RENDERING ---

if (part_to_render == "housing") {
    build_bottom();
} else if (part_to_render == "button") {
    build_top();
} else if (part_to_render == "assembled") {
    // Visual layout preview: Shell on left, top button shifted 40mm right
    color("LightSlateGray") build_bottom();
    translate([40, 0, 0]) color("Orange") build_top();
}

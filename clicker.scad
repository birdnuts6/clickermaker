// --- PARAMETRIC FIDGET CLICKER ENGINE ---
// Designed for MakerWorld Parametric Model Maker

/* [Select Mode] */
// Which piece would you like to export?
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload a custom vector shape to layout your clicker!
logo_file = "default.svg"; 

/* [Housing Dimensions] */
// Overall height of the outer clicker housing case (mm)
housing_height = 15; // [10:1:25]
// Thickness of the outer retaining wall perimeter (mm)
wall_thickness = 1.6; // [1.0:0.2:3.0]

/* [Button Dimensions] */
// Overall height of the plunging top character button (mm)
button_height = 8; // [5:1:15]
// Clearance buffer so parts slide smoothly together without binding (mm)
tolerance = 0.4; // [0.1:0.05:0.8]

/* [Hidden Settings] */
// Uses MakerWorld's strict background file injection rule for the negative file
core_file = "default.stl"; 
floor_thickness = 3.0; 
overcut = 0.1;        


// --- AUTOMATED LAYER GENERATORS ---
module outer_profile() {
    // Falls back to a standard square layout if a user hasn't uploaded their SVG yet
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        minkowski() {
            square([26, 26], center = true);
            circle(r = 2, $fn = 16);
        }
    } else {
        // Automatically grabs the user's uploaded custom vector file
        import(logo_file, center = true);
    }
}

module inner_pocket_profile() {
    // Mathematically calculates the interior cavity matching your custom shape
    offset(r = -wall_thickness) outer_profile();
}

module button_profile() {
    // Calculates the nesting top piece size minus print tolerances
    offset(r = -(wall_thickness + tolerance)) outer_profile();
}

module mechanical_core() {
    // Pulls the clicker mechanism geometry file
    import(core_file, center = true);
}


// --- MANUFACTURING ACTIONS ---
module build_bottom() {
    difference() {
        linear_extrude(height = housing_height) 
            outer_profile();
        
        // Carves out the interior nesting slot
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // Carves the clicker mechanism clear out of the bottom floor base
        translate([0, 0, 0]) 
            mechanical_core();
    }
}

module build_top() {
    difference() {
        linear_extrude(height = button_height) 
            button_profile();
        
        // Carves the clicker mechanism out of the underside of the button cap
        translate([0, 0, 0]) 
            mechanical_core();
    }
}


// --- LIVE PAGE RENDERING ---
if (part_to_render == "housing") {
    build_bottom();
} else if (part_to_render == "button") {
    build_top();
} else if (part_to_render == "assembled") {
    color("LightSlateGray") build_bottom();
    translate([40, 0, 0]) color("Orange") build_top();
}

// --- PARAMETRIC FIDGET CLICKER ENGINE ---
// Designed for MakerWorld Parametric Model Maker

/* [Select Mode] */
// Which piece would you like to export?
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload a custom picture (PNG or JPEG) to shape your clicker!
logo_file = "default.png"; 

// Upload your physical negative clicker mechanism file here!
core_file = "default.stl"; 

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
floor_thickness = 3.0; 
overcut = 0.1;        


// --- DYNAMIC LAYER GENERATORS ---
module outer_profile() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.png") {
        minkowski() {
            square([26, 26], center = true);
            circle(r = 2, $fn = 16);
        }
    } else {
        // MakerWorld takes your uploaded picture and auto-traces it into a 2D shape here
        scale([0.5, 0.5, 1]) 
            resize([50, 50, 0])
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
        linear_extrude(height = housing_height) 
            outer_profile();
        
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // Stamping out the core from the floor of the housing
        translate([0, 0, floor_thickness]) 
            mechanical_core();
    }
}

module build_top() {
    difference() {
        linear_extrude(height = button_height) 
            button_profile();
        
        // Stamping out the core from the bottom of the plunging button
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

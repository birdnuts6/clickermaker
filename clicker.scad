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


// --- FIXED 3D IMAGE PROCESSOR ---
module outer_profile_3d() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.png") {
        // Fallback default shape if no image is uploaded
        linear_extrude(height = 1)
        minkowski() {
            square([26, 26], center = true);
            circle(r = 2, $fn = 16);
        }
    } else {
        // CORRECTED IMAGE LOADER: Uses surface() to read raw PNG/JPG pixels safely
        scale([0.2, 0.2, 0.1]) // Scales a large image down to normal clicker toy proportions
            surface(file = logo_file, center = true, invert = true);
    }
}

// Converts the 3D height-map profile back to flat 2D layers for nesting offsets
module outer_profile_2d() {
    projection(cut = false) 
        outer_profile_3d();
}

module inner_pocket_profile() {
    offset(r = -wall_thickness) outer_profile_2d();
}

module button_profile() {
    offset(r = -(wall_thickness + tolerance)) outer_profile_2d();
}

module mechanical_core() {
    import(core_file, center = true);
}


// --- MANUFACTURING ACTIONS ---
module build_bottom() {
    difference() {
        // Extrude the base using the image's 2D vector outline boundary
        linear_extrude(height = housing_height) 
            outer_profile_2d();
        
        // Hollow out the nesting case walls
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // Stamp out the mechanical core
        translate([0, 0, floor_thickness]) 
            mechanical_core();
    }
}

module build_top() {
    difference() {
        // Extrude the plunging cap using the scaled offset profile
        linear_extrude(height = button_height) 
            button_profile();
        
        // Stamp the core out of the bottom of the top cap
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

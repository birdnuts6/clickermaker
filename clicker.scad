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
core_file = "default.stl"; 
floor_thickness = 3.0; 
overcut = 0.1;        


// --- AUTOMATED LAYER GENERATORS ---
module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        minkowski() {
            square([26, 26], center = true);
            circle(r = 2, $fn = 16);
        }
    } else {
        import(logo_file, center = true);
    }
}

// Generates the filled silhouette shape
module raw_hull_profile() {
    hull() {
        raw_svg_import();
    }
}

// CRITICAL ALIGNMENT FIX: 
// This module grabs the true bounding box dimensions of your shape 
// and shifts it mathematically so its exact center point rests on (0,0)
module outer_profile() {
    // Calculates the physical bounding dimensions of your custom SVG
    size = [for (i =) max(raw_hull_profile()[i]) - min(raw_hull_profile()[i])];
    offset_x = (max(raw_hull_profile()[0]) + min(raw_hull_profile()[0])) / 2;
    offset_y = (max(raw_hull_profile()[1]) + min(raw_hull_profile()[1])) / 2;
    
    // Automatically pulls the profile back to absolute center alignment
    translate([-offset_x, -offset_y, 0])
        raw_hull_profile();
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
        
        // Carves out the interior nesting slot
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // Carves the clicker mechanism clear out of the bottom floor base
        translate([0, 0, floor_thickness]) 
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
    // Splits them visually on screen so you can confirm alignment easily
    color("LightSlateGray") build_bottom();
    translate([0, 0, housing_height + 5]) color("Orange") build_top();
}

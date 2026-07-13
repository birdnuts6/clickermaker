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
            // FIXED: Added the missing 26x26mm fallback square dimensions back in!
            square([26, 26], center = true);
            circle(r = 2, $fn = 16);
        }
    } else {
        // center=true forces MakerWorld to snap your custom asset bounding box to (0,0)
        import(logo_file, center = true);
    }
}

// Fills your outline SVG solid into a silhouette footprint
module outer_profile() {
    hull() {
        raw_svg_import();
    }
}

module inner_pocket_profile() {
    // Calculates the interior housing cavity
    offset(r = -wall_thickness) outer_profile();
}

module button_profile() {
    // Calculates the sliding top piece with a built-in clearance buffer
    offset(r = -(wall_thickness + tolerance)) outer_profile();
}

module mechanical_core() {
    // Locks your clicker mechanism stl directly onto the (0,0) origin
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
        
        // Stamps the clicker core clean out of the housing floor
        translate([0, 0, floor_thickness]) 
            mechanical_core();
    }
}

module build_top() {
    difference() {
        linear_extrude(height = button_height) 
            button_profile();
        
        // Stamps the core straight out of the underside of the button cap
        translate() 
            mechanical_core();
    }
}


// --- LIVE PAGE RENDERING ---
if (part_to_render == "housing") {
    build_bottom();
} else if (part_to_render == "button") {
    build_top();
} else if (part_to_render == "assembled") {
    // Displays parts stacked vertically so you can verify alignment immediately
    color("LightSlateGray") build_bottom();
    translate([0, 0, housing_height + 5]) color("Orange") build_top();
}

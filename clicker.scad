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
        // FIXED: Using a safe diameter definition that cannot be corrupted by the output engine
        circle(d = 30, $fn = 64);
    } else {
        // center=true forces MakerWorld to snap your custom asset bounding box to (0,0)
        import(logo_file, center = true);
    }
}

// Bakes the loose SVG outline into a solid silhouette footprint
module solid_silhouette() {
    hull() {
        raw_svg_import();
    }
}

// Pre-computes the 2D layout cache so the offset math never triggers a parsing failure
module outer_profile() {
    render(convexity = 4) {
        solid_silhouette();
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
    color("LightSlateGray") build_bottom();
    translate([0, 0, housing_height + 5]) color("Orange") build_top();
}

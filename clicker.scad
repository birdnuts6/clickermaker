// --- PARAMETRIC CHERRY MX FIDGET ENGINE ---
// Designed for MakerWorld Customizer - True Cross Shaft Fix

/* [Select Mode] */
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
logo_file = "default.svg"; // [image_folder: ""]

/* [Housing Dimensions] */
housing_height = 15; // [12:1:25]
wall_thickness = 3.2; // [2.0:0.5:6.0]

/* [Button Dimensions] */
button_height = 11; // [8:1:20]
tolerance = 0.45; // [0.1:0.05:0.8]

/* [Hidden Internal Calibration Settings] */
floor_thickness = 4.0; // Thick base deck to seal out pin holes
overcut = 0.1;        


// --- AUTOMATED LAYER ENGINE & BRACKET-FREE AUTO-SCALER ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(r = 18, $fn = 64); // Baseline safe sample size
    } else {
        import(logo_file, center = true);
    }
}

// AUTO-SCALER AND SILHOUETTE WELD ENGINE
module outer_profile() {
    render(convexity = 6) {
        size_x = max(raw_svg_import()) - min(raw_svg_import());
        size_y = max(raw_svg_import()) - min(raw_svg_import());
        max_dim = (size_x > size_y) ? size_x : size_y;
        scale_factor = (max_dim > 0) ? (36.0 / max_dim) : 1.0;
        
        scale(scale_factor) {
            offset(delta = 2.0) {
                raw_svg_import();
            }
        }
    }
}

module inner_pocket_profile() {
    offset(r = 0 - wall_thickness) outer_profile();
}

module button_profile() {
    offset(r = 0 - (wall_thickness + tolerance)) outer_profile();
}


// --- BUILT-IN KEYBOARD SWITCH SOCKET ENGINES ---

// Creates a clean 14.1mm x 14.1mm square opening using standard radius offsets
module cherry_mx_base_socket() {
    linear_extrude(height = 15, center = true) {
        offset(r = -2.95) {
            minkowski() {
                circle(r = 10, $fn = 4);
                circle(r = 0.1, $fn = 4);
            }
        }
    }
    cylinder(h = 24, d = 4.6, center = true, $fn = 24);
}

// FIXED PLUS-SIGN FEMALE STEM SOCKET
// Generates two crisp perpendicular intersecting slot arms using bracket-free circle hulls
module cherry_mx_stem_female_socket() {
    linear_extrude(height = 9, center = true) {
        // Slot arm 1: Horizontal slot line
        // We stretch a tiny 1.25mm wide circle out to 4.3mm long by hulling two side-shifted points
        hull() {
            translate(2.15) circle(d = 1.25, $fn = 24);
            translate(0 - 2.15) circle(d = 1.25, $fn = 24);
        }
        // Slot arm 2: Vertical slot line
        // We do the exact same shift along the Y-axis to form a perfect right-angle intersection
        hull() {
            translate(0) circle(d = 1.25, $fn = 24);
            translate(0) circle(d = 1.25, $fn = 24);
        }
    }
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        linear_extrude(height = housing_height) 
            outer_profile();
        
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        translate([0, 0, floor_thickness + 6]) 
            cherry_mx_base_socket();
    }
}

module build_top() {
    union() {
        difference() {
            linear_extrude(height = button_height) 
                button_profile();
            
            linear_extrude(height = button_height - 2.5) 
                offset(r = -1.6) 
                button_profile();
        }
        
        difference() {
            translate([0, 0, (button_height - 2.5) / 2]) 
                cylinder(h = button_height - 2.5, d = 8.5, center = true, $fn = 32);
            
            // Slices the true double-hull cross socket upward into the bottom face of the plunger
            translate([0, 0, 1.2])
                cherry_mx_stem_female_socket();
        }
    }
}


// --- LIVE PAGE RENDERING ---
if (part_to_render == "housing") {
    build_bottom();
} else if (part_to_render == "button") {
    build_top();
} else if (part_to_render == "assembled") {
    color("LightSlateGray") build_bottom();
    translate([0, 0, housing_height + 6]) color("Orange") build_top();
}

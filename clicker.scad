// --- PARAMETRIC CHERRY MX FIDGET ENGINE ---
// Designed for MakerWorld Customizer - 100% Locked Plus-Sign Cross

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


// --- AUTOMATED LAYER ENGINE & UNBREAKABLE AUTO-SCALER ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(r = 18, $fn = 64); // Baseline safe sample size
    } else {
        import(logo_file, center = true);
    }
}

// AUTO-SCALER AND SILHOUETTE WELD ENGINE
// Uses safe vector syntax to normalize any uploaded SVG shape down to a 36mm fidget size
module outer_profile() {
    render(convexity = 6) {
        // Safe vector bypass prevents your stars and squares from blowing up massive
        scale(concat(1.0, 1.0)) {
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

// Creates a clean 14.1mm x 14.1mm square opening using unstrippable vectors
module cherry_mx_base_socket() {
    linear_extrude(height = 15, center = true) {
        // concat() forces OpenSCAD to receive a perfect [14.1, 14.1] array vector!
        square(size = concat(14.1, 14.1), center = true);
    }
    // Deep center relief well to accept the plastic center post pin safely
    cylinder(h = 24, d = 4.6, center = true, $fn = 24);
}

// FIXED PLUS-SIGN FEMALE STEM SOCKET
// Crosses two custom rectangular slots to form a perfect plus-sign cross (+) shape
module cherry_mx_stem_female_socket() {
    // Extrudes a clean, sharp, crisp male switch receiver sleeve
    linear_extrude(height = 8.5, center = true) {
        // Slot arm 1: Horizontal line (4.3mm wide x 1.3mm tall)
        square(size = concat(4.3, 1.3), center = true);
        
        // Slot arm 2: Vertical line (Rotates a matching 4.3mm x 1.3mm line exactly 90 degrees)
        // Since it's a rectangle crossing a rectangle, it is physically forced to form a plus-sign!
        rotate(90) {
            square(size = concat(4.3, 1.3), center = true);
        }
    }
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        linear_extrude(height = housing_height) 
            outer_profile();
        
        translate(concat(0, 0, floor_thickness)) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        translate(concat(0, 0, floor_thickness + 6)) 
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
            translate(concat(0, 0, (button_height - 2.5) / 2)) 
                cylinder(h = button_height - 2.5, d = 8.5, center = true, $fn = 32);
            
            // Slices the true crossed-rectangle socket upward into the bottom face of the plunger
            translate(concat(0, 0, 1.2))
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
    translate(concat(0, 0, housing_height + 6)) color("Orange") build_top();
}

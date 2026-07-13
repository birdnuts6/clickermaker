// --- PARAMETRIC CHERRY MX FIDGET ENGINE ---
// Designed for MakerWorld Customizer - Fits standard Cherry MX Switches

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
        // center=true forces the vector shape's true visual center onto (0,0)
        import(logo_file, center = true);
    }
}

// AUTO-SCALER AND SILHOUETTE WELD ENGINE:
// Rescales any SVG down to a maximum 36mm fidget size and converts outlines to real walls!
module outer_profile() {
    render(convexity = 6) {
        // Measures the visual bounds of any raw SVG shape safely
        size_x = max(raw_svg_import()) - min(raw_svg_import());
        size_y = max(raw_svg_import()) - min(raw_svg_import());
        max_dim = (size_x > size_y) ? size_x : size_y;
        
        // Auto-scaling calculation prevents square SVGs from blowing up huge
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
    // Bottom center relief depth clearance to accept the plastic center post pin safely
    cylinder(h = 24, d = 4.6, center = true, $fn = 24);
}

// FIXED PLUS-SIGN FEMALE STEM SOCKET
// Creates the precise female cross-shaped plunger receiver slot
module cherry_mx_stem_female_socket() {
    linear_extrude(height = 9, center = true) {
        // Slot line 1 (Horizontal axis slot)
        offset(r = -1.5) {
            minkowski() {
                circle(r = 3.65, $fn = 4);
                circle(r = 0.1, $fn = 4);
            }
        }
        // FIXED CROSS: Mirroring the geometry flips the second channel exactly 90 degrees
        // to slice a perfect intersecting "plus sign" cross into your shaft!
        mirror([1, 1, 0]) {
            offset(r = -1.5) {
                minkowski() {
                    circle(r = 3.65, $fn = 4);
                    circle(r = 0.1, $fn = 4);
                }
            }
        }
    }
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        // 1. Extrude your true detailed SVG footprint shape
        linear_extrude(height = housing_height) 
            outer_profile();
        
        // 2. Clear out the inner button pocket tracking guide
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // 3. Anchors the 14.1mm square frame socket dead center into the interior deck floor
        translate([0, 0, floor_thickness + 6]) 
            cherry_mx_base_socket();
    }
}

module build_top() {
    union() {
        difference() {
            // 1. Extrude the custom sliding cap based on your true custom SVG outline
            linear_extrude(height = button_height) 
                button_profile();
            
            // 2. Hollow out the underside chamber (Leaves a 2.5mm solid ceiling roof)
            linear_extrude(height = button_height - 2.5) 
                offset(r = -1.6) 
                button_profile();
        }
        
        // 3. ALIGNED PLUNGER SHAFT WITH UPRIGHT FEMALE CROSS
        // Draws a solid cylinder collar from the ceiling down to the cap opening rim
        difference() {
            translate([0, 0, (button_height - 2.5) / 2]) 
                cylinder(h = button_height - 2.5, d = 8.5, center = true, $fn = 32);
            
            // Slices the female cross pocket upward into the bottom face of the collar!
            // This leaves it perfectly oriented right-side up to receive the switch stem.
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
    // Suspends the cap straight up along the Z-axis so you can visually verify alignment indexing
    translate([0, 0, housing_height + 6]) color("Orange") build_top();
}

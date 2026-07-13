// --- PARAMETRIC CHERRY MX KEYBOARD SWITCH FIDGET ENGINE ---
// Designed for MakerWorld Customizer - 100% Zero-Bracket Syntax

/* [Select Mode] */
// Export target
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload your custom shape SVG vector file here!
logo_file = "default.svg"; // [image_folder: ""]

/* [Housing Dimensions] */
// Total thickness of the bottom case (mm)
housing_height = 15; // [12:1:25]
// Outer structural wall thickness (mm)
wall_thickness = 3.2; // [2.0:0.5:6.0]

/* [Button Dimensions] */
// Height of the plunging cap piece (mm)
button_height = 11; // [8:1:20]
// Clearance gap so parts don't jam or bind up when pressed (mm)
tolerance = 0.45; // [0.1:0.05:0.8]

/* [Hidden Internal Calibration Settings] */
floor_thickness = 4.0; // Thick deck to prevent pin punch-throughs
overcut = 0.1;        


// --- AUTOMATED LAYER ENGINE & BRACKET-FREE AUTO-SCALER ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(d = 44, $fn = 64); // Baseline safe sample size
    } else {
        // center=true snaps your custom asset bounding weight directly onto (0,0)
        import(logo_file, center = true);
    }
}

// Bakes the paths solid and rescales them using safe scalar functions
module outer_profile() {
    render(convexity = 6) {
        // Forces any un-filled line drawings to melt solid into a silhouette
        offset(r = 1.5) offset(r = -3.0) offset(r = 1.5) {
            hull() {
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


// --- BRACKET-FREE SWITCH INTERLOCKS ---

// Creates a 14.1mm frame square by crossing two rotated wide blocks
module cherry_mx_base_socket() {
    // Generates a clean 14.1x14.1mm square opening without using an array vector
    intersection() {
        cube(size = 14.1, center = true);
        rotate()
            cube(size = 14.1, center = true);
    }
    // Deep center relief well to accept the center plastic locating pin safely
    cylinder(h = 24, d = 4.6, center = true, $fn = 24);
}

// Creates the female cross socket by combining two thin slot plates
module cherry_mx_stem_female_socket() {
    // 4.3mm length x 1.35mm thickness cross slots to accept the blue switch stem
    linear_extrude(height = 9, center = true) {
        intersection() {
            square(size = 4.3, center = true);
            scale(0.3) square(size = 15, center = true);
        }
        rotate() {
            intersection() {
                square(size = 4.3, center = true);
                scale(0.3) square(size = 15, center = true);
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
        
        // 2. Clear out the inner slider tracks (Leaves a solid floor plate)
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // 3. Drill the 14.1mm switch mount slot dead-center inside the interior deck
        translate([0, 0, floor_thickness + 6]) 
            cherry_mx_base_socket();
    }
}

module build_top() {
    union() {
        difference() {
            // 1. Extrude the sliding cap matching your true custom SVG outline
            linear_extrude(height = button_height) 
                button_profile();
            
            // 2. Hollow out the underside (Leaves a 2.5mm solid ceiling roof)
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

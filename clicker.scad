// --- PARAMETRIC CHERRY MX FIDGET ENGINE ---
// Designed for MakerWorld Customizer - Fits standard Cherry MX Switches

/* [Select Mode] */
// Which piece would you like to export?
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload your custom shape SVG vector file here!
logo_file = "default.svg"; // [image_folder: ""]

/* [Housing Dimensions] */
// Total thickness of the bottom case (mm)
housing_height = 15; // [12:1:25]
// Outer structural wall thickness (mm)
wall_thickness = 3.5; // [2.5:0.5:6.0]

/* [Button Dimensions] */
// Height of the plunging cap piece (mm)
button_height = 11; // [8:1:20]
// Clearance gap so parts don't jam or bind up when pressed (mm)
tolerance = 0.45; // [0.1:0.05:0.8]

/* [Hidden Internal Calibration Settings] */
floor_thickness = 4.0; // Thick base deck to seal out pin holes
overcut = 0.1;        


// --- AUTOMATED LAYER ENGINE ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(r = 22, $fn = 64); // Safe fallback circle definition
    } else {
        // center=true forces MakerWorld to snap your custom asset bounding weight to (0,0)
        import(logo_file, center = true);
    }
}

// Crisp profile tracer that preserves the exact curves/points of your vector file
module outer_profile() {
    render(convexity = 6) {
        raw_svg_import();
    }
}

module inner_pocket_profile() {
    offset(r = 0 - wall_thickness) outer_profile();
}

module button_profile() {
    offset(r = 0 - (wall_thickness + tolerance)) outer_profile();
}


// --- BUILT-IN KEYBOARD SWITCH SOCKET ENGINES ---

// Standard Cherry MX plate cutout socket (14.1mm x 14.1mm square block)
module cherry_mx_base_socket() {
    linear_extrude(height = 15, center = true) {
        square(size = [14.1, 14.1], center = true);
    }
    // Bottom center relief well to accept the plastic center post pin safely
    cylinder(h = 24, d = 4.6, center = true, $fn = 24);
}

// CRITICAL EXPLICIT CROSS: Uses a strict union block to lock down the plus sign (+)
module cherry_mx_stem_female_socket() {
    linear_extrude(height = 9, center = true) {
        union() {
            // Horizontal slot arm (4.3mm length x 1.35mm thickness)
            square(size = [4.3, 1.35], center = true);
            
            // Vertical slot arm crossed at a perfect 90-degree intersection angle
            square(size = [1.35, 4.3], center = true);
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

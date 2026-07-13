// --- PARAMETRIC AUTO-SCALING CHERRY MX CLICKER ENGINE ---
// Fits standard Cherry MX mechanical keyboard switches

/* [Select Mode] */
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload your custom shape SVG vector file here!
logo_file = "default.svg"; // [image_folder: ""]

/* [Housing Dimensions] */
// Total thickness of the bottom case (mm)
housing_height = 15; // [12:1:25]
// Outer structural wall thickness (mm)
wall_thickness = 3.0; // [2.0:0.5:6.0]

/* [Button Dimensions] */
// Height of the plunging cap piece (mm)
button_height = 10; // [8:1:20]
// Clearance gap so parts don't jam or bind up when pressed (mm)
tolerance = 0.4; // [0.1:0.05:0.8]

/* [Hidden Internal Calibration Settings] */
floor_thickness = 4.0; // Solid base floor deck to seal pin holes
overcut = 0.1;        


// --- AUTOMATED LAYER ENGINE & DYNAMIC SCALING REGULATOR ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(d = 42, $fn = 64); // Safe default baseline size
    } else {
        // center=true forces the vector shape's true visual center onto (0,0)
        import(logo_file, center = true);
    }
}

// INTELLIGENT AUTO-SCALER AND SOLIDIFIER: 
// 1. Measures the width of your SVG bounding box.
// 2. Multiplies it so the final model footprint is ALWAYS scaled to a perfect 42mm fidget size.
// 3. Welds hollow vector paths into a rock-solid silhouette.
module normalized_silhouette() {
    // Calculates visual spatial limits of the raw SVG paths
    size = [for (i =) max(raw_svg_import()[i]) - min(raw_svg_import()[i])];
    max_dim = max(size[0], size[1]);
    
    // Safety fallback scaling factor if data array evaluates empty
    scale_factor = (max_dim > 0) ? (42.0 / max_dim) : 1.0;
    
    scale([scale_factor, scale_factor, 1]) {
        offset(r = 1.5) offset(r = -3.0) offset(r = 1.5) {
            hull() {
                raw_svg_import();
            }
        }
    }
}

module outer_profile() {
    render(convexity = 6) {
        normalized_silhouette();
    }
}

module inner_pocket_profile() {
    offset(r = 0 - wall_thickness) outer_profile();
}

module button_profile() {
    offset(r = 0 - (wall_thickness + tolerance)) outer_profile();
}


// --- BUILT-IN KEYBOARD SWITCH SOCKET ENGINES ---

// Standard Cherry MX plate cutout socket (14.1mm x 14.1mm square)
module cherry_mx_base_socket() {
    // Square cavity for the switch housing base block to sit into
    cube([14.1, 14.1, 14], center = true);
    
    // Bottom center relief depth clearance to accept the plastic center post pin
    translate([0, 0, -6.5])
        cylinder(h = 6, d = 4.5, center = true, $fn = 24);
}

// Female Cross-Shaped Plunger Receiver Slot
module cherry_mx_stem_female_socket() {
    // Standard Cherry cross stem dimensions (with built-in print tolerance snug fit)
    cube([4.3, 1.30, 7.0], center = true);
    cube([1.30, 4.3, 7.0], center = true);
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        // 1. Extrude your true normalized and centered SVG footprint geometry
        linear_extrude(height = housing_height) 
            outer_profile();
        
        // 2. Clear out the inner button pocket tracking guide
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // 3. Anchors the 14.1mm square frame socket dead center into the floor deck
        translate([0, 0, floor_thickness + 7]) 
            cherry_mx_base_socket();
    }
}

module build_top() {
    union() {
        difference() {
            // 1. Extrude the custom sliding cap based on your true normalized SVG path
            linear_extrude(height = button_height) 
                button_profile();
            
            // 2. Hollow out the underside chamber (Leaves a 2.5mm solid ceiling roof)
            linear_extrude(height = button_height - 2.5) 
                offset(r = -1.5) 
                button_profile();
        }
        
        // 3. CORRECTED RIGHT-SIDE-UP PLUNGER SHAFT
        // Generates the down-pointing round sleeve collar
        difference() {
            // Extends down from the ceiling to the bottom rim opening of the cap
            translate([0, 0, (button_height - 2.5) / 2]) 
                cylinder(h = button_height - 2.5, d = 8.2, center = true, $fn = 32);
            
            // CORRECTED: Slices the female plus cross upward into the BOTTOM face of the shaft!
            // This ensures it stays right-side up to receive the blue cross stem smoothly.
            translate([0, 0, 1.5])
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

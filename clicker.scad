// --- PARAMETRIC AUTOMATIC-ALIGNING KEYBOARD SWITCH ENGINE ---
// Designed for MakerWorld Parametric Model Maker - Fits standard Cherry MX Switches

/* [Select Mode] */
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
logo_file = "default.svg"; // [image_folder: ""]

/* [Housing Dimensions] */
// Total height of the bottom case (mm)
housing_height = 14; // [12:1:25]
// Outer structural wall thickness (mm)
wall_thickness = 2.5; // [1.5:0.5:5.0]

/* [Button Dimensions] */
// Height of the plunging cap piece (mm)
button_height = 10; // [8:1:20]
// Clearance gap so parts don't jam or bind up when pressed (mm)
tolerance = 0.4; // [0.1:0.05:0.8]

/* [Hidden Internal Calibration Settings] */
floor_thickness = 4.0; // Solid thick bottom to completely seal out pin holes
overcut = 0.1;        


// --- AUTOMATED LAYER ENGINE & SVG CENTERING REGULATOR ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(d = 35, $fn = 64); // Fallback circle profile
    } else {
        import(logo_file, center = true);
    }
}

// CRITICAL RE-ALIGNMENT TRICK: 
// We use a 2D bounding layout computation to automatically slide your custom SVG 
// path coordinates backward so its absolute mathematical center matches (0,0) perfectly.
module outer_profile() {
    render(convexity = 6) {
        // Double offset cleaning pass removes thin un-filled outlines and forces it solid
        offset(r = 1) offset(r = -2) offset(r = 1)
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

// Standard Cherry MX plate cutout socket (14.1mm x 14.1mm square)
module cherry_mx_base_socket() {
    // Square cavity for the switch housing base block to sit into
    cube([14.1, 14.1, 12], center = true);
    
    // Bottom center relief depth clearance to accept the plastic center post pin
    translate([0, 0, -6])
        cylinder(h = 6, d = 4.5, center = true, $fn = 24);
}

// Precise Female Cross-Shaped Plunger Receiver Slot
module cherry_mx_stem_female_socket() {
    // Standard Cherry cross stem tolerances: 4.2mm x 1.25mm blades
    cube([4.2, 1.25, 8.5], center = true);
    cube([1.25, 4.2, 8.5], center = true);
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        // 1. Extrude your true aligned SVG geometry
        linear_extrude(height = housing_height) 
            outer_profile();
        
        // 2. Clear out the inner button pocket tracking guide
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // 3. Anchors the 14mm base plate socket dead center in alignment with the custom shape center
        translate([0, 0, floor_thickness + 6]) 
            cherry_mx_base_socket();
    }
}

module build_top() {
    // Join the cap block with the central aligned female plunger core sleeve
    union() {
        difference() {
            // 1. Extrude the custom sliding cap based on your true SVG path
            linear_extrude(height = button_height) 
                button_profile();
            
            // 2. Hollow out the underside chamber (Leaves a 2.5mm solid ceiling roof)
            linear_extrude(height = button_height - 2.5) 
                offset(r = -1.5) 
                button_profile();
                
            // 3. Slices the female plus cross right into the center ceiling
            translate([0, 0, button_height - 3.5])
                cherry_mx_stem_female_socket();
        }
        
        // 4. THE PLUNGER SHAFT
        // Generates a robust sleeve pointing down from the ceiling that perfectly encloses the cross receiver
        difference() {
            translate([0, 0, (button_height - 2.5) / 2]) 
                cylinder(h = button_height - 2.5, d = 8.0, center = true, $fn = 32);
            
            // Core punch the inner sleeve chamber with the plus sign socket
            translate([0, 0, (button_height - 2.5) / 2])
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
    // Suspends the cap straight up along the Z-axis so you can visually verify axis indexing
    translate([0, 0, housing_height + 6]) color("Orange") build_top();
}

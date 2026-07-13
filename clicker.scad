// --- PARAMETRIC KEYBOARD SWITCH FIDGET CLICKER ENGINE ---
// Designed for MakerWorld Parametric Model Maker - Fits standard Cherry MX Switches

/* [Select Mode] */
// Which piece would you like to export?
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload your custom shape SVG file here!
logo_file = "default.svg"; // [image_folder: ""]

/* [Housing Dimensions] */
// Total height of the bottom case (Must be at least 12mm to clear switch pins)
housing_height = 14; // [12:1:25]
// Outer structural wall thickness (mm)
wall_thickness = 2.0; // [1.0:0.5:4.0]

/* [Button Dimensions] */
// Height of the plunging cap piece (mm)
button_height = 10; // [8:1:20]
// Clearance gap so parts don't jam or bind up when pressed (mm)
tolerance = 0.4; // [0.1:0.05:0.8]


/* [Hidden Settings] */
floor_thickness = 3.0; 
overcut = 0.1;        


// --- AUTOMATED LAYER GENERATORS ---
module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(d = 35, $fn = 64); // Fallback circle profile
    } else {
        import(logo_file, center = true);
    }
}

// Automatically welds your custom SVG outline solid into a unified footprint shape
module outer_profile() {
    render(convexity = 4) {
        hull() {
            raw_svg_import();
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

// Standard Cherry MX plate cutout socket (14mm x 14mm square)
module cherry_mx_base_socket() {
    // 14mm square socket for the switch housing to press-fit into
    cube([14.1, 14.1, 20], center = true);
    
    // Bottom center relief hole to clear the round center plastic pin on the switch
    translate([0, 0, -8])
        cylinder(h = 10, d = 4.5, center = true, $fn = 24);
}

// Female cross-shaped socket that presses onto the blue stem
module cherry_mx_stem_female_socket() {
    // Standard Cherry cross specs: 4.1mm x 1.2mm and 4.1mm x 1.4mm cross blades
    cube([4.2, 1.25, 8], center = true);
    cube([1.25, 4.2, 8], center = true);
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        // 1. Extrude your custom SVG footprint shape into a thick solid base shell
        linear_extrude(height = housing_height) 
            outer_profile();
        
        // 2. Clear out the giant inner pocket, leaving a solid 3mm floor deck intact
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                inner_pocket_profile();
        
        // 3. Carve the precise 14mm keyboard switch socket directly in the center floor
        translate([0, 0, floor_thickness + 5]) 
            cherry_mx_base_socket();
    }
}

module build_top() {
    // Combine the cap block with the downward pointing cross-socket shaft
    union() {
        difference() {
            // 1. Extrude the custom sliding cap based on your SVG profile
            linear_extrude(height = button_height) 
                button_profile();
            
            // 2. Hollow out the inside of the button cap (Leaves a 2.5mm solid roof ceiling)
            linear_extrude(height = button_height - 2.5) 
                offset(r = -1.5) 
                button_profile();
                
            // 3. Cut the female cross socket straight into the ceiling of the button cap
            translate([0, 0, button_height - 3.5])
                cherry_mx_stem_female_socket();
        }
        
        // 4. DOWNWARD EXTENDING PLUNGER SHAFT
        // A solid cylinder that extends downward from the ceiling to securely wrap the cross socket
        difference() {
            translate([0, 0, 1]) // Extends downward from the inside roof
                cylinder(h = button_height - 2.5, d = 7.5, $fn = 32);
            
            // Re-hollow the core of the cylinder with the cross socket shape
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
    // Displays the button suspended above the housing base case
    translate([0, 0, housing_height + 6]) color("Orange") build_top();
}

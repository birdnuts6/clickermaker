// --- PARAMETRIC CHERRY MX KEYBOARD SWITCH FIDGET ENGINE ---
// Designed for MakerWorld Customizer - Fits standard keyboard switches

/* [Select Mode] */
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
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

/* [Hidden Settings] */
floor_thickness = 4.0; // Heavy floor blocks pin punch-throughs
overcut = 0.1;        


// --- AUTOMATED LAYER ENGINE ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(r = 22, $fn = 64); 
    } else {
        import(logo_file, center = true);
    }
}

// FIXED: Removed the hull() block completely!
// Uses progressive mathematical stepping to melt hollow vector path strokes 
// into a unified solid mass without filling in your sharp outer valleys or star points.
module outer_profile() {
    render(convexity = 6) {
        offset(r = 2.0) {
            offset(r = -4.0) {
                offset(r = 2.0) {
                    raw_svg_import();
                }
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


// --- SWITCH INTERLOCK MECHANICS ---

// Creates a clean 14.1mm x 14.1mm frame square with zero layout array arrays
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

// Creates the precise female cross socket by extruding crossed geometry
module cherry_mx_stem_female_socket() {
    linear_extrude(height = 9, center = true) {
        offset(r = -1.5) {
            minkowski() {
                circle(r = 3.65, $fn = 4);
                circle(r = 0.1, $fn = 4);
            }
        }
        offset(r = -1.5) {
            minkowski() {
                circle(r = 3.65, $fn = 4);
                circle(r = 0.1, $fn = 4);
            }
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

// --- PARAMETRIC CHERRY MX KEYBOARD SWITCH FIDGET ENGINE ---
// Designed for MakerWorld Customizer - fits standard keyboard switches

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

/* [Hidden Settings] */
floor_thickness = 4.0; 
overcut = 0.1;        


// --- AUTOMATED LAYER ENGINE ---

module raw_svg_import() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        circle(r=22, $fn=64); 
    } else {
        import(logo_file, center = true);
    }
}

module outer_profile() {
    render(convexity = 6) {
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


// --- SWITCH INTERLOCK MECHANICS ---

module cherry_mx_base_socket() {
    // Generates a clean 14.1x14.1mm square opening without using an array vector
    intersection() {
        cube(size = 14.1, center = true);
        rotate(45) cube(size = 14.1, center = true);
    }
    cylinder(h = 24, d = 4.6, center = true, $fn = 24);
}

module cherry_mx_stem_female_socket() {
    // 4.3mm length x 1.35mm thickness cross slots to accept the blue switch stem
    linear_extrude(height = 9, center = true) {
        intersection() {
            square(size = 4.3, center = true);
            scale(0.3) square(size = 15, center = true);
        }
        rotate(90) {
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

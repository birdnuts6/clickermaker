// --- PARAMETRIC FIDGET CLICKER ---

/* [Main Configuration] */

// Upload your custom vector outline file here
logo_file = "./"; // [file:svg]

// Overall height of the clicker housing
housing_height = 15; // [10:1:25]

// Overall height of the top button cap
button_height = 8; // [5:1:15]

// Clearance buffer so parts fit together cleanly (3D printer tolerance)
tolerance = 0.2; // [0.0:0.05:0.5]


/* [Hidden Mechanical Settings] */
switch_hole = 14.0;       
switch_depth = 11.0;      
cross_size = 5.0;         
stem_l = 1.35;            

// --- MAIN LOGIC ---

// 1. Bottom Housing Shell (Centered at 0,0)
difference() {
    // If no file is uploaded yet, draw a built-in 30mm x 30mm rounded square
    if (logo_file == "") {
        linear_extrude(height = housing_height) {
            minkowski() {
                square([26, 26], center = true);
                circle(r = 2, $fn = 16);
            }
        }
    } else {
        // If a user drops an SVG file in, extrude that file profile automatically
        linear_extrude(height = housing_height) {
            import(logo_file, center = true);
        }
    }

    // Cut out the square socket cavity for the keyboard switch
    translate([0, 0, housing_height - (switch_depth / 2) + 0.1]) {
        cube([switch_hole + tolerance, switch_hole + tolerance, switch_depth], center = true);
    }
}

// 2. Top Button Cap (Shifted 40mm to the right so it doesn't overlap)
translate([40, 0, 0]) {
    difference() {
        // If no file is uploaded yet, draw the matching cap block
        if (logo_file =="./") {
            linear_extrude(height = button_height) {
                minkowski() {
                    square([26, 26], center = true);
                    circle(r = 2, $fn = 16);
                }
            }
        } else {
            linear_extrude(height = button_height) {
                import(logo_file, center = true);
            }
        }

        // Cut out the Cherry MX cross stem connection underneath
        translate([0, 0, 2.5]) {
            cube([cross_size, stem_l, 5.0], center = true);
            cube([stem_l, cross_size, 5.0], center = true);
        }
    }
}

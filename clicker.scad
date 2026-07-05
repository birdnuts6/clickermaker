// --- PARAMETRIC FIDGET CLICKER ---

/* [Main Configuration] */

// Which part of the clicker do you want to generate?
part_to_render = "housing"; // ["housing": Bottom Housing Shell, "button": Top Button Cap]

// Upload your custom vector outline file
logo_file = "default.svg"; // [file:svg]

/* [Dimensions] */

// Overall height of the clicker housing
housing_height = 15; 

// Overall height of the top button cap
button_height = 8; 

// Clearance buffer so parts fit together cleanly (3D printer tolerance)
tolerance = 0.2; 

/* [Hidden Settings] */
switch_hole = 14.0;       
switch_depth = 11.0;      
cross_size = 5.0;         
stem_l = 1.35;            

// --- MAIN LOGIC ---
if (part_to_render == "housing") {
    generate_housing();
} else if (part_to_render == "button") {
    generate_button();
}

module generate_housing() {
    difference() {
        linear_extrude(height = housing_height) {
            import(logo_file, center = true);
        }
        translate([0, 0, housing_height - (switch_depth / 2) + 0.1]) {
            cube([switch_hole + tolerance, switch_hole + tolerance, switch_depth], center = true);
        }
    }
}

module generate_button() {
    difference() {
        linear_extrude(height = button_height) {
            import(logo_file, center = true);
        }
        translate([0, 0, 2.5]) {
            cube([cross_size, stem_l, 5.0], center = true);
            cube([stem_l, cross_size, 5.0], center = true);
        }
    }
}

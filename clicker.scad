// --- PARAMETRIC FIDGET CLICKER ---

// Upload your custom vector outline file
logo_file = "default.svg"; 

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

// --- GENERATING BOTH PARTS SIDE BY SIDE ---
// This spits out both models right next to each other automatically

// 1. Bottom Housing Shell (Centered at 0,0)
difference() {
    linear_extrude(height = housing_height) {
        import(logo_file, center = true);
    }
    translate([0, 0, housing_height - (switch_depth / 2) + 0.1]) {
        cube([switch_hole + tolerance, switch_hole + tolerance, switch_depth], center = true);
    }
}

// 2. Top Button Cap (Shifted 40mm to the right so it doesn't overlap)
translate([40, 0, 0]) {
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

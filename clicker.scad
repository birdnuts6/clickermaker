// --- PARAMETRIC SVG FIDGET CLICKER GENERATOR ---

/* [Select Part] */
// Which part of the clicker do you want to generate?
part_to_render = "housing"; // ["housing": Bottom Housing Shell, "button": Top Button Cap]

/* [SVG Customization] */
// Upload your custom vector outline file
logo_file = "default.svg"; // [file:svg]
// Overall height of the clicker housing
housing_height = 15;
// Overall height of the top button cap
button_height = 8;
// Clearance buffer so parts fit together cleanly (3D printer tolerance)
tolerance = 0.2; 

/* [Keychain Feature] */
// Add a keychain loop attachment to the housing?
add_keychain = true; 
// Distance from center to place the loop (adjust if it overlaps your SVG)
keychain_offset = 25; 

/* [Text Engraving Feature] */
// Text to engrave onto the top button cap
button_text = "CLICK"; 
// Depth of the text engraving into the cap
engrave_depth = 1.0; 
// Font size of the text
text_size = 6; 

/* [Hidden Mechanical Switch Dimensions] */
switch_hole = 14.0;       // Standard Cherry MX square width/length
switch_depth = 11.0;      // Depth to embed the switch safely
stem_w = 4.1 + 0.15;      // Standard Cherry MX stem width + tolerance
stem_l = 1.2 + 0.15;      // Standard Cherry MX stem length + tolerance
cross_size = 5.0;         // Outer bounds of cross stem

// --- MAIN LOGIC ---
if (part_to_render == "housing") {
    generate_housing();
} else if (part_to_render == "button") {
    generate_button();
}

// --- MODULES ---

module generate_housing() {
    difference() {
        // Main Base Body (Union joins the SVG body and keychain loop together)
        union() {
            linear_extrude(height = housing_height) {
                import(logo_file, center = true);
            }
            if (add_keychain) {
                translate([0, keychain_offset, 0]) {
                    linear_extrude(height = housing_height) {
                        difference() {
                            circle(d = 8, $fn = 32); // Outer loop ring
                            circle(d = 4, $fn = 32); // Inner hole
                        }
                    }
                }
            }
        }
        
        // Cut out the square socket for the mechanical switch
        translate([0, 0, housing_height - (switch_depth / 2) + 0.1]) {
            cube([switch_hole + tolerance, switch_hole + tolerance, switch_depth], center = true);
        }
        
        // Small hole through the bottom floor for safety/extraction
        translate([0, 0, -0.1])
            cylinder(d = 3.0, h = housing_height, $fn = 24);
    }
}

module generate_button() {
    difference() {
        // Main Button Cap Shape
        linear_extrude(height = button_height) {
            import(logo_file, center = true);
        }
        
        // Cherry MX cross-shaped stem receptor underneath
        translate([0, 0, 2.5]) {
            cube([cross_size, stem_l, 5.0], center = true);
            cube([stem_l, cross_size, 5.0], center = true);
        }
        
        // Custom Text Engraving on Top
        if (button_text != "") {
            translate([0, 0, button_height - engrave_depth]) {
                linear_extrude(height = engrave_depth + 0.1) {
                    text(button_text, size = text_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
                }
            }
        }
    }
}

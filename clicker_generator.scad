/* [Tab 1: Body Ergonomics] */

// The visual style of the outer clicker body
chassis_style = "square"; // [square:Filleted Square, round:Cylindrical Circle]

// Outer width/diameter of the casing (X-axis)
body_width = 15.0; // [12:0.5:25]

// Outer length of the casing (Y-axis)
body_length = 14.0; // [12:0.5:25]

// Total thickness height of the fidget device (Z-axis)
body_height = 10.0; // [8:0.5:20]

// Corner smooth radius (Only applies to Square style)
corner_smoothness = 2.5; // [0:0.5:5]

// Add tactical ridge textures along the outer side grip walls
side_grips = true;


/* [Tab 2: Mechanical Internals] */

// Slicer air gap between moving button and outer wall (Crucial for print-in-place)
print_clearance = 0.35; // [0.15:0.05:0.60]

// Depth of the organic dish scoop on the button face for your thumb
thumb_scoop_depth = 1.0; // [0.0:0.2:2.5]

// Standard micro switch internal pocket size (X/Y dimension)
switch_pocket_size = 6.5; // [5.0:0.1:8.5]


/* [Tab 3: Top Face Artwork] */

// Type of custom detailing to mold onto the button surface
artwork_mode = "text"; // [none:Plain Scoop, text:Custom Text String, logo:SVG File]

// Type out your custom text label
button_label = "SNAP";

// Size scaling for your custom text string
font_scale = 4.5; // [3:0.5:10]

// Extrusion height of the artwork (Positive = pops out, Negative = recessed)
artwork_height = 0.6; // [-2.0:0.1:2.0]


/* [Hidden] */
// Circle fragmentation detail resolution
$fn = 48; 

// --- GEOMETRIC GENERATION ENGINE ---

module base_shape(w, l, h, r) {
    if (chassis_style == "round") {
        cylinder(d = max(w, l), h = h, center = true);
    } else {
        minkowski() {
            cube([w - 2*r, l - 2*r, h - 0.2], center = true);
            cylinder(r = r, h = 0.2, center = true);
        }
    }
}

module clicker_engine() {
    retaining_lip = 1.2;
    
    // 1. HOUSING MAIN FRAME
    difference() {
        // Core housing body
        base_shape(body_width, body_length, body_height, corner_smoothness);
        
        // Subtract side grip texture notches if enabled
        if (side_grips && chassis_style == "square") {
            for (y = [-body_length/2 + 2 : 2 : body_length/2 - 2]) {
                translate([body_width/2, y, 0]) cube([1, 0.8, body_height + 2], center=true);
                translate([-body_width/2, y, 0]) cube([1, 0.8, body_height + 2], center=true);
            }
        }
        
        // Hollow out underside switch tactile pocket
        translate([0, 0, -body_height/2 + (body_height - 3)/2 - 1])
        cube([switch_pocket_size, switch_pocket_size, body_height - 3 + 2], center = true);
        
        // Internal vertical plunger travel shaft path
        inner_w = body_width - (retaining_lip * 2);
        inner_l = body_length - (retaining_lip * 2);
        translate([0, 0, 1])
        base_shape(inner_w, inner_l, body_height, corner_smoothness);
    }
    
    // 2. CAPTIVE INTERNAL MOVING BUTTON PLUNGER
    difference() {
        union() {
            // Lower wider retention plate trapped inside the casing floor
            base_w = body_width - (retaining_lip * 2) - (print_clearance * 2);
            base_l = body_length - (retaining_lip * 2) - (print_clearance * 2);
            translate([0, 0, -body_height/2 + 2])
            base_shape(base_w, base_l, 2, max(0, corner_smoothness - retaining_lip));
            
            // Upper plunging button top core extending through casing ceiling
            translate([0, 0, 1])
            base_shape(base_w - 0.8, base_l - 0.8, body_height - 1, max(0, corner_smoothness - retaining_lip - 0.4));
        }
        
        // Cut out the thumb scoop dish from the top face
        if (thumb_scoop_depth > 0) {
            translate([0, 0, body_height/2 + 15 - thumb_scoop_depth])
            sphere(r = 15);
        }
        
        // Recessed artwork calculation channel (if height value is negative)
        if (artwork_height < 0 && artwork_mode == "text") {
            translate([0, 0, body_height/2 - 0.1 + artwork_height])
            linear_extrude(height = abs(artwork_height) + 0.2)
            text(button_label, size = font_scale, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }
    }
    
    // 3. EMBOSSED OUTWARD ARTWORK (if height value is positive)
    if (artwork_height > 0 && artwork_mode == "text") {
        translate([0, 0, body_height/2 - thumb_scoop_depth * 0.3])
        linear_extrude(height = artwork_height)
        text(button_label, size = font_scale, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
}

clicker_engine();

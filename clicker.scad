// --- PARAMETRIC FIDGET CLICKER ENGINE ---
// Designed for MakerWorld Parametric Model Maker

/* [Select Mode] */
// Which piece would you like to export?
part_to_render = "assembled"; // [housing, button, assembled]

/* [Asset Uploads] */
// Upload your custom emblem graphic! (Will stick out on top of the button)
logo_file = "default.svg"; 

/* [Housing Dimensions] */
// Total thickness of the bottom case to completely shield the square core block (mm)
housing_height = 18; // [12:1:30]
// Outer wall thickness surrounding the mechanism (mm)
wall_thickness = 2.0; // [1.0:0.5:4.0]

/* [Button Dimensions] */
// Height of the plunging clicker cap (mm)
button_height = 10; // [6:1:20]
// Clearance gap so parts don't jam or bind up when pressed (mm)
tolerance = 0.35; // [0.1:0.05:0.8]

/* [Hidden Settings] */
core_file = "default.stl"; 
floor_thickness = 3.0; // Solid heavy bottom deck 
overcut = 0.1;        


// --- CORE GEOMETRIC BODIES ---

// Defines a clean, classic handheld rounded rectangle body shape
module body_shape() {
    minkowski() {
        square([32, 32], center = true);
        circle(r = 4, $fn = 32);
    }
}

// Automatically processes and completely fills your artwork logo shape
module solid_logo_emblem() {
    if (logo_file == "" || logo_file == "./" || logo_file == "default.svg") {
        // Fallback badge design if no graphic is uploaded
        circle(d = 16, $fn = 32);
    } else {
        // The hull() handles hollow lines, converting your art into a solid shape
        hull() {
            import(logo_file, center = true);
        }
    }
}

// Cleans up the negative reference STL core geometry
module mechanical_core() {
    import(core_file, center = true);
}


// --- MANUFACTURING ACTIONS ---

module build_bottom() {
    difference() {
        // 1. Solid Outer Case Body Block
        linear_extrude(height = housing_height) 
            body_shape();
        
        // 2. Clear Internal Cavity (Slices out a pocket for the button to slide into)
        // Leaves a solid 3mm bottom floor intact
        translate([0, 0, floor_thickness]) 
            linear_extrude(height = housing_height - floor_thickness + overcut) 
                offset(r = -wall_thickness) 
                    body_shape();
        
        // 3. Inner Mechanism Carving (Stamps out the negative lock shape in the center floor)
        // Elevated by the floor thickness so it sits perfectly inside the shell
        translate([0, 0, floor_thickness]) 
            mechanical_core();
    }
}

module build_top() {
    // Combine the plunging button cap body with your embossed 3D logo artwork
    union() {
        difference() {
            // 1. Solid Plunging Button Cap
            linear_extrude(height = button_height) 
                offset(r = -(wall_thickness + tolerance)) 
                    body_shape();
            
            // 2. Hollow Out Underside (Leaves a solid 2mm roof on top of the button)
            // This closes off the top of the button entirely!
            linear_extrude(height = button_height - 2.0) 
                offset(r = -(wall_thickness + tolerance + 1.2)) 
                    body_shape();
            
            // 3. Mechanism Slot (Punches through the underside ceiling to fit the shaft)
            // Shifted down slightly to align the top of the mechanical shaft cut
            translate([0, 0, -2.0]) 
                mechanical_core();
        }
        
        // 4. Custom SVG Picture Badge (Sticks up out of the top surface by 1.5mm)
        translate([0, 0, button_height - overcut])
            linear_extrude(height = 1.5)
                solid_logo_emblem();
    }
}


// --- LIVE PAGE RENDERING ---
if (part_to_render == "housing") {
    build_bottom();
} else if (part_to_render == "button") {
    build_top();
} else if (part_to_render == "assembled") {
    // Displays the items stacked vertically on the screen so you can inspect internal clearances
    color("LightSlateGray") build_bottom();
    translate([0, 0, housing_height + 8]) color("Orange") build_top();
}

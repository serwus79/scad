// Width (inner size in mm)
width = 140; // [60:400]

// Depth (inner size in mm)
depth = 110;  // [60:300]

// Height
height = 20; // [10:1:100]

// Rim outer width in mm
rim_outer_width = 16; // [0:1:100]


// corner radius in mm
roundness = 4.5; // [0:0.1:15]
 

/* [Hidden] */
support_height = 30;
th=3.5;
grid_border = 10;
 

module round_cube(coords, r=0) {
        
    if (r<=0) {
        translate([0,0,coords[2]/2])
        cube(coords, center=true);
    } else {
    
        x = coords[0];
        y = coords[1];
        z = coords[2];
        hull() {
            translate([ x/2 - r,  y/2 - r]) cylinder(r=r, h=z);
            translate([-x/2 + r,  y/2 - r]) cylinder(r=r, h=z);
            translate([ x/2 - r, -y/2 + r]) cylinder(r=r, h=z);
            translate([-x/2 + r, -y/2 + r]) cylinder(r=r, h=z);
        }

    }
    
}



module grid_generator(grid_width,grid_depth,grid_parts=0,grid_gap=0.5) {

    
    border = grid_border;
    hex_d = 18;
    
    x_sep = 10.5;
    y_sep = 0;
    
    x_shift = x_sep + hex_d;
    y_shift = y_sep + hex_d;
    
    hlf_width = width/2;
    hlf_depth = depth/2;
    
        difference() {
            round_cube([grid_width-grid_gap*2, grid_depth-grid_gap*2, 2], roundness-1, $fn=40);
            translate([0,0,-1])
            round_cube([grid_width-grid_gap*2-border*2, grid_depth-grid_gap*2-border*2, 4], roundness-1, $fn=40);
        }
        
        
        difference() {
            translate([0,0,1])
            cube([grid_width-grid_gap*2-border*2, grid_depth-grid_gap*2-border*2, 2], center=true);
            
            x_steps = floor((hlf_width - border/2) / x_shift);
            y_steps = floor(hlf_depth / y_shift);
            
            for(x = [-x_steps : x_steps],
                y = [-y_steps : y_steps]) {
            
                translate([x_shift*x,y_shift*y,0])
                cylinder(d=hex_d, h=6, center=true, $fn=6);
            }
            
            alt_x_steps = floor((hlf_width - x_shift/2 - border/2) / x_shift);
            alt_y_steps = floor((hlf_depth - y_shift/2) / y_shift);
            
            for(x = [ -alt_x_steps - 1 : alt_x_steps ],
                y = [ -alt_y_steps - 1 : alt_y_steps ]) {
            
                translate([x_shift*x,y_shift*y,0])
                translate([x_shift/2,y_shift/2,0])
                cylinder(d=hex_d, h=6, center=true, $fn=6);      
            }
        }

}

module rim(width, depth, height, border) {
        difference() {
            round_cube([width,depth, height], roundness-1, $fn=40);
             translate([0,0,-1])
            round_cube([width-border*2, depth-border*2,height+2 ], roundness-1, $fn=40);
        }
}



 grid_generator(width+rim_outer_width/2, depth+rim_outer_width/2);

rim(width, depth, height, 2);
// Width (inner size in mm)
width = 190; // [60:400]

// Depth (inner size in mm)
depth = 100;  // [60:300]

// Height
height = 45; // [35:1:100]


// corner radius in mm
roundness = 4.5; // [0:0.1:15]
 
// drain placement
drain_side = 1; // [0:short side (depth), 1:long side (width)]

// append drain duct
drain_duct = 1; // [0:no, 1:yes]

// append drain hole
drain_hole = 1; // [0:no, 1:yes]

// grid parts
separators = 3; // [0:10]

// grid height
grid_height = 70; // [30:100]

// append grid at back
grid_back = 1; // [0:no, 1:yes]

grid_back_height = 50; // [30:100]


// which parts to render?
part = "both"; // [tray, grid, both]
 

/* [Hidden] */
support_height = 30;
th=3.5;
grid_border = 1.7;
 

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


module shell() {

    difference() {
//   union(){
        
        round_cube([width+th*2, depth+th*2, height], roundness+th, $fn=60);
        
        difference() {
            round_cube([width, depth, height+0.1], roundness, $fn=80);
            
            
              if(drain_hole){
                translate([0,0,7]){
                rotate(atan(9/sqrt(width*width+depth*depth)), [width,-depth,0]){
                  translate([0,0,-height/2]){
                    cube([width*2, depth*2, height], center=true);    
                  }
                }              
              }
              }
              else{
                translate([0,0,7]){
                translate([0,0,-height/2]){
                  cube([width*2, depth*2, height], center=true);    
                }}
            }
        }
        
        
        front_cut_radius = 20; // height/2;
        side_cut_radius = 20; // height/2;
        
        // front cut
        translate([0, depth, height/2+support_height+front_cut_radius/2]){
          rotate([90,0,0]) {
            round_cube([width-26, height+2*side_cut_radius, depth*2], front_cut_radius, $fn=60);
          }
        }

        // side cut
        translate([-width, 0, height/2+support_height+side_cut_radius/2]) {
          rotate([0,90,0]) {
            round_cube([height+2*side_cut_radius, depth-20.4, width*2], side_cut_radius, $fn=80);
          }
        }
    }


    // grid support
    translate([-width/4,depth/2-th,0])
    cube([width*2/4,th,support_height/2-2.2]);

    translate([-width/4,-depth/2,0])
    cube([width*2/4,th,support_height/2-2.2]);

    translate([-width/2,-depth/4,0])
    cube([th, depth/2, support_height/2-2.2]);

    translate([width/2-th,-depth/4,0])
    cube([th, depth/2, support_height/2-2.2]);

}
   

module drip() {
    

    difference() {
    
        cube([17.18,18.5-th,18]);
        
        translate([-1,0,7])
        rotate([30,0,0])
        cube([17.18+2, 20, 18]);
        
        translate([2.5,0,5])
        cube([17.18-5, 20, 18]);
    }
}

module drip_cutter_core() {
    
    gap = 17.18-5;
    
    upscale = 1.25;
    
    translate([0,gap*upscale,0])
    linear_extrude(43, scale=[0.38,0.83])
    scale(upscale)
    translate([0,-gap])
    hull() {
        translate([gap/2-1, 1]) circle(d=2, $fn=30);   
        translate([-gap/2+1, 1]) circle(d=2, $fn=30);
        translate([-gap/2, gap/2-2.95]) square([gap, gap/2]);  
    }    
}

module drip_cutter() {
  
    additional_cut = drain_duct ? 0 : 5; // make the drain hole smaller
    echo(additional_cut);
    
    intersection() {

        translate([(17.18)/2, +3.5, 2.38]) 
        rotate([90,0,0])
        mirror([0,0,1])
        drip_cutter_core();
        
        translate([2.5,0,3])
        cube([17.18-5, 50, 17.18-5-additional_cut]);  
    }

    translate([2.5,4,3.3])
    rotate([90+30,0,0])
    translate([0,0,-1])
    cube([17.18-5, 17.18-5, 17.18-5]);
}
    
module stand() {

    difference() {

        union() {
            
            if(drain_hole && drain_duct) {
                if (drain_side) {
                    translate([-width/2+roundness, -depth/2-18.5, 0])
                    drip(); 
                } else {
                    translate([-width/2-18.5, -depth/2+roundness, 0])
                    mirror([0,1,0])
                    rotate(-90)
                    drip(); 
                }
                
            }

            shell();
        }

        if(drain_hole) {
            if (drain_side) {
                translate([-width/2+roundness, -depth/2-18.5, 0])
                drip_cutter();
            } else {
                translate([-width/2-18.5, -depth/2+roundness, 0])
                mirror([0,1,0])
                rotate(-90)
                drip_cutter();
            }
        }
    }
}

module grid_generator(grid_width,grid_depth,grid_parts=0,grid_gap=0.5) {

    
    border = grid_border;
    hex_d = 14;
    
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


module grid(grid_width,grid_depth,grid_parts=0,grid_gap=0.5){
    separator_distance = grid_width/(grid_parts+1);

    separator_space = grid_width/2-separator_distance;
    union (){
        grid_generator(grid_width, grid_depth);

        for (a =[1:grid_parts]){
            translate([-grid_width/2+separator_distance*a-1,0, floor(grid_height/2)]) rotate([0,90,0]) {
                union(){

                grid_generator(grid_height, grid_depth);
                  
                translate([(floor(grid_height/2) - 2), 0, 1]) cube([4,grid_depth-1,2], center=true);
                }
            }
        } 
        
        if (grid_back) {
          translate([0,floor(grid_depth/2)-0.6,grid_back_height/2-0.5]) {
            rotate([90,0,0]) grid_generator(grid_width-roundness*2, grid_back_height);
          }
        }
    }
}


module stand_w_grid() {
    stand();
    
    %translate([0,0,16])
    grid(width, depth, separators);
}


if( part == "tray" ) {
    stand_w_grid();
}

if (part == "grid") {
    grid(width, depth, separators);

}

if (part == "both") {
    translate([0, depth*2/3, 0]) grid(width, depth, separators);
    translate([0, -depth*2/3, 0]) stand_w_grid();
}
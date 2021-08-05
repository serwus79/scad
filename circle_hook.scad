
// promień części przyklejanej
radius1 = 20;
// wysokość części przyklejanej
height1 = 2;

translate([0, 0, height1/2])
    cylinder(h = height1, r1 = radius1, r2 = radius1, center = true, $fn=60);

translate([0,0, height1])
cylinder(h = 7, r1 = 3, r2 = 3, center = true, $fn=60);
include <honeycomb.scad>

module pipe(r, height, thickness){
  difference() {
    cylinder(h = height, r = r, $fn = 120);
    cylinder(h = height, r = r - thickness, $fn = 120);
  }
}

module lid(r, thickness){
  rInner = r*0.8;
  rOuter = r*1.2;
  honeycombR=3;
  honeycombSize = ceil(rInner*2.5/honeycombR);
  intersection() {
    cylinder(h = thickness, r = rInner, $fn=120);
    linear_extrude(height = thickness*2) 
      honeycomb(r=honeycombR, thickness=0.5, cols=honeycombSize, rows=honeycombSize, center=true);
  }
  pipe(rOuter, thickness, rOuter - rInner);

}

outerWidth = 60;

lid(outerWidth/2, 3);

translate([0,0,3]) {
  pipe(r = outerWidth/2, height = 18, thickness = 2.5);
}

/*
Honeycomb generator module
*/
/*
module honeycomb generate honeycomb based on number of rows and columns
  r float radius of hexagons
  thickness float thickness of hexagon walls
  cols int how many hexagons per row
  rows int number of rows
  center bool center generated shape
  
  example:
    color("Yellow") honeycomb(r=4, thickness=2, cols=5, rows=4, center=true);
*/
module honeycomb(r, thickness=1, cols=0, rows=0, center=false) {
  translate([ // if center is true, calculate total size and translate accordingly
    center ? ( cols * r / tan(30) + (r + thickness) / tan(30) / 2 ) /-2 : 0,
    center ? ( rows * r * sin(30) + (rows+0.5) * r + thickness ) /-2 : 0
  ])
  translate([ (r+thickness/2) / 2 / tan(30), r+thickness/2])  // Move so it starts at 0, 0
  for (j = [ 0 : 1 : rows-1 ] ) {  // Iterate rows
    translate([ r / 2 / tan(30) * (j%2) , j * (r + r * sin(30)) ])
    for (i = [ 0 : 1 : cols-1 ]) { // Iterate columns
      translate([ i * ( r / tan(30) ) , 0]) rotate([0, 0, 90]) {

        // Make the hexagons
        if (thickness==0) {
          circle(r, $fn=6);
        }
        else {
          difference() {
            circle(r+thickness/2, $fn=6);
            circle(r-thickness/2, $fn=6);
          }
        }
      }
    }
  }
  
  /* // Draw a square around the total area
  %square([
    cols * r / tan(30) + (r + thickness) / tan(30) / 2,
    rows * r * sin(30) + (rows+0.5) * r + thickness
  ]);
  */
}

/*
module honeycomb_square generate honeycomb based on x and y size
  dimensions vector [x, y] size of square
  r float radius of hexagons
  thickness float thickness of hexagon walls
  center bool center generated shape
  
  example:
    color("Yellow") honeycomb_square([100, 20], 2, 1, true);
*/
module honeycomb_square(dimensions = [10, 10], r=1, thickness=1, center=false) {
  
  intersection() {
    translate([r * -1, thickness * -1])
    honeycomb(r=r, thickness=thickness,
      cols = (dimensions[0] - (r + thickness) / tan(30) / 2) / (r / tan(30)) + 2,
      rows = dimensions[1] / (r*2 - thickness) + 1,
      center=center);
   
    square(dimensions, center=center); 
  }
}

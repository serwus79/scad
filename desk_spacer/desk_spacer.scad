
module slat(
  side="right", // "left"|"right"
  length = 15,  // length of slat, increased by thickness
  height = 54,  // heigt of slat without thickness,
  thickness = 4,// thicness on upper and lower ends
  width = 20    // width of slat
  ) {
  sideMultipler = side == "left" ? 1 : -1;

  PolyPoints=[
  [sideMultipler *  0, 0, 0],                              // 0
  [sideMultipler *  thickness, 0, 0],                      // 1
  [sideMultipler *  thickness, width, 0],                  // 2
  [sideMultipler *  0, width, 0],                          // 3
  [sideMultipler * (length), 0, (height - thickness)],     // 4
  [sideMultipler * (length), width, (height - thickness)], // 5
  [sideMultipler * (length), 0, (height)],                 // 6
  [sideMultipler * (length), width, (height)],             // 7
  [sideMultipler * (length - thickness), 0, (height)],     // 8
  [sideMultipler * (length - thickness), width, (height)], // 9
  [sideMultipler *  0, 0, thickness],                      //10
  [sideMultipler *  0, width, thickness],                  //11
  ];
  
  PolyFaces=[
  [ 0, 1, 2, 3], // A
  [ 1, 4, 5, 2], // B
  [ 4, 6, 7, 5], // C
  [ 6, 8, 9, 7], // D
  [ 8,10,11, 9], // E
  [10, 0, 3,11], // F
  [ 3, 2, 5, 7, 9,11], // G
  [ 0,10, 8, 6, 4, 1], // H
  ];

  union() {
    translate([-1 * sideMultipler * 4,0,0])
      polyhedron( PolyPoints, PolyFaces );
    slatSupport(side, length, height, thickness, width, thicness);
  }
}

module slatSupport(
  slatSide="right", // "left"|"right"
  slatLength = 15,  // length of slat, increased by thickness
  slatHeight = 54,  // heigt of slat without thickness,
  slatThickness = 4,// thicness on upper and lower ends
  slatWidth = 20    // width of slat
) {
  length = 3 * slatLength;
  width = 4;
  sideMultipler = slatSide == "left" ? 1 : -1;

  slatLengthWithoutThickness = slatLength - slatThickness;
  slatHeightWithoutThickness = slatHeight - slatThickness;


  PolyPoints = [
    [ 0, 0, 0], // 0
    [ sideMultipler * length, 0, 0], // 1
    [ sideMultipler * length, width, 0] ,// 2
    [ 0, width, 0], // 3
    [ sideMultipler * (length + slatLengthWithoutThickness), 0, slatHeightWithoutThickness], // 4
    [ sideMultipler * (length + slatLengthWithoutThickness), width, slatHeightWithoutThickness], // 5
  ];

  PolyFaces = [
    [0,1,2,3], // A
    [1,4,5,2], // B
    [4,0,3,5], // C
    [3,2,5],   // D
    [0,4,1],   // E
  ];

  translateX = slatSide == "left" ?  -(length + slatThickness) : length + slatThickness;
  
  translate([translateX, slatWidth/2-width/2, slatThickness])
    polyhedron( PolyPoints, PolyFaces );
}


module wrenchLike(){

  Protrusion = 0.01;        // [0.01, 0.1]

  WrenchSize = 20.0;                   // headset race across-the-flats size
  NumFlats = 32;

  JawWidth = 10.0;

  JawOD = 1.5*JawWidth + WrenchSize;
  echo(str("Jaw OD: ",JawOD));

  StemOD = 18.0;

  WrenchThick = 4.0;

  //- Build things

  difference() {
    linear_extrude(height=WrenchThick,convexity=4) {
      hull() {                      // taper wrench body to handle
        circle(d=JawOD);
        translate([0.3*JawOD,0,0])
          circle(d=HandleWidth);
      }
    }
    translate([0,0,-Protrusion])
      rotate(1*180/NumFlats) {         // cosine converts across-flats to circle dia
        cylinder(d=WrenchSize/cos(180/NumFlats),h=(WrenchThick + 2*Protrusion),$fn=NumFlats);
    }
    translate([-StemOD,0,WrenchThick/2])
      cube([2*StemOD,StemOD,(WrenchThick + 2*Protrusion)],center=true);
    translate([-0.75*StemOD,0,WrenchThick/2])
      cube([0.7*StemOD,2*StemOD,(WrenchThick + 2*Protrusion)],center=true);

  }
}

union() {
  cube(size=[215,20,4], center=false); 
  translate([-16.5, 0, 50])
    cube(size=[6.5,20, 4], center=false);
  slat();
  translate([215, 0, 0])
    slat("left", 10, 14);
    translate([235, 10, 10])
      rotate(180)
        wrenchLike();

}


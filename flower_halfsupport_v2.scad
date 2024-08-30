// promien okregu
circleRadius = 50;
// poczatek i koniec okregu w stopniach
circleAngles = [45, 280];
// szerokosc okregu
circleWidth = 5;
// wysokosc okregu
circleHeight = 5;

// wysokosc nogi
legHeight = 100;
// odstep pierwszej i ostatniej nogi od brzegu w stopniach
legGap = 10;
// liczba nog
legCount = 6;


fn = 100;


module sector(radius, angles, fn = 24) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

module arc(radius, angles, width = 1, fn = 24) {
    difference() {
        sector(radius + width, angles, fn);
        sector(radius, angles, fn);
    }
} 

module leg(radius, height, fn=24) {
    cylinder(r=radius, h=height, $fn=100); 
}

function generateLegAngles(circleAngles, legGap, legCount) = 
    let(
        startAngle = circleAngles[0] + legGap,
        endAngle = circleAngles[1] - legGap,
        step = (endAngle - startAngle) / (legCount - 1)
    )
    [ for(i = [0 : legCount - 1])
        startAngle + i * step
    ];
    



translate([0, 0, legHeight])
    linear_extrude(circleHeight) 
        arc(circleRadius, circleAngles, circleWidth, fn);


legRadius = circleWidth/2-circleWidth*0.1;
legPosRadius = circleRadius+(circleWidth/2);
legAngles = generateLegAngles(circleAngles, legGap, legCount);

for (angle = legAngles) { // Umieszczanie nóg w równych odstępach
        rotate([0, 0, angle])
            translate([legPosRadius, 0, 0]) // Pozycjonowanie nóg na obwodzie koła
                leg(legRadius, legHeight, fn);
    }

// Resolution for milling:
$fa            = 1;    // Minimum angle
$fs            = 0.1;  // Minimum size
delta          = 0.001;

rotor_diameter = 75.0;
core_diameter  = 15.0;
hole_diameter  =  4.2;
gap            =  2.0;
fastener_edge  =  3.5;
holder_thick   =  8.0;
holder_medium  =  5.0;
holder_thin    =  3.0;
rounding       =  3.5;
frame          =  2.5;
extra          = 10.0;

fastener_width = hole_diameter + 2 * fastener_edge;
d1             = (rotor_diameter-hole_diameter)/2 - 
                  fastener_edge;


module pie90(d) {
    difference() {
        circle(d=d, true);
        
        union() {
            translate([0, -d/2-delta])
                square([d/2+2*delta,
                        d/2+2*delta], 
                       center = false);
            translate([-d/2-delta, -d/2-delta])
                square([d/2+2*delta, d+2*delta], 
                       center = false);
        }
    }
}

module hole3d() {
        cylinder(d=hole_diameter,
                 h=25,
                 center=true);
}

module holes3d() {
    union() {
        hole3d();
        translate([ d1,  d1]) hole3d();
        translate([ d1, -d1]) hole3d();
        translate([-d1,  d1]) hole3d();
        translate([-d1, -d1]) hole3d();      
    }
}

module holes3d2() {
    d  = 1.5;
    dx = (rotor_diameter - 2 * d) / 2;
    dy = (rotor_diameter + 2 * extra - 2 * d) / 2;
    union() {
        holes3d();
        translate([ dx,  dy]) hole3d();
        translate([ dx, -dy]) hole3d();
        translate([-dx,  dy]) hole3d();
        translate([-dx, -dy]) hole3d();      
    }
}

module hole2d() {
        circle(d=hole_diameter);
}

module holes2d() {
    union() {
        hole2d();
        translate([ d1,  d1]) hole2d();
        translate([ d1, -d1]) hole2d();
        translate([-d1,  d1]) hole2d();
        translate([-d1, -d1]) hole2d();      
    }
}

module rotor() {
    difference() {
        union() {
            pie90(rotor_diameter);
            rotate([0, 0, 180])
                pie90(rotor_diameter);
            circle(d=core_diameter, true);
        };
        holes2d();
    }
}

module fastener_block() {
    translate([rounding, rounding])
        minkowski() {
            square([fastener_width - 2 * rounding,
                    rotor_diameter - 2 * rounding]);
            circle(r=rounding);
        };
}

module holder_thin() {
    size = rotor_diameter;
    thin = holder_thick - holder_thin;
    difference() {
    translate([rounding - size/2, 
               rounding - size/2,
               holder_thick - thin + delta])
        minkowski() {
            cube([size - 2 * rounding,
                  size - 2 * rounding,
                  thin/2]);
            cylinder(r=rounding,
                     h=thin/2,
                     center = false);
        }; // end minkowski //
        cylinder(d=core_diameter,
                 h=holder_medium,
                 center=false);
    }; // end difference //
}

module holder_wo_holes() {
    size = rotor_diameter + 2 * frame;
    translate([rounding - size/2, 
               rounding - size/2 - extra, 0])
        minkowski() {
            cube([size - 2 * rounding,
                  size - 2 * rounding + 2 * extra,
                  holder_thick/2]);
            cylinder(r=rounding,
                     h=holder_thick/2,
                     center = false);
        } // end minkowski //
};

module holder() {
    difference() {
        holder_wo_holes();
        union() {
            holes3d2();
            holder_thin();
        }
    }; // end difference //
}

module stator_wo_holes() {
    union() {
        translate([rotor_diameter/2 - fastener_width,
                   -rotor_diameter/2])
            fastener_block();
        difference() {
            union() {
                translate([0, -rotor_diameter/2])
                    square([rotor_diameter/2 - gap/2,
                            rotor_diameter]);
            };
            union() {
                translate([-gap/2, 0])
                    circle(d=core_diameter+gap, true);
                rotate([0, 0, 45])
                    square([rotor_diameter,
                            rotor_diameter/2+delta]);
                rotate([0, 0, -45])
                    translate([0, -rotor_diameter/2])
                        square([rotor_diameter,
                                rotor_diameter/2+delta]);
            }
        }; // end difference //
    }; // end union //
}

module stator() {
    difference() {
        stator_wo_holes();
        holes2d();
    };
};

module preview_rotor() {
    color("red", 1)
        rotor();
}

module preview_stator() {
    translate([gap/2, 0, 2])
        color("blue", 1)
            stator();
    
    translate([gap/2, 0, 2])
        rotate([0, 0, 180])
            color("blue", 1)
                stator();
    
}

module preview_hole() {
    translate([0, 0, -5])
        cylinder(d=hole_diameter,
             h=50,
             center=false);
}

module preview() {
    
    for (i = [1 : 8]) {
        z = i * 4;
    
        translate([0, 0, z]) {
            preview_rotor();
            preview_stator();
        }        
        
        translate([0, 0, z + 4]) {
            preview_rotor();
            preview_stator();
        }        
    } // end for //
    
    preview_stator();
    
    translate([0, 0, 10 * 4])
        color("green", 1)
            holder();
    
    rotate([180, 0, 0])
        color("green", 1)
            holder();

        color("red")
            translate([0, 0, -24])
                cylinder(d=hole_diameter,
                     h=70,
                     center=false);

        color("blue") {
            translate([ d1,  d1]) preview_hole();
            translate([ d1, -d1]) preview_hole();
            translate([-d1,  d1]) preview_hole();
            translate([-d1, -d1]) preview_hole();      
        }
}

preview();

// You need 2 printed holder per VC
// holder();

// You need n cutted rotor
// rotor();

// You need 2 * n + 2 cutted stator per VC
//stator();

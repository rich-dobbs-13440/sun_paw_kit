include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>
use <ScadApotheka/m2_helper.scad>


a_lot = 500;
eps = 0.01;


orient_for_build = false;
show_male_mock = true;
show_female_mock = true;

show_male_holder = true;
show_face_plate = true;
show_ratchet_strap = true;
show_ratchet_strap_slot = true;
engage_ratchet_strap = true;
//show_recess = true;
//show_front_bracket = true;

alpha_holder = 0.25; // [0.25,1]
alpha_recess = 0.25; // [0.25,1]


/* [Dimensions for xt90] */
x_male_plug_xt90 = 20.71;
y_male_plug_xt90 = 20.87;
z_male_plug_xt90 = 10;

y_female_plug_xt90 = 13.3;

/* [Dimensions for xt90 holder] */
x_holder = 45;
z_holder = 21.5;
x_screws_holder = 33.5;


/* [Part Design] */
face_plate_overlap = 5; // [1:20]
ratchet_extent = [14, 15, 2];
root_count = 3;

module end_of_customization() {}


if (show_female_mock) {
    female_xt90();
}
if (show_male_mock) {
    male_xt90();
}

if (show_male_holder) {
    male_holder();
}


if (show_face_plate) {
    face_plate();
}


module female_xt90() {
    translate([0, -y_female_plug_xt90, 0])
    import("XT90_FEMALE.amf", convexity=10);
}


module male_xt90() {
    color(alpha=0.25) 
    translate([0, -y_male_plug_xt90, 0]) 
    import("XT90_MALE.amf", convexity=10);
}

if (show_ratchet_strap) {
    ratchet_strap(
        ratchet_extent, 
        root_count = root_count,
        tooth_count = 10,
        tooth_height = 0.5,
        center_dovetail = true,
        orient_for_build=orient_for_build, engage_strap=engage_ratchet_strap);
}

if (show_ratchet_strap_slot) {
    ratchet_strap( show_slot=true, orient_for_build=orient_for_build); 
}

module ratchet_strap(
        extent = [10, 25, 2],
        root_count=5, 
        tooth_count = 10,
        tooth_height = 1,
        wall = 1,
        show_slot=false, 
        rooted_strap = false,
        center_dovetail = false,
        orient_for_build=false, 
        show_engage_strap=false) {
            
    root = [extent.x - 2*extent.z - 2*wall, extent.y/root_count, extent.z];    
    tooth = [root.x,  extent.y/tooth_count, tooth_height];   
    
    module tooth() {
        hull() {
            block([tooth.x, tooth.y, 0.1], center=ABOVE+RIGHT);
            block([tooth.x, 0.1, tooth.z], center = ABOVE+RIGHT);
        }
    }
    
    module root() {
        block([root.x, root.y, root.z], center=BELOW+RIGHT);
        hull() {
            translate([0, 0, -extent.z]) block([extent.x-2*wall, 0.1, 0.1], center = ABOVE+RIGHT);
            translate([0, root.y, -root.z]) block([root.x, 0.1, 0.1], center = ABOVE+RIGHT);
            block([root.x, 0.1, 0.1], center = BELOW+RIGHT);
        }
    }
    
    module socket() {
        // The insertion path
        hull() {
            root();
            translate([0, 0, 2*root.z]) root();
        }
        // The engage path
        hull() {
            root();
            translate([0, root.y/2, 0]) root();
        }
    }
   
    
    module strap(rooted_strap=true) {
        for (i=[0:tooth_count-1]) {
            translate([0, i*tooth.y, 0]) {
                tooth(center_dovetail=center_dovetail);
            }
        }
        if (rooted_strap) {
            for (i=[0:root_count-1]) {
                translate([0, i*root.y, 0]) {
                    root();
                }
            }            
        } else {
            block([root.x, extent.y, extent.z], center=BELOW+RIGHT);
        }
    }
    
    module slot() {
        for (i=[0:root_count-1]) {
            translate([0, i*root.y, 0]) {
                socket();
            }
        }
    }
    
    if (show_slot) {   
        translation = orient_for_build ? [0, 0, 0] : [0, 0, 0];
        rotation = orient_for_build ? [90, 0, 0] : [0, 0, 0];
        translate(translation)
        rotate(rotation) 
        color("red") {
             render(convexity=10) difference() {
                block([extent.x, root_count * root.y, 2*root.z], center=BELOW+RIGHT);
                slot();
             }
         }
    } else {
        dy = engage_ratchet_strap ? tooth.y/2 : 0;
        translation = orient_for_build ? [0, 0, tooth.z] : [0, dy, 0];
        translate(translation)  
            color("green") strap(engage_strap=); 
    }
    
    
}


module male_holder() {
    module segment() {
        render(convexity=10) difference() {
            translate([-x_holder/2, -4, -z_holder/2])  {
                rotate([0, -90, 180])
                    import("XT90_holder.STL", convexity=10);
            }
            translate([0, -6, 0]) plane_clearance(RIGHT);
        }
    }
    module slots() {
        center_reflect([1, 0, 0]) 
            translate([-x_male_plug_xt90/2-5, 0, 0]) 
                rotate([0, 90, 180]) 
                    ratchet_strap(
                        ratchet_extent,
                        root_count = root_count,
                        show_slot = true, 
                        orient_for_build = false); 
    }
    color(PART_1, alpha=alpha_holder) {
        segment();
        translate([0, 7, 0]) segment();
        
    }
    slots();

}


module face_plate() {
    d_face_plate = z_holder + 2 * face_plate_overlap;
    color(PART_3) {
        render(convexity=10) difference() {
            hull() {
                center_reflect([1, 0, 0]) {
                    translate([x_male_plug_xt90/2, 0, 0]) {
                        rod(d=d_face_plate, l=2, center=SIDEWISE+RIGHT); 
                    }
                }
            }
            scale([1.05, 1, 1.05]) translate([0, -5, 0]) hull() female_xt90();
        }
    }
}
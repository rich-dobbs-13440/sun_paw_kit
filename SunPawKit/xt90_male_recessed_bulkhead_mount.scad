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
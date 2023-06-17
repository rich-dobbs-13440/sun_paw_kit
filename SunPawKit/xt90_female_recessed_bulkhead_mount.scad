include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>
use <ScadApotheka/m2_helper.scad>


a_lot = 500;
eps = 0.01;

show_mocks = true;
show_holder = true;
show_recess = true;
show_face_plate = true;
show_back_plate = true;

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

d_recess = 37;
d_face_plate = 55;

module end_of_customization() {}

if (show_mocks) {
    female_xt90();
    male_xt90();
}


if (show_holder) {
    female_holder(); 
}

if (show_recess) {
    recess();
}

if (show_face_plate) {
    face_plate();
}

if (show_back_plate) {
    back_plate();
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


module female_holder() {
    color(PART_1, alpha=alpha_holder)
    translate([-x_holder/2, 0, z_holder/2])  
    rotate([0, 90, 0])
    import("XT90_holder.STL", convexity=10);
}


module recess() {
    id = sqrt(x_male_plug_xt90^2  + z_male_plug_xt90^2);
    color(PART_2, alpha=alpha_recess) {
        render(convexity=10) difference() {
            scale([1.0, 1, 0.9]) {
                rod(d=x_holder, hollow=id, l=y_female_plug_xt90, center=SIDEWISE+LEFT); 
            }
            rod(d=d_recess, taper=x_male_plug_xt90, l=y_female_plug_xt90 + 1, center=SIDEWISE+LEFT); 
            center_reflect([1, 0, 0]) 
                translate([x_screws_holder/2, -6, 0]) 
                    rotate([90, 0, 0]) 
                        hole_through("M3", $fn=12);
            translate([x_holder/2, 0, 0]) plane_clearance(FRONT);
            translate([-x_holder/2, 0, 0]) plane_clearance(BEHIND);
        }
    }
}


module face_plate() {
    color(PART_3) 
    translate([0, -y_female_plug_xt90, 0]) 
    rod(d=d_face_plate, hollow=d_recess, l=2, center=SIDEWISE+LEFT); 
}

module back_plate () {
    h_backer = 10;
    color(PART_4) 
     translate([0, -y_female_plug_xt90+1]) 
    render(convexity=10) difference() {
       rod(d=d_face_plate, hollow=d_recess, l=h_backer, center=SIDEWISE+RIGHT); 
        translate([0, 10, 0]) scale([1.05, 10, 1.05]) hull() recess(); 
        center_reflect([0, 0, 1]) translate([0, h_backer/2, 0]) hole_through("M2", $fn=12, cld=0.4);
    }
    
}
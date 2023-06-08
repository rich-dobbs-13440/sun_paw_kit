include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>
use <ScadApotheka/m2_helper.scad>
use <MCAD/boxes.scad>

a_lot = 500;

show_mocks = true;
show_mounting_face_plate = true;
show_recess = true;
show_front_bracket = true;

/* [Dimensions for ps_300g ] */

d_outside_curve_ps_300g = 44; // [40: 48]
z_ps_300g = 47.7;
y_ps_300g = 110;
y_center_ps_300g = 44.8;
y_foot_screws_cl = 88.8;
d_foot_ps_300g = 6.6;
x_extrusion_ps_300g = 160;

/* [Dimensions for mounting ] */
h_recess = 2; // [2:Test, 10:Production]
h_front_bracket = 2; // [2:Test, 10:Production]
r_face_round = 5; // [2:Test",10:Production]

module end_of_customization() {}



if (show_mocks) {
    translate([-h_recess, 0, 0]) giandel_ps_300b();
}

if (show_mounting_face_plate) {
    mounting_face_plate();
}

if (show_recess) {
   recess();
}

if (show_front_bracket) {
    translate([-h_recess, 0, 0]) front_bracket(); 
}



module giandel_ps_300b(as_clearance= false, clearance=1)  {
    echo("Giandel 300w Pure Sine Wave Inverter");
    x_face_plate = 0.6;
    
    
    module profile (as_clearance, x_specified, clearance = 0) {
        x = as_clearance ? a_lot : x_specified;
        dx = as_clearance ? 0 : -x_specified/2;
        dy_outside_curve = y_ps_300g/2 - d_outside_curve_ps_300g/2;
        d_body = d_outside_curve_ps_300g + 2 * clearance;
        z = z_ps_300g + 2 * clearance;
        
        d_foot = d_foot_ps_300g + 2 * clearance;
        dz_foot = -z_ps_300g/2 + d_foot/2 - clearance;
        dy_foot = y_foot_screws_cl/2;
        translate([dx, 0, 0]) {
            hull() {
                // Central block
                block([x, y_center_ps_300g, z]);
                center_reflect([0, 1, 0]) 
                    translate([0, dy_outside_curve, 0]) 
                        rod(d=d_body, l=x);
              
            }
            // Rounded foot
            translate([0, 0, dz_foot]) {
                hull() {
                    center_reflect([0, 1, 0]) 
                        translate([0, dy_foot, 0]) 
                                rod(d=d_foot, l=x);
                }
            }
        }          
    }
    module face_plate() {
        color("black") {
                profile (as_clearance=false, x_specified=x_face_plate, clearance = 0);      
        }
    }
    
    module extrusion() { 
        color(ALUMINUM) {
            translate([-x_face_plate, 0, 0]) {
                profile (as_clearance=false, x_specified=x_extrusion_ps_300g, clearance = 0); 
            }
        }
    }
    module back_plate() {
        dx = -(x_face_plate  + x_extrusion_ps_300g);
        color("black") {
            translate([dx, 0, 0]) {            
                profile (as_clearance=false, x_specified=x_face_plate, clearance = 0);   
            }   
        }        
    }
    if (as_clearance) {
        profile(as_clearance=true, clearance=clearance);
    } else {
        face_plate();
        extrusion();
        back_plate(); 
    }

}


function dy_pill() = y_ps_300g/2 - z_ps_300g/2;

function d_pill(overlap) = z_ps_300g + 2 * overlap;


module pill(overlap, h) {
    hull()
        center_reflect([0, 1, 0]) 
            translate([0, dy_pill(), 0]) 
                rod(d=d_pill(overlap), l=h);
    
}

module mounting_face_plate() {
    h_pill_minkowski = 1;
    d_minkowski = 5;    
    overlap_id_minkowski = -5 + d_minkowski;
    overlap_od_minkowski = 5;
    id_minkowski = d_pill(overlap_id_minkowski) - d_minkowski;
    echo("id_minkowski", id_minkowski);
    od_minkowski = d_pill(overlap_od_minkowski) + d_minkowski;
    echo("od_minkowski", od_minkowski);
    minkowski() {
        difference() {
            pill(overlap = overlap_od_minkowski, h = h_pill_minkowski);
            pill(overlap = overlap_id_minkowski, h = a_lot); 
        }
        difference() {
            sphere(d=d_minkowski, $fn=12);
            plane_clearance(BEHIND);
        }
    }
}


module mounting_profile(h, as_clearance = false, clearance=0) {
    overlap = as_clearance ? 2 * clearance : 4;
    h_to_use = as_clearance ? a_lot : h;
    dx = as_clearance ? 0 : -h / 2; 
    dy = y_foot_screws_cl/2 - 1;
    module foot_screws_pedistals() {
        d_pedistal = 10;
        center_reflect([0, 1, 0]) 
            translate([0,  dy, -z_ps_300g/2 + d_foot/2]) 
                    rod(d=d_pedistal, l=h_to_use); 
    }
    module profile() {
        hull() {
            pill(overlap = overlap, h=h_to_use);
            foot_screws_pedistals();
        }        
    } 
    translate([dx, 0, 0]) profile();
}

module recess() {
    color("red", alpha = 0.25) {
        difference() {
            mounting_profile(h_recess);
            pill(overlap = -2, h = a_lot); 
        }  
    }
}
//
//
module front_bracket() {
    translate([-h_recess, 0, 0]) {
        render(convexity=10) difference() {
            hull() giandel_ps_300b(as_clearance= true, clearance=5);
            plane_clearance(FRONT); 
            translate([-h_front_bracket, 0, 0]) plane_clearance(BEHIND); 
            giandel_ps_300b(as_clearance= true, clearance=1);
        }
    }
}


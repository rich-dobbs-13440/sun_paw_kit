include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>


orient_for_build = true;
show_rooted_ratchet_strap = true;
show_unrooted_ratchet_strap = true;
show_slot = true;
show_strap_as_engaged = true;

root_count = 3;
tooth_count = 6;
tooth_height = 0.0; // [0.0, 0.25. 0.5, 0.75, 1]
dovetail_looseness = 1.15;
center_dovetail = true;

x_extent = 14;
y_extent = 15;
z_extent = 2;

ratchet_extent = [x_extent, y_extent, z_extent];

module end_of_customization() {}


if (show_rooted_ratchet_strap) {
    translate([x_extent, 0, 0]) ratchet_strap(
        ratchet_extent, 
        root_count = root_count,
        tooth_count = tooth_count,
        tooth_height = tooth_height,
        rooted_strap = true,
        center_dovetail = center_dovetail,
        orient_for_build = orient_for_build, 
        show_strap_as_engaged = show_strap_as_engaged);
}


if (show_unrooted_ratchet_strap) {
    ratchet_strap(
        ratchet_extent, 
        root_count = root_count,
        tooth_count = tooth_count,
        tooth_height = tooth_height,
        rooted_strap = false,
        center_dovetail = center_dovetail,
        orient_for_build = orient_for_build, 
        show_strap_as_engaged = show_strap_as_engaged);
}

if (show_slot) {
    ratchet_strap(
        ratchet_extent, 
        root_count = root_count,
        tooth_count = tooth_count,
        tooth_height = tooth_height,
        center_dovetail = center_dovetail,    
        show_slot = true, 
        orient_for_build = orient_for_build); 
}

module ratchet_strap(
        extent = [10, 25, 2],
        root_count=5, 
        tooth_count = 10,
        tooth_height = 1,
        wall = 1,
        show_slot = false, 
        rooted_strap = false,
        center_dovetail = false,
        orient_for_build = false, 
        show_strap_as_engaged = false) {
            
    root = [extent.x - 2*extent.z - 2*wall, extent.y/root_count, extent.z];    
    tooth = [root.x,  extent.y/tooth_count, tooth_height];   
    
    module tooth() {
        hull() {
            block([tooth.x, tooth.y, 0.1], center=ABOVE+RIGHT);
            block([tooth.x, 0.1, tooth.z], center = ABOVE+RIGHT);
        }
    }
    
    module center_dovetail(male = false) {
        x_neck = 2;
        scaling = male ? [1, 1, 1] : [dovetail_looseness, dovetail_looseness, dovetail_looseness];
        rotation = male ? [0, 180, 0] : [0, 0, 0];
         scale(scaling) {
            rotate(rotation) {
                hull() {
                    translate([0, 0, extent.z/2])  block([x_neck, extent.y, 0.01], center = ABOVE+RIGHT);
                    translate([0, 0, -extent.z/2]) block([x_neck + extent.z, extent.y, 0.01], center = ABOVE+RIGHT);
                }
            }
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
                tooth();
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
        dy = show_strap_as_engaged ? tooth.y/2 : 0;
        translation = orient_for_build ? [0, 0, tooth.z] : [0, dy, 0];
        translate(translation)  {
            color("green")  {
                    if (center_dovetail && !rooted_strap) {
                        render(convexity = 10) difference() {
                            strap(rooted_strap=rooted_strap); 
                            center_dovetail(male = false);
                        }
                    } else if (center_dovetail) {
                        strap(rooted_strap=rooted_strap); 
                        translate([0, 0, root.z/2]) center_dovetail(male = true);
                    } else {
                        strap(rooted_strap=rooted_strap); 
                    }
                }
            }
    }
}



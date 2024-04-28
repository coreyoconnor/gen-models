
/* The goal is to replicate a rotating cable "tie".
 * I have one for reference but I lost where I got the orignal from *shrug*
 * units in mm.
 */

height = 20;
gap = 0.3; // printing with a 0.6 mm nozzle. The original seems to be < 0.1
inner_radius= 13;
inner_contact_radius = 4;
half_height = height / 2;
inset_at_half_height = cos(45) * half_height;
outer_radius = inner_radius + inner_contact_radius + inset_at_half_height + gap + 4;
detent_radius = 2.5;

module inner_ring() {
    inner_section_points =
        [
         [inner_radius, 0],
         [inner_radius + inner_contact_radius, 0],
         [inner_radius + inner_contact_radius + inset_at_half_height, half_height],
         [inner_radius + inner_contact_radius, height],
         [inner_radius, height],
        ];

    module full_inner_ring() {
        rotate_extrude($fn = 80) {
            polygon(inner_section_points);
        }
    }

    module inner_grip_slots() {
        sx = 1;
        sy = 8;
        for( r = [0 : 60 : 360] ) {
            rotate(r, [0, 0, 1]) {
                translate([inner_radius - sx, -sy/2, 0]) {
                    cube([sx, sy, height]);
                }
            }
        }
    }

    difference() {
        union() {
            full_inner_ring();
            inner_grip_slots();

            r = cos(45)*(inner_radius + inner_contact_radius)-0.8;
            translate([-r, r, 0]) cylinder(h = height, r = detent_radius, $fn = 30);
            translate([r, -r, 0]) cylinder(h = height, r = detent_radius, $fn = 30);
        }
        // sw (-x, -y) chunk if viewed from above
        s = inner_radius + inner_contact_radius + inset_at_half_height;

        // huh.. I guess I could have rotated the profile 270 instead
        translate([-s - 2, -s - 2, -1]) {
            cube(size = [s + 2, s + 2, height + 2]);
        }
    }
}

module outer_ring() {
    outer_section_points  =
        [
         [ inner_radius + inner_contact_radius + gap, 0],
         [ outer_radius, 0 ],
         [ outer_radius, height ],
         [ inner_radius + inner_contact_radius + gap, height],
         [ inner_radius + inner_contact_radius + inset_at_half_height + gap, half_height],
         ];
    module full_outer_ring() {
        rotate_extrude($fn = 80) {
            polygon(outer_section_points);
        }
    }

    module outer_grip_slots() {
        sx = 1;
        sy = 10;
        for( r = [0 : 30 : 360] ) {
            rotate(r, [0, 0, 1]) {
                translate([outer_radius, 0, -1 ]) {
                    scale([1, 10, 1]) cylinder(h = height + 2, r = sx, $fn = 20);
                }
            }
        }
    }

    difference() {
        full_outer_ring();
        s = outer_radius;
        translate([-1, -1, -1]) cube(size = [s + 2, s + 2, height + 2]);

        // that is equivalent to the original model. Now for extras
        outer_grip_slots();

        r = cos(45)*(inner_radius + inner_contact_radius)-0.7;
        translate([-r, r, -1]) cylinder(h = height+2, r = detent_radius, $fn = 30);
        translate([r, -r, -1]) cylinder(h = height+2, r = detent_radius, $fn = 30);
    }
}

inner_ring();
outer_ring();

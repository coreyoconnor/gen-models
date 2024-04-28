/* The goal is to replicate a rotating cable "tie".
 * I have one for reference but I lost where I got the orignal from *shrug*
 * units in mm.
 */

height = 40;
gap = 0.25; // printing with a 0.6 mm nozzle.
inner_radius= 13;
inner_contact_radius = 3;
multiplicity = 6; // number of teeth
angle = 60;
inner_height = height / (2 * multiplicity);
inset_at_inner_height = inner_height / tan(angle);
inner_extent = inner_radius + inner_contact_radius + inset_at_inner_height;
outer_thickness = 2.5;
outer_radius = inner_radius + inner_contact_radius + inset_at_inner_height + gap + outer_thickness;
detent_radius = 2.1;
inner_grip_slots_sx = 6;
inner_grip_slots_sy = 1.5;
outer_grip_slots_sx = 1;
outer_grip_slots_sy = 10;

module inner_ring() {

    function inner_x(i) =
        let (t = (i % 2) == 0 ? 0 : inset_at_inner_height)
        inner_radius + inner_contact_radius + t;

    function inner_y(i) = i * inner_height;

    inner_section_points =
        [ [ inner_radius, 0 ],
          each [ for (i = [0 : 2 *multiplicity]) [inner_x(i), inner_y(i)] ],
          [ inner_radius, height ] ];

    module full_inner_ring() {
        rotate_extrude($fn = 100) {
            polygon(inner_section_points);
        }
    }

    module inner_grip_slots() {
        sx = inner_grip_slots_sx;
        sy = inner_grip_slots_sy;
        for( r = [15, 75, 135, 315] ) {
            rotate(r, [0, 0, 1]) {
                translate([inner_radius, 0, 0]) {
                    scale([1, sy, 1]) cylinder(d = sx, h = height, $fn = 50);
                }
            }
        }
    }

    module wavy_slot() {
        slice_points =
            [ [ 0, -0.1],
              [ inner_extent + 1, -0.1],
              [ inner_extent + 1, 0.51],
              [ 0, 0.51]
              ];

        for(h = [0 : 0.5 : height - 0.5]) {
            a = -30*cos((h/height)*185) - 5;
            rotate(a, [0, 0, 1]) translate([0, 0, h]) {
                rotate_extrude(angle = 80, $fn = 100) {
                    polygon(slice_points);
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
        // translate([-s - 1, -s - 1, -1]) cube(size = [s + 2, s + 2, height + 2]);
        rotate(190, [0, 0, 1]) wavy_slot();
    }
}

module outer_ring() {

    function outer_x(i) =
        let (t = (i % 2) == 0 ? 0 : inset_at_inner_height)
        inner_radius + inner_contact_radius + gap + t;

    function outer_y(i) = i * inner_height;

    outer_section_points =
        [ each [ for (i = [0 : 2 * multiplicity]) [outer_x(i), outer_y(i)] ],
          [ outer_radius, height ],
          [ outer_radius, 0 ]
          ];

    module full_outer_ring() {
        rotate_extrude($fn = 100) {
            polygon(outer_section_points);
        }
    }

    module outer_grip_slots() {
        sx = outer_grip_slots_sx;
        sy = outer_grip_slots_sy;
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
#outer_ring();

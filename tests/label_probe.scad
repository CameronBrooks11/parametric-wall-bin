// Imports a rendered bin (BIN) and shows where it isn't inside a thin slab
// through the engraved label on the back flange: what's left is the label.
BIN = "bin.stl";
box_length = 200;
box_width = 70;
wall_thickness = 3;
text_extrude = 2;
box_height = 100;
mounting_flange = 25;

intersection()
{
    // Within the engraving's depth, from 5 mm below the rim to 115.5 mm:
    // below the screw holes and the flange's rounded top corners.
    translate([ wall_thickness, box_width - wall_thickness + 0.2, box_height - 5 ])
        cube([ box_length - 2 * wall_thickness, text_extrude - 0.4, 20.5 ]);
    difference()
    {
        translate([ -1, -1, -1 ]) cube([ box_length + 2, box_width + 2, 202 ]);
        import(BIN);
    }
}

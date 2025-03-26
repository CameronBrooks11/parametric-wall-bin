// higher resolution
$fa = 1;
$fs = 0.4;

// variables
corner_radius = 3;
box_length = 200;
box_width = 70;
box_height = 100;
wall_thickness = 3;
screw_diameter = 4;
mounting_flange = 25;

text_string = "Safety Glasses";
text_font = "Arial:style=Bold";
text_extrude = 2;

center_screw = true;

zFite = $preview ? 0.1 : 0;

// rounded corners
translate([ corner_radius, corner_radius, 0 ])

    // bottom left corner
    difference()
{
    cylinder(h = box_height, r = corner_radius);
    translate([ -corner_radius, 0, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, -corner_radius, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, 0, -1 ]) cylinder(h = box_height + 2, r = corner_radius - wall_thickness);
}
// bottom right corner
translate([ box_length - corner_radius, corner_radius, 0 ]) rotate([ 0, 0, 90 ]) difference()
{
    cylinder(h = box_height, r = corner_radius);
    translate([ -corner_radius, 0, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, -corner_radius, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, 0, -1 ]) cylinder(h = box_height + 2, r = corner_radius - wall_thickness);
}
// top right corner
translate([ box_length - corner_radius, box_width - corner_radius, 0 ]) rotate([ 0, 0, 180 ]) difference()
{
    cylinder(h = box_height, r = corner_radius);
    translate([ -corner_radius, 0, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, -corner_radius, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, 0, -1 ]) cylinder(h = box_height + 2, r = corner_radius - wall_thickness);
}
// top left corner
translate([ corner_radius, box_width - corner_radius, 0 ]) rotate([ 0, 0, 270 ]) difference()
{
    cylinder(h = box_height, r = corner_radius);
    translate([ -corner_radius, 0, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, -corner_radius, -1 ]) cube([ corner_radius * 2, corner_radius * 2, box_height + 2 ]);
    translate([ 0, 0, -1 ]) cylinder(h = box_height + 2, r = corner_radius - wall_thickness);
}
// walls
// lower wall
difference()
{
    translate([ -0.0001 + corner_radius, 0, 0 ])
        cube([ box_length - 2 * corner_radius + 0.0002, wall_thickness, box_height ]);
}
// upper wall
difference()
{

    // Lengths in X, Y, Z dimension
    dx = box_length - 2 * corner_radius + 0.0002;
    dy = wall_thickness;
    dz = box_height + mounting_flange;

    // Corner radius on XY plane (from origin clockwise around positive Z axis)
    rxy = [ 0, 0, 0, 0 ];
    // Corner radius on YZ plane (from origin clockwise around positive X axis)
    ryz = [ 0, 0, 0, 0 ];
    // Corner radius on XZ plane (from origin clockwise around positive Y axis)
    rxz = [ 0, 0, screw_diameter, screw_diameter ];
    translate([ -0.0001 + corner_radius, box_width - wall_thickness, 0 ]) intersection()
    {
        // XY plane
        linear_extrude(dz) hull()
        {
            for (ix = [0:1], iy = [0:1])
            {
                i = [ 0, 1, 3, 2 ][ix * 2 + iy];
                r = rxy[i] == 0 ? 0.0001 : rxy[i];
                x = ix == 0 ? r : dx - r;
                y = iy == 0 ? r : dy - r;
                translate([ x, y, 0 ]) circle(r, $fn = 40);
            }
        }

        // YZ plane
        translate([ 0, 0, dz ]) rotate([ 0, 90, 0 ]) linear_extrude(dx) hull()
        {
            for (iy = [0:1], iz = [0:1])
            {
                i = [ 1, 0, 2, 3 ][iy * 2 + iz];
                r = ryz[i] == 0 ? 0.0001 : ryz[i];
                y = iy == 0 ? r : dy - r;
                z = iz == 0 ? r : dz - r;
                intersection()
                {
                    translate([ z, y, 0 ]) circle(r, $fn = 40);

                    square([ dz, dy ]);
                }
            }
        }

        // XZ plane
        translate([ 0, dy, 0 ]) rotate([ 90, 0, 0 ]) linear_extrude(dy) hull()
        {
            for (ix = [0:1], iz = [0:1])
            {
                i = [ 0, 3, 1, 2 ][ix * 2 + iz];
                r = rxz[i] == 0 ? 0.0001 : rxz[i];
                x = ix == 0 ? r : dx - r;
                z = iz == 0 ? r : dz - r;
                intersection()
                {
                    translate([ x, z, 0 ]) circle(r, $fn = 40);

                    square([ dx, dz ]);
                }
            }
        }
    }

    // left screwhole
    translate([
        corner_radius + screw_diameter / 2 + 5, -1 / 2 * wall_thickness + box_width,
        box_height + mounting_flange - 1 / 2 * screw_diameter - 5
    ]) rotate([ 90, 0, 0 ]) cylinder(h = wall_thickness + 2, d = screw_diameter + 0.5, center = true);
    // right screwhole
    translate([
        box_length - corner_radius - screw_diameter / 2 - 5, -1 / 2 * wall_thickness + box_width,
        box_height + mounting_flange - 1 / 2 * screw_diameter - 5
    ]) rotate([ 90, 0, 0 ]) cylinder(h = wall_thickness + 2, d = screw_diameter + 0.5, center = true);

    // center screwhole
    if (center_screw)
    {
        translate([
            box_length / 2, -1 / 2 * wall_thickness + box_width,
            box_height + mounting_flange - 1 / 2 * screw_diameter - 5
        ]) rotate([ 90, 0, 0 ]) cylinder(h = wall_thickness + 2, d = screw_diameter + 0.5, center = true);
    }

    //  text
    text_size = mounting_flange / 2;
    translate([ box_length / 2, box_width - wall_thickness + text_extrude, box_height + text_size / 2 ])
        rotate([ 90, 0, 0 ]) color("red") linear_extrude(height = text_extrude + zFite)
            text(text_string, size = text_size, font = text_font, halign = "center", valign = "center", $fn = 40);
}

// left wall
translate([ 0, corner_radius, 0 ]) cube([ wall_thickness, box_width - corner_radius * 2, box_height ]);

// right wall
translate([ box_length - wall_thickness, corner_radius, 0 ])
    cube([ wall_thickness, box_width - corner_radius * 2, box_height ]);

// floor plate

// Lengths in X, Y, Z dimension
dx = box_length;
dy = box_width;
dz = wall_thickness;

// Corner radius on XY plane (from origin clockwise around positive Z axis)
rxy = [ corner_radius, corner_radius, corner_radius, corner_radius ];
// Corner radius on YZ plane (from origin clockwise around positive X axis)
ryz = [ 0, 0, 0, 0 ];
// Corner radius on XZ plane (from origin clockwise around positive Y axis)
rxz = [ 0, 0, 0, 0 ];

intersection()
{
    // XY plane
    linear_extrude(dz) hull()
    {
        for (ix = [0:1], iy = [0:1])
        {
            i = [ 0, 1, 3, 2 ][ix * 2 + iy];
            r = rxy[i] == 0 ? 0.0001 : rxy[i];
            x = ix == 0 ? r : dx - r;
            y = iy == 0 ? r : dy - r;
            translate([ x, y, 0 ]) circle(r, $fn = 40);
        }
    }

    // YZ plane
    translate([ 0, 0, dz ]) rotate([ 0, 90, 0 ]) linear_extrude(dx) hull()
    {
        for (iy = [0:1], iz = [0:1])
        {
            i = [ 1, 0, 2, 3 ][iy * 2 + iz];
            r = ryz[i] == 0 ? 0.0001 : ryz[i];
            y = iy == 0 ? r : dy - r;
            z = iz == 0 ? r : dz - r;
            intersection()
            {
                translate([ z, y, 0 ]) circle(r, $fn = 40);

                square([ dz, dy ]);
            }
        }
    }

    // XZ plane
    translate([ 0, dy, 0 ]) rotate([ 90, 0, 0 ]) linear_extrude(dy) hull()
    {
        for (ix = [0:1], iz = [0:1])
        {
            i = [ 0, 3, 1, 2 ][ix * 2 + iz];
            r = rxz[i] == 0 ? 0.0001 : rxz[i];
            x = ix == 0 ? r : dx - r;
            z = iz == 0 ? r : dz - r;
            intersection()
            {
                translate([ x, z, 0 ]) circle(r, $fn = 40);

                square([ dx, dz ]);
            }
        }
    }
}
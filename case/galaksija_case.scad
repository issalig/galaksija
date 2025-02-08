/*
 Decription: Galaksija case
 Author: issalig
 Date: 06/02/25
 */

use("galaksija_keys.scad");

// measures taken from the pcb
$pcb_width = 310.24;
$pcb_height = 217.22;
$pcb_holes_dist = 77.928; // holes near space bar
$pcb_holes_x_off = 119.5; // offset from pcb origin
$pcb_holes_y_off = 9.65;
$pcb_hole_diam = 3;
$pcb_thickness = 1.6;

$case_width = $pcb_width + 20;
$case_height = $pcb_height + 10;
$case_base_deep = 5;
$case_top_deep = 12.5 + 1.5; // front part
$case_pcb_off_x = ($case_width - $pcb_width) / 2;
$case_pcb_off_y = $case_height - $pcb_height; // pcb until bottom
$case_height2 = $case_height / 3;
$case_top_deep2 = $case_top_deep + 8 + 6; // back part
$case_top_angle = 0;                      // 20;
$keyboard_frame_radius = 1;               // keep safe distance

$font_name = "GreenMountain3"; // https://www.whatfontis.com/FF_Green-Mountain-3.font

$base_vents_enabled = true;

// screw positions
$screws_width = $case_width - 12;
$screws_height = $case_height - 10;
$screws_metric = 3;

$thickness = 1;
$fillet_radius = 2; // 1.5
$fn_case = 30;
$fn = 50; //$fn_case;

$colortop = "gold";  //[0.15, 0.15, 0.15];
$colortop2 = "gold"; //[0.15, 0.15, 0.15];
$colorbase = "gold"; // [0.15, 0.15, 0.15];
$special_color = "#deb887";
$normal_color = [ 0.15, 0.15, 0.15 ];
$font_name = "GreenMountain3";

$top_nerves = 1;
$base_nerves = 1;

// position of the nerves and screw holes to make the sandwich
$base_nerve_x = 0.6; // relative nerve positions
$base_nerve_x2 = 0.35;
$base_nerve_y = 0.5;

$front_central_hole_x = 0.55; // use it with non symmetrical partitions to join base left with top right
$side_central_hole = 0.6;     // use it to join upper and lower parts

$top_nerve_x = 0.55; // for the keyboard part
$top_nerve_x2 = 0.5; // for the back part

$top_nerve_y = 2 / 3;

// logo
$logo_enabled = 1;          // show logo
$logo_text_enabled = false; // show font logo or galakisja original logo

// origin is pcb left bottom

// pcb from kicad export
module pcb()
{
	translate([ -532.5, -182.7, 0 ])
	import("galaksija_pcb.stl");

	// cube([$pcb_width, $pcb_height, $pcb_thickness]);
	translate([ $pcb_holes_x_off, $pcb_holes_y_off, -50 ])
	% cylinder(h = 100, d = $pcb_hole_diam);
	translate([ $pcb_holes_x_off + $pcb_holes_dist, $pcb_holes_y_off, -50 ])
	% cylinder(h = 100, d = $pcb_hole_diam);

	// led
	translate([ 247.5, 23, -50 ])
	% cylinder(h = 100, d = $pcb_hole_diam);

	// conn holes
	// 23.5, 204.92
	// 108.33, 204.92
	translate([ 23.5, 204.92, -50 ])
	% cylinder(h = 100, d = $pcb_hole_diam);
	translate([ 108.33, 204.92, -50 ])
	% cylinder(h = 100, d = $pcb_hole_diam);
}

// simple pcb mockup
module pcb_rectangle()
{
	cl = 0.3; // clearance
	translate([ -cl, -cl, 0 ]);
	cube([ $pcb_width + cl * 2, $pcb_height + cl * 2, $pcb_thickness + cl / 2 ]);
}

// for slanted back top
module chamfer_profile(width = 20, h = $case_height2 - $case_height, angle = 10)
{
	// h = r * cos(a);
	r = h / cos(angle);
	echo("h", h);
	y = r * sin(angle);
	x = r * cos(angle);

	rotate([ 0, 90, 0 ])
	linear_extrude(height = width)
#polygon(points = [ [ 0, 0 ], [ -x, 0 ], /*[-x/4, y/2],*/[ 0, y ] ]);
}

// holes for back connections
module back_connections()
{
	// data
	conn_deep = 14.5;
	translate([ -65.81 + $pcb_width / 2, $case_height / 2, $case_top_deep - conn_deep / 2 ])
	cube([ 90, 10, conn_deep ], center = true);
	// dc switch

	translate([ -$case_width / 2 + 22, $case_height / 2, $case_top_deep - 8 ])
	cube([ 14.6, 35, 9 ], center = true);

	// push nmi button
	translate([ -162 + $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep - conn_deep / 2 - 1.5 ])
	rotate([ 90, 0, 0 ])
	cylinder(h = 20, d = 6.8, $fn = $fn_case);

	// push rst button
	translate([ -147 + $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep - conn_deep / 2 - 1.5 ])
	rotate([ 90, 0, 0 ])
	cylinder(h = 20, d = 6.8, $fn = $fn_case);

	// push brk button
	translate([ -132 + $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep - conn_deep / 2 - 1.5 ])
	rotate([ 90, 0, 0 ])
	cylinder(h = 20, d = 6.8, $fn = $fn_case);

	// video offset 87.25 - width 10.60
	// translate([-$case_width/2+$fillet_radius+87.2,$case_height/2,$case_top_deep-conn_deep/2])
	translate([ 87.25 - $pcb_width / 2, $case_height / 2, $case_top_deep - conn_deep / 2 ])
	cube([ 11, 10, conn_deep + 5 ], center = true);

	// dc offset 31.4 - width 9.2
	// translate([-$case_width/2+$fillet_radius+31.4,$case_height/2,//$case_top_deep-conn_deep/2])
	translate([ 31.4 - $pcb_width / 2, $case_height / 2, $case_top_deep - conn_deep / 2 ])
	cube([ 9.7, 10, conn_deep + 5 ], center = true);

	// audio offset 57.83 - width 11
	translate([ 57.83 - $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep - conn_deep / 2 - 1.5 ])
	rotate([ 90, 0, 0 ])
	cylinder(h = 20, d = 6.8, $fn = $fn_case);

	// led
	translate([ $pcb_width / 2, -$pcb_height / 2 + $case_pcb_off_y / 2, 0 ])
	translate([ -247.5, 23, -$case_top_deep / 2 - $fillet_radius * 0 ])
	cylinder(h = 100, d = $pcb_hole_diam);
}

// text legends for back connections
module back_legends()
{

	// data legend
	translate([ 220 - $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep - 14.5 - 0.5 - 1 ])
	rotate([ 270, 0, 0 ])
	// color([1,1,1])
	linear_extrude(0.5) text("Expansion", size = 3, font = $font_name, halign = "center", $fn = 50);

	// break legend
	translate([ -132 + $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep / 2 - 7 - 1.5 ])
	rotate([ 270, 0, 0 ])
	// color([1,1,1])
	linear_extrude(0.5) text("Brk", size = 3, font = $font_name, halign = "center", $fn = 50);

	// reset legend
	translate([ -147 + $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep / 2 - 7 - 1.5 ])
	rotate([ 270, 0, 0 ])
	// color([1,1,1])
	linear_extrude(0.5) text("Rst", size = 3, font = $font_name, halign = "center", $fn = 50);

	// nmi legend
	translate([ -162 + $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep / 2 - 7 - 1.5 ])
	rotate([ 270, 0, 0 ])
	// color([1,1,1])
	linear_extrude(0.5) text("NMI", size = 3, font = $font_name, halign = "center", $fn = 50);

	// audio legend
	translate([ 57.83 - $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep / 2 - 7 - 1.5 ])
	rotate([ 270, 0, 0 ])
	linear_extrude(0.5) text("Tape", size = 3, font = $font_name, halign = "center", $fn = 50);

	// video legend
	translate([ 87.25 - $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep / 2 - 8 ])
	rotate([ 270, 0, 0 ])
	linear_extrude(0.5) text("Video", size = 3, font = $font_name, halign = "center", $fn = 50);

	// dc legend
	translate([ 31.4 - $pcb_width / 2, $case_height / 2 + $fillet_radius, $case_top_deep / 2 - 8 ])
	rotate([ 270, 0, 0 ])
	linear_extrude(0.5) text("5V", size = 3, font = $font_name, halign = "center", $fn = 50);

	// switch legend
	translate([ -$case_width / 2 + $fillet_radius + 20, $case_height / 2 + $fillet_radius, $case_top_deep / 2 - 8 ])
	rotate([ 270, 0, 0 ])
	linear_extrude(0.5) text("I/O", size = 3, font = $font_name, halign = "center", $fn = 50);
}

// logo using font from keyboard
module logo()
{
	if ($logo_text_enabled)
	{
		translate([ $case_width / 2 - 37, $case_height / 2 - 30, -$case_top_deep2 / 2 + 0.5 ])
		rotate([ 0, 180, 0 ])
		linear_extrude(0.5) text("GALAKSIJA", size = 4.5, font = $font_name, halign = "center", $fn = 50);

		translate([ $case_width / 2 - 37, $case_height / 2 - 30 - 6, -$case_top_deep2 / 2 + 0.5 ])
		rotate([ 0, 180, 0 ])
		linear_extrude(0.5) text("MIKRO RAČUNAR", size = 2.8, font = $font_name, halign = "center", $fn = 50);
	}
}

module top_front()
{
	angle = 0; // TODO fix it to work with angles

	// logo
	if ($logo_enabled)
	{
		color($normal_color) translate(
		    [ -$case_width / 2 + 65 + 200, $case_height / 2 - 30, -$case_top_deep2 / 2 - $fillet_radius + 2 - 3 ])
		rotate([ 0, 180, 0 ])
		// scale([1,1,2])
		// ImageToStl.com
		import("galaksija_logo.stl");
		// import("galaksija_logo_plate.stl");
		/*
		scale([1, 1, 0.1])
	  surface(file = "smiley.png", center = true, invert = true);

		*/
	}

	// main body
	difference()
	{
		minkowski()
		{
			translate([ 0, 0, $case_top_deep / 2 ])
			// cube([$case_width, $case_height, $case_top_deep], center = true );

			// slanted middle

			difference()
			{
				cube([ $case_width, $case_height, $case_top_deep ], center = true);
				translate([ -$case_width / 2, -$case_height / 2, -$case_top_deep / 2 ])
				chamfer_profile(width = $case_width, h = $case_top_deep, angle = angle);
			}

			sphere(r = $fillet_radius, $fn = $fn_case);
		}
		// remove inner part
		translate([ 0, 0, ($case_top_deep + $fillet_radius) / 2 ])
		// cube([$case_width, $case_height, $case_top_deep+$fillet_radius], center = true );
		difference()
		{
			angle = 0;
			cube([ $case_width, $case_height, $case_top_deep ], center = true);
			translate([ -$case_width / 2, -$case_height / 2, -$case_top_deep / 2 ])
			chamfer_profile(width = $case_width, h = $case_top_deep, angle = angle);
		}

		// remove bottom fillet
		translate([ 0, 0, ($case_top_deep + $fillet_radius / 2) ])
		cube([ $case_width + $fillet_radius * 2, $case_height + $fillet_radius * 2, $fillet_radius ], center = true);

		// vents
		nholes = -1;
		dholes = 3;
		whole = 1;
		hhole = 7;
		dj = $case_height - 30;
		for (i = [0:1:nholes])
		{
			for (j = [0:1:1])
			{
				translate(
				    [ -$case_width / 2, -nholes * dholes / 2 + i * dholes - dj / 2 + j * dj, -$case_top_deep + 2 ])
				cube([ hhole, whole, $case_top_deep * 2 ], center = true);

				translate([ $case_width / 2, -nholes * dholes / 2 + i * dholes - dj / 2 + j * dj, -$case_top_deep + 2 ])
				cube([ hhole, whole, $case_top_deep * 2 ], center = true);
			}
		}

		// subtract holes for connections
		back_connections();
	}
	// add legends
	back_legends();
}

module top_back()
{
	angle = $case_top_angle;

	// main body
	difference()
	{
		minkowski()
		{
			translate([ 0, 0, $case_top_deep2 / 2 ])
			// slanted middle
			difference()
			{
				cube([ $case_width, $case_height2, $case_top_deep2 ], center = true);
				translate([ -$case_width / 2, -$case_height2 / 2, -$case_top_deep2 / 2 ])
				chamfer_profile(width = $case_width, h = $case_top_deep2 - $case_top_deep, angle = angle);
			}

			//}

			sphere(r = $fillet_radius, $fn = $fn_case);
		}
		// remove inner part
		/*
		translate([0,0,($case_top_deep2+$fillet_radius)/2])
		cube([$case_width, $case_height2, $case_top_deep2+$fillet_radius], center = true );*/

		// slanted middle

		difference()
		{
			translate([ 0, 0, ($case_top_deep2 + $fillet_radius) / 2 ])
			cube([ $case_width, $case_height2, $case_top_deep2 + $fillet_radius ], center = true);

			translate([ -$case_width / 2, -$case_height2 / 2, -$case_top_deep2 / 2 + 10 ])
			chamfer_profile(width = $case_width, h = $case_top_deep2 - $case_top_deep, angle = angle);
			/*
			%translate([0,-$case_height2*0.8,0])
			rotate([-angle,0,0])
			translate([0,$case_height2*0,$case_top_deep2/2])
			                        translate([0,0,$case_top_deep/4])

			cube([$case_width, $case_height2, $case_top_deep2], center = true );
			*/
		}
		//}

		// remove base fillet ???
		translate([ 0, 0, ($case_top_deep2 + $fillet_radius / 2) ])
		cube([ $case_width + $fillet_radius * 2, $case_height2 + $fillet_radius * 2, $fillet_radius ], center = true);

		// vents
		nholes = 20;
		dholes = 3;
		whole = 1;
		hhole = 7;
		dj = $case_width - 90;
		for (i = [0:1:nholes])
		{
			for (j = [0:1:1])
			{
				translate([
					-nholes * dholes / 2 + i * dholes - dj / 2 + j * dj, $case_height / 2 * 0 + $case_height2 / 2,
					-$case_top_deep2 + 2
				])
				cube([ whole, hhole, $case_top_deep2 * 2 ], center = true);
			}
		}
	}
}

module base_mounting_holes()
{
	mh_off_y = 0;
	mh_off_x = 0;

	difference()
	{
		// mounting holes in the for corners
		for (mh_w = [0:1:1])
		{
			// front
			translate([ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y, 0 ])
			cylinder(h = $case_base_deep, d2 = $screws_metric + 9, d1 = $screws_metric + 9, $fn = $fn_case);

			// back
			translate([ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y + $screws_height, 0 ])
			cylinder(h = $case_base_deep, d2 = $screws_metric + 9, d1 = $screws_metric + 9, $fn = $fn_case);

			////middle
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * $side_central_hole, 0
			])
			cylinder(h = $case_base_deep, d2 = $screws_metric + 9, d1 = $screws_metric + 9, $fn = $fn_case);

			// middle holes 2
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * (1 - $case_height2 / $case_height + 0.1), 0
			])
			//#cylinder(h=$case_top_deep2, d1=$screws_metric+3, d2=$screws_metric+6.5, $fn=$fn_case);
			cylinder(h = $case_base_deep, d2 = $screws_metric + 9, d1 = $screws_metric + 9, $fn = $fn_case);
		}

		// hollow mounting holes for the screw just to pass
		for (mh_w = [0:1:1])
		{
			// front
			translate([ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y, -3 ])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 0.3, $fn = $fn_case);
			// back
			translate(
			    [ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y + $screws_height, -3 ])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 0.3, $fn = $fn_case);

			// middle
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * $side_central_hole, -3
			])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 0.3, $fn = $fn_case);

			// middle2
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * (1 - $case_height2 / $case_height + 0.1), -3
			])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 0.3, $fn = $fn_case);
		}
	}

	// front central hole
	difference()
	{
		union()
		{
			translate([ -$screws_width / 2 + $front_central_hole_x * $case_width, -$screws_height / 2 + mh_off_y, 0 ])
			cylinder(h = $case_base_deep, d2 = $screws_metric + 9, d1 = $screws_metric + 9, $fn = $fn_case);
		}
		translate([ -$screws_width / 2 + $front_central_hole_x * $case_width, -$screws_height / 2 + mh_off_y, -3 ])
		cylinder(h = $case_base_deep + 4, d = $screws_metric + 0.3, $fn = $fn_case);
	}

	// front central hole 2
	difference()
	{
		union()
		{
			translate(
			    [ -$screws_width / 2 + $front_central_hole_x * $case_width - 12, -$screws_height / 2 + mh_off_y, 0 ])
			cylinder(h = $case_base_deep, d2 = $screws_metric + 9, d1 = $screws_metric + 9, $fn = $fn_case);
		}
		translate([ -$screws_width / 2 + $front_central_hole_x * $case_width - 12, -$screws_height / 2 + mh_off_y, -3 ])
		cylinder(h = $case_base_deep + 4, d = $screws_metric + 0.3, $fn = $fn_case);
	}

	if ($base_nerves)
	{

		$nerve_width = 3;

		// nerves for partition
		// y-axis nerve
		translate([ -$nerve_width / 2 + ($base_nerve_x - 0.5) * $case_width, -$case_height / 2, 0 ])
		cube([ $nerve_width, $case_height * $base_nerve_y, 2 ]);
		// y-axis nerve2
		translate(
		    [ -$nerve_width / 2 + ($base_nerve_x2 - 0.5) * $case_width, -$case_height * ($base_nerve_y - 0.5), 0 ])
		cube([ $nerve_width, $base_nerve_y * $case_height, 2 ]);

		// x-axis nerve
		translate([ -$case_width / 2, -$nerve_width / 2 + ($base_nerve_y - 0.5) * $case_height, 0 ])
		cube([ $case_width, $nerve_width, 2 ]);

	} // endif base_nerves

	logo();
}

module case_top_mounting_holes()
{
	mh_off_y = 0;
	mh_off_x = 0;

	difference()
	{
		// mounting holes
		for (mh_w = [0:1:1])
		{
			// front holes
			translate([ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y, 0 ])
			cylinder(h = $case_top_deep, d1 = $screws_metric + 3, d2 = $screws_metric + 6.5, $fn = $fn_case);
			translate([ -0.5 - $screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y - 6, 3 ])
			cube([ 1, 3, $case_top_deep - 2 ]);

			// back holes
			translate([ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y + $screws_height, 0 ])
			cylinder(h = $case_top_deep2, d1 = $screws_metric + 3, d2 = $screws_metric + 6.5, $fn = $fn_case);
			translate([
				-0.5 - $screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y + $screws_height + 2, 3
			])
			cube([ 1, 3, $case_top_deep2 - 2 ]);

			// middle holes 2
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * (1 - $case_height2 / $case_height + 0.1), 0
			])
			cylinder(h = $case_top_deep2, d1 = $screws_metric + 3, d2 = $screws_metric + 6.5, $fn = $fn_case);
			translate([
				-3 - $screws_width / 2 + mh_w * ($screws_width + 9),
				-$screws_height / 2 + mh_off_y - 0.5 + $screws_height * (1 - $case_height2 / $case_height + 0.1), 3
			])
			rotate([ 0, 0, 90 ])
			cube([ 1, 3, $case_top_deep2 - 2 ]);

			// middle holes
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * $side_central_hole, 0
			])
			cylinder(h = $case_top_deep, d1 = $screws_metric + 3, d2 = $screws_metric + 6.5, $fn = $fn_case);
			translate([
				-3 - $screws_width / 2 + mh_w * ($screws_width + 9),
				-$screws_height / 2 + mh_off_y - 0.5 + $screws_height * $side_central_hole, 3
			])
			rotate([ 0, 0, 90 ])
			cube([ 1, 3, $case_top_deep - 2 ]);
		}

		// hollow mounting holes
		for (mh_w = [0:1:1])
		{
			// front
			translate([ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y, -3 ])
			cylinder(h = $case_base_deep + 4, d = $screws_metric - 0.3, $fn = $fn_case);

			// back
			translate(
			    [ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y + $screws_height, -3 ])
			cylinder(h = $case_base_deep + 4, d = $screws_metric - 0.3, $fn = $fn_case);

			// middle 2
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * (1 - $case_height2 / $case_height + 0.1), -3
			])
			cylinder(h = $case_base_deep + 4, d = $screws_metric - 0.3, $fn = $fn_case);

			// middle
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * $side_central_hole, -3
			])
			cylinder(h = $case_base_deep + 4, d = $screws_metric - 0.3, $fn = $fn_case);
		}
	}

	// middle back support
	/*
	difference(){
	 translate([-$case_width*0.05,$case_height/2-$case_height2,0])
	    //#cylinder(h=$case_top_deep2, d=$screws_metric+3, $fn=$fn_case);
	    #cube([3,1,$case_top_deep2], center=false);
	    //translate([-$case_width*0.05,$case_height/2-$case_height2,0])
	    //cylinder(h=$case_top_deep2, d=$screws_metric, $fn=$fn_case);
	}
	*/

	// front central hole
	difference()
	{
		union()
		{
			translate([ -$screws_width / 2 + $case_width * $front_central_hole_x, -$screws_height / 2 + mh_off_y, 0 ])
			cylinder(h = $case_top_deep, d1 = $screws_metric + 3, d2 = $screws_metric + 6.5, $fn = $fn_case);
			translate([
				-0.5 - $screws_width / 2 + $case_width * $front_central_hole_x, -$screws_height / 2 + mh_off_y - 6, 2
			])
			cube([ 1, 3, $case_top_deep - 2 ]);
		}

		translate([ -$screws_width / 2 + $case_width * $front_central_hole_x, -$screws_height / 2 + mh_off_y, -3 - 80 ])
		cylinder(h = $case_base_deep + 4 + 100, d = $screws_metric - 0.3, $fn = $fn_case);
	}

	// front central hole2
	difference()
	{
		union()
		{
			translate(
			    [ -$screws_width / 2 + $case_width * $front_central_hole_x - 12, -$screws_height / 2 + mh_off_y, 0 ])
			cylinder(h = $case_top_deep, d1 = $screws_metric + 3, d2 = $screws_metric + 6.5, $fn = $fn_case);
			translate([
				-0.5 - $screws_width / 2 + $case_width * $front_central_hole_x - 12, -$screws_height / 2 + mh_off_y - 6,
				2
			])
			cube([ 1, 3, $case_top_deep - 2 ]);
		}

		translate(
		    [ -$screws_width / 2 + $case_width * $front_central_hole_x - 12, -$screws_height / 2 + mh_off_y, -3 - 80 ])
		cylinder(h = $case_base_deep + 4 + 100, d = $screws_metric - 0.3, $fn = $fn_case);
	}

	// expansion connector
	/*
	difference(){
	union(){
	translate([-$pcb_width/2+23.5,$case_pcb_off_y/2-$pcb_height/2+204.92,0])
	# cylinder(h=$case_top_deep2, d1=$screws_metric+3, d2=$screws_metric+6.5, $fn=$fn_case);
	translate([-$pcb_width/2+108.33,$case_pcb_off_y/2-$pcb_height/2+204.92,0])
	# cylinder(h=$case_top_deep2, d1=$screws_metric+3, d2=$screws_metric+6.5, $fn=$fn_case);
	}
	translate([-$pcb_width/2+23.5,$case_pcb_off_y/2-$pcb_height/2+204.92,0])
	# cylinder(h=$case_top_deep2, d=$screws_metric, $fn=$fn_case);
	translate([-$pcb_width/2+108.33,$case_pcb_off_y/2-$pcb_height/2+204.92,0])
	# cylinder(h=$case_top_deep2, d=$screws_metric, $fn=$fn_case);
	}
	*/

	$nerve_width = 3;
	$nerve_deep = 4;
	height = $case_top_deep - $nerve_deep - $fillet_radius;
	height2 = $case_top_deep2 - $nerve_deep - $fillet_radius;

	if ($top_nerves)
	{
		translate([ 0, 0, 2 ])
		{

			// nerves for partition
			// middle front front
			translate([
				-$nerve_width / 2 + ($top_nerve_x - 0.5) * $case_width, -$case_height / 2, height + 2 - 0.7 - 10 + 2
			])
			cube([ $nerve_width, 5, $case_top_deep - 2 ]);

			// middle front back
			translate([
				-$nerve_width / 2 + ($top_nerve_x - 0.5) * $case_width,
				$case_height - $case_height2 - $case_height / 2 - 30, -1.2
			])
			cube([ $nerve_width, 9, $case_top_deep ]);

			// side nerve separating front and back (right)
			translate([ -$case_width / 2, -$nerve_width / 2 + $case_height2 / 2 - 2, height + 2 - 0.7 - 10 + 3 ])
			cube([ 5, $nerve_width, $case_top_deep - 3 ]);

			// side nerve separating front and back (left)
			translate([ $case_width / 2 - 5, -$nerve_width / 2 + $case_height2 / 2 - 2, height + 2 - 0.7 - 10 + 3 ])
			cube([ 5, $nerve_width, $case_top_deep - 3 ]);

			// middle back front
			translate([
				-$nerve_width / 2 + ($top_nerve_x2 - 0.5) * $case_width,
				$case_height - $case_height2 - $case_height / 2 + 3,
				height + 2 - 0.7 - 10 + $case_top_deep2 - ($case_top_deep2 - $case_top_deep)
			])
			cube([ $nerve_width, 5, $case_top_deep2 - $case_top_deep ]);

			// middle back back
			translate([
				-$nerve_width / 2 + ($top_nerve_x2 - 0.5) * $case_width, $case_height / 2 - 5,
				height + 2 - 0.7 - 10 + $case_top_deep2 - ($case_top_deep2 - $case_top_deep + 4)
			])
			cube([ $nerve_width, 5, $case_top_deep2 - $case_top_deep + 4 ]);
		}
	} // endif nerves
}

module case_base()
{
	mh_off_y = 0;
	mh_off_x = 0;

	base_mounting_holes();

	// main body
	difference()
	{

		minkowski()
		{
			translate([ 0, 0, $case_base_deep / 2 ])
			cube([ $case_width, $case_height, $case_base_deep ], center = true);
			sphere(r = $fillet_radius, $fn = $fn_case);
		}

		// hollow case
		translate([ 0, 0, ($case_base_deep + $fillet_radius) / 2 ])
		cube([ $case_width, $case_height, $case_base_deep + $fillet_radius ], center = true);

		// remove top fillet
		translate([ 0, 0, ($case_base_deep + $fillet_radius / 2) ])
		cube([ $case_width + $fillet_radius * 2, $case_height + $fillet_radius * 2, $fillet_radius ], center = true);

		if ($base_vents_enabled)
		{
			// vents
			nholes = 15;
			dholes = 3;
			whole = 1;
			hhole = 10;
			for (i = [0:1:nholes])
			{
				// front left
				translate(
				    [ -nholes * dholes / 2 + i * dholes - $case_width / 4, -$case_height * 0.4, -$case_base_deep ])
				cube([ whole, hhole, $case_base_deep * 2 ], center = true);
				// front right
				translate(
				    [ -nholes * dholes / 2 + i * dholes + $case_width / 4, -$case_height * 0.4, -$case_base_deep ])
				cube([ whole, hhole, $case_base_deep * 2 ], center = true);
				// back left
				translate([ -nholes * dholes / 2 + i * dholes - $case_width / 4, $case_height * 0.4, -$case_base_deep ])

				// back right
				cube([ whole, hhole, $case_base_deep * 2 ], center = true);
				translate([ -nholes * dholes / 2 + i * dholes + $case_width / 4, $case_height * 0.4, -$case_base_deep ])
				cube([ whole, hhole, $case_base_deep * 2 ], center = true);
			}
		}

		if (0)
		{
			// vents
			nholes2 = 9;
			dholes2 = 16;
			whole2 = 13;
			hhole2 = 90;
			for (i2 = [0:1:nholes2])
			{
				// front left
				translate([
					-nholes2 * dholes2 / 2 + i2 * dholes2 - $case_width / 4, -$case_height / 4 + 22, -$case_base_deep
				])
				cube([ whole2, hhole2, $case_base_deep * 2 ], center = true);
				// front right
				translate([
					-nholes2 * dholes2 / 2 + i2 * dholes2 + $case_width / 4, -$case_height / 4 + 22, -$case_base_deep
				])
				cube([ whole2, hhole2, $case_base_deep * 2 ], center = true);

				translate([
					-nholes2 * dholes2 / 2 + i2 * dholes2 - $case_width / 4, -$case_height / 4 + 117, -$case_base_deep
				])
				cube([ whole2, hhole2 - 30, $case_base_deep * 2 ], center = true);
				// front right
				translate([
					-nholes2 * dholes2 / 2 + i2 * dholes2 + $case_width / 4, -$case_height / 4 + 117, -$case_base_deep
				])
				cube([ whole2, hhole2 - 30, $case_base_deep * 2 ], center = true);
			}
		}

		// screw head on bottom part
		for (mh_w = [0:1:1])
		{
			// front
			translate([ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y, -3 ])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 4, $fn = $fn_case);

			// back
			translate(
			    [ -$screws_width / 2 + mh_w * $screws_width, -$screws_height / 2 + mh_off_y + $screws_height, -3 ])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 4, $fn = $fn_case);

			// middle sides
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * $side_central_hole, -3
			])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 4, $fn = $fn_case);

			// middle2
			translate([
				-$screws_width / 2 + mh_w * $screws_width,
				-$screws_height / 2 + mh_off_y + $screws_height * (1 - $case_height2 / $case_height + 0.1), -3
			])
			cylinder(h = $case_base_deep + 4, d = $screws_metric + 4, $fn = $fn_case);
		}
		// middle front
		translate([ -$screws_width / 2 + $front_central_hole_x * $case_width, -$screws_height / 2 + mh_off_y, -3 ])
		cylinder(h = $case_base_deep + 4, d = $screws_metric + 4, $fn = $fn_case);

		// middle front2
		translate([ -$screws_width / 2 + $front_central_hole_x * $case_width - 12, -$screws_height / 2 + mh_off_y, -3 ])
		cylinder(h = $case_base_deep + 4, d = $screws_metric + 4, $fn = $fn_case);

		//
		// pass-through holes for keyb and expansion
		translate([ -($pcb_width) / 2, -($pcb_height / 2 - $case_pcb_off_y / 2), 0 ])
		{
			// keyboard front
			translate([ $pcb_holes_x_off, $pcb_holes_y_off, -10 ])
			cylinder(h = 50, d = 2.7);
			translate([ $pcb_holes_x_off + $pcb_holes_dist, $pcb_holes_y_off, -10 ])
			cylinder(h = 50, d = 2.7);

			// expansion connector
			translate([ 23.5, 204.92, -10 ])
			cylinder(h = 50, d = 2.7);
			translate([ 108.33, 204.92, -10 ])
			cylinder(h = 50, d = 2.7);
		}
	}

	// inner bevel
	inner_th = 0.3;
	union()
	{
		// left
		translate([ -$case_width / 2 + 1 / 2, -inner_th, ($case_base_deep / 2 + 1) ])
		cube([ 1, $case_height - inner_th * 2, 7 ], center = true);

		// right
		translate([ $case_width / 2 - 1 / 2, -inner_th, ($case_base_deep / 2 + 1) ])
		cube([ 1, $case_height - inner_th * 2, 7 ], center = true);

		// front
		translate([ inner_th, -$case_height / 2 + 1 / 2, ($case_base_deep / 2 + 1) ])
		cube([ $case_width - inner_th * 2, 1, 7 ], center = true);
	}

	// holes for pcb
	translate([ -($pcb_width) / 2, -($pcb_height / 2 - $case_pcb_off_y / 2), 0 ])
	pcb_mounting_holes();
}

module keyboard_frame()
{
	key_size = 19;
	key_deep = 22.1;

	// offset to pcb origin
	translate([ 30.23, 88.72, 7 ])
	{

		// center first key
		// translate([key_size*1.5,key_size/2,0])
		// cylinder(h=100, d=4);

		cube([ key_size * 13, key_size, key_deep ]);

		translate([ -key_size / 2, -key_size, 0 ])
		cube([ key_size * 14, key_size, key_deep ]);

		translate([ -key_size / 4, -key_size * 2, 0 ])
		cube([ key_size * 14, key_size, key_deep ]);

		translate([ key_size / 4, -key_size * 3, 0 ])
		cube([ key_size * 13, key_size, key_deep ]);

		usize = 8;
		translate([ key_size / 4 + key_size * (7 - 0.5 - usize / 2), -key_size * 4, 0 ])
		cube([
			key_size * usize, key_size,
			key_deep
		]); // 8u space bar, change it if you plan to use a different space bar
	}
}

module pcb_mounting_holes()
{
	difference()
	{
		union()
		{
			// keyboard front
			translate([ $pcb_holes_x_off, $pcb_holes_y_off, 0 ])
			cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);
			translate([ $pcb_holes_x_off + $pcb_holes_dist, $pcb_holes_y_off, 0 ])
			cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);

			// expansion connector
			// 23.5, 204.92
			// 108.33, 204.92
			translate([ 23.5, 204.92, 0 ])
			cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);
			translate([ 108.33, 204.92, 0 ])
			cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);
		}
		// keyboard front
		translate([ $pcb_holes_x_off, $pcb_holes_y_off, -10 ])
		cylinder(h = 50, d = 2.7);
		translate([ $pcb_holes_x_off + $pcb_holes_dist, $pcb_holes_y_off, -10 ])
		cylinder(h = 50, d = 2.7);

		// expansion connector
		translate([ 23.5, 204.92, 0 ])
		cylinder(h = 50, d = 2.7);
		translate([ 108.33, 204.92, 0 ])
		cylinder(h = 50, d = 2.7);
	}

	// standoff
	translate([ $pcb_width * 0.95, $pcb_height * 0.95, 0 ])
	cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);
	translate([ $pcb_width * 0.05, $pcb_height * 0.95, 0 ])
	cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);
	translate([ $pcb_width * 0.95, $pcb_height * 0.05, 0 ])
	cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);
	translate([ $pcb_width * 0.05, $pcb_height * 0.05, 0 ])
	cylinder(h = $case_base_deep, d = $pcb_hole_diam + 3);

	/*
	translate([$pcb_width*0.95,$pcb_height*0.4,0])
	cylinder(h=$case_base_deep, d=$pcb_hole_diam+3);
	translate([$pcb_width*0.05,$pcb_height*0.4,0])
	cylinder(h=$case_base_deep, d=$pcb_hole_diam+3);
	translate([$pcb_width*0.95,$pcb_height*0.6,0])
	cylinder(h=$case_base_deep, d=$pcb_hole_diam+3);
	translate([$pcb_width*0.05,$pcb_height*0.6,0])
	cylinder(h=$case_base_deep, d=$pcb_hole_diam+3);
	*/
}

module tzxduino()
{
	height = 100;

	// mounting hole top-right
	translate([ 70, 55, 0 ])
	cylinder(h = height, r = 1.6);
	// mounting hole bottom_left (origin)
	cylinder(h = height, r = 1.6);

	// buttons

	for (i = [0:1:5])
	{
		translate([ i * 11.2 + 12.9, 0.25, 0 ])
		cylinder(h = height, r = 2.1);
	}

	s = [ "\u25b2", "\u25bc", "\u25a0", "\u25B6", "\u23CF", "\u21bb" ]; //,"!"];

	for (i = [0:1:len(s)])
	{
		translate([ i * 11.2 + 12.9, 0.25 + 7, 15.5 ])
		linear_extrude(0.5)
		    // text(s[i], size = 3, font = "", halign = "center", $fn = 50);
		    text(s[i], size = 3, valign = "center", halign = "center", font = "Liberation");
	}
	echo(s);
	// screen
	translate([ 21.92, 22.6, 0 ])
	cube([ 26.3, 16.8, height ]);

	// pcb
	translate([ -5, -5, 0 ])
	{
		color([ 0, 1, 0 ], alpha = 0.5) cube([ 80, 65, 1.4 ]);
	}

	translate([ -107.65, 88.85, 1.4 / 2 ])
	import("yatzxduino.stl");

	translate([ 80 - 18 - 3.5, 59, 8 ])
	cube([ 10, 10, 4.8 ]);

	// translate([80-28.5, 18.5+10,8])
	// cube([23.7,41.7,1.1]);

	// translate([80-28.5-55.2, 18.5+10,8])
	//#cube([23.7,41.7,1.1]);
	translate([ 80 - 28.5 - 55.2 + 13 / 2, 18.5 + 10, 8 + 1.1 ])
#cube([ 10.7, 41.7, 3 ]);
}

module tzxduino_mounting_holes()
{
	height = 100;

	// mounting hole top-right
	translate([ 70, 55, 0 ])
	{
		cylinder(h = height, r = 1.6);
#cylinder(h = $case_top_deep2, d1 = $screws_metric + 3, d2 = $screws_metric + 6.5, $fn = $fn_case);
	}
	// mounting hole bottom_left (origin)
	cylinder(h = height, r = 1.6);

	//#cylinder(h = $case_base_deep, d2 = $screws_metric + 9, d1 = $screws_metric + 9, $fn = $fn_case);
}

module case_top()
{
	// top part
	top_position = 20;

	// top front
	color($normal_color) difference()
	{
		translate([ ($pcb_width) / 2, $pcb_height / 2, top_position ])
		rotate([ 0, 180, 0 ])
		color($colortop) top_front();

		// subtract inner back part from top_front
		translate([
			($pcb_width) / 2, $pcb_height / 2 + ($case_height - $case_height2) / 2,
			top_position + //$case_top_deep2-$case_top_deep*1.5-$fillet_radius
			    -$case_top_deep / 2 + $fillet_radius / 2
		])
		cube([ $case_width, $case_height2, $case_top_deep + $fillet_radius ], center = true);

		// keyboard cutout
		translate([ 0, 0 + $case_pcb_off_y / 2, top_position - 19 ])
		minkowski()
		{
			keyboard_frame();
			sphere(r = $keyboard_frame_radius); // keep safe area
		}
	}

	// top back
	color($special_color) difference()
	{
		translate([
			($pcb_width) / 2, $pcb_height / 2 + ($case_height - $case_height2) / 2, top_position + $case_top_deep2 -
			$case_top_deep
		])
		rotate([ 0, 180, 0 ])
		color($colortop2) top_back();

		// remove front wall from top_back
		translate([
			($pcb_width) / 2, $pcb_height / 2 + ($case_height - $case_height2) / 2,
			top_position + //$case_top_deep2-$case_top_deep*1.5-$fillet_radius
			    -$case_top_deep / 2
		])
		cube([ $case_width + 2 * $fillet_radius, $case_height2 + 2 * $fillet_radius, $case_top_deep ], center = true);

		//#translate([ ($pcb_width) -80, $pcb_height -55, top_position +0 ])
		// tzxduino();
	}

	// add mounting holes
	translate([ ($pcb_width) / 2, $pcb_height / 2 - 0 * $case_pcb_off_y / 2, top_position - $case_top_deep + 0.2 ])
	case_top_mounting_holes();

	// add mounting for tzxduino
	// tzxduino_mounting_holes();
}

// translate([0,-$case_pcb_off_y/2, 0])
// case_top();

// translate([0,0,$case_base_deep-$pcb_thickness])
// pcb();

// pcb_holes();

// 0 means all case
// 1, 2, 3, 4 are the different subparts
module case_top_parts(part = 0)
{

	echo("Top part:", part);

	intersection()
	{
		translate([ 0, -$case_pcb_off_y / 2, 0 ])
		case_top();

		// all,front left, front right, back left, back right
		translation = [
			[ -$case_pcb_off_y - $fillet_radius - 5, -$case_pcb_off_y - $fillet_radius - 5, -$fillet_radius + 8 ],
			[ -$case_pcb_off_y - $fillet_radius, -$case_pcb_off_y - $fillet_radius, -$fillet_radius + 8 ],
			[
				-$case_pcb_off_y - $fillet_radius + $case_width * $top_nerve_x + $fillet_radius,
				-$case_pcb_off_y - $fillet_radius, -$fillet_radius + 8
			],

			[
				-$case_pcb_off_y - $fillet_radius, -$case_pcb_off_y - $fillet_radius + $case_height - $case_height2,
				-$fillet_radius + 8
			],

			[
				-$case_pcb_off_y - $fillet_radius + $case_width * $top_nerve_x2 + $fillet_radius,
				-$case_pcb_off_y - $fillet_radius + $case_height - $case_height2, -$fillet_radius + 8
			]
		];

		// all,front left, front right, back left, back right
		inter_cube = [[$case_width + 2 * $fillet_radius + 10, $case_height + 2 * $fillet_radius + 10,
		               $case_top_deep2 + 2 * $fillet_radius + 10],

		              [($case_width + 2 * $fillet_radius) * ($top_nerve_x),
		               ($case_height + 0 * $fillet_radius - $case_height2), $case_top_deep + 2 * $fillet_radius + 10],

		              [($case_width + 2 * $fillet_radius) * (1 - $top_nerve_x),
		               ($case_height + 0 * $fillet_radius - $case_height2), $case_top_deep + 2 * $fillet_radius + 10],

		              [($case_width + 2 * $fillet_radius) * ($top_nerve_x2), $case_height2 + 2 * $fillet_radius + 5,
		               $case_top_deep2 + 3 * $fillet_radius],

		              [($case_width + 2 * $fillet_radius) * (1 - $top_nerve_x2), $case_height2 + 2 * $fillet_radius + 5,
		               $case_top_deep2 + 2 * $fillet_radius + 10]

		];

		i_cube = [ 0, 1, 2, 3, 4 ]; // dirty array to select intersection cube
		translate(translation[part])
		{
			cube(inter_cube[i_cube[part]]);
		}
	}
}

// part 0 is everything
// 1 front left, 2 front right, 3 back left, 4 back right
module case_base_parts2(part = 0)
{
	intersection()
	{
		difference()
		{
			translate([ ($pcb_width) / 2, $pcb_height / 2 - $case_pcb_off_y / 2, 0 ])
			case_base();

			translate([ 0, 0, $case_base_deep - $pcb_thickness ])
			// pcb();
			pcb_rectangle();
		}

		// all,front left, front right, back left, back right
		trans = [
			[ -$case_pcb_off_y - $fillet_radius, -$case_pcb_off_y - $fillet_radius, -$fillet_radius ],
			[ -$case_pcb_off_y - $fillet_radius, -$case_pcb_off_y - $fillet_radius, -$fillet_radius ],
			[
				-$case_pcb_off_y - $fillet_radius + $case_width / 2 + $fillet_radius, -$case_pcb_off_y - $fillet_radius,
				-$fillet_radius
			],
			[
				-$case_pcb_off_y - $fillet_radius,
				-$case_pcb_off_y - $fillet_radius + $case_height / 2 + $fillet_radius, -$fillet_radius
			],
			[
				-$case_pcb_off_y - $fillet_radius + $case_width / 2 + $fillet_radius,
				-$case_pcb_off_y - $fillet_radius + $case_height / 2 + $fillet_radius, -$fillet_radius
			]
		];

		// 0-whole 1-quarter
		inter_cube = [[$case_width + 2 * $fillet_radius, $case_height + 2 * $fillet_radius,
		               $case_top_deep + 2 * $fillet_radius + 10],
		              [($case_width + 2 * $fillet_radius) / 2, ($case_height + 2 * $fillet_radius) / 2,
		               $case_base_deep + 2 * $fillet_radius + 10]];

		i_cube = [ 0, 1, 1, 1, 1 ]; // dirty array to select intersection cube
		translate(trans[part])
		{
			cube(inter_cube[i_cube[part]]);
		}
	}
}

/*
($base_nerve_x-0.5)*$case_width
*/

// part 0 is everything
// 1 front left, 2 front right, 3 back left, 4 back right
module case_base_parts(part = 0)
{
	intersection()
	{
		difference()
		{
			translate([ ($pcb_width) / 2, $pcb_height / 2 - $case_pcb_off_y / 2, 0 ])
			color($normal_color) case_base();

			translate([ 0, 0, $case_base_deep - $pcb_thickness ])
			// pcb();
			pcb_rectangle();
		}

		//$case_pcb_off_y en x ??? check it!!

		echo("Part:", part);

		// all,front left, front right, back left, back right
		trans = [
			[ -$case_pcb_off_x - $fillet_radius, -$case_pcb_off_y - $fillet_radius, -$fillet_radius ], // all
			[ -$case_pcb_off_x - $fillet_radius, -$case_pcb_off_y - $fillet_radius, -$fillet_radius ], // front left
			[
				-$case_pcb_off_x - $fillet_radius + $case_width * $base_nerve_x + $fillet_radius,
				-$case_pcb_off_y - $fillet_radius, -$fillet_radius
			], // front right
			[
				-$case_pcb_off_x - $fillet_radius,
				-$case_pcb_off_y - $fillet_radius + $case_height * $base_nerve_y + $fillet_radius, -$fillet_radius
			], // back left
			[
				-$case_pcb_off_x - $fillet_radius + $case_width * $base_nerve_x2 + $fillet_radius,
				-$case_pcb_off_y - $fillet_radius + $case_height * $base_nerve_y + $fillet_radius, -$fillet_radius
			] // back right
		];

		// all,front left, front right, back left, back right
		inter_cube =
		    [[$case_width + 2 * $fillet_radius, $case_height + 2 * $fillet_radius,
		      $case_top_deep + 2 * $fillet_radius + 10], // all
		     [($case_width * $base_nerve_x + $fillet_radius), ($case_height * $base_nerve_y + $fillet_radius),
		      $case_base_deep + 2 * $fillet_radius + 10], // fl
		     [($case_width * (1 - $base_nerve_x) + $fillet_radius), ($case_height * $base_nerve_y + $fillet_radius),
		      $case_base_deep + 2 * $fillet_radius + 10], // fr
		     [($case_width * $base_nerve_x2 + $fillet_radius), ($case_height * (1 - $base_nerve_y) + $fillet_radius),
		      $case_base_deep + 2 * $fillet_radius + 10], // bl
		     [($case_width * (1 - $base_nerve_x2) + $fillet_radius),
		      ($case_height * (1 - $base_nerve_y) + $fillet_radius), $case_base_deep + 2 * $fillet_radius + 10] // br
		];

		i_cube = [ 0, 1, 2, 3, 4 ]; // dirty array to select intersection cube
		translate(trans[part])
		{
			cube(inter_cube[i_cube[part]]);
		}
	}
}

module show_base_and_top()
{
	translate([ 0, 0, -40 ])
	case_base_parts(part = 0);
	translate([ 0, 0, 10 ])
	case_top_parts(part = 0);
}

// show_base_and_top();

// case_base_parts(part=0);
// case_base_parts(part=1);
// case_base_parts(part=2);
// case_base_parts(part=3);
// case_base_parts(part=4);

case_top_parts(part = 0);
// case_top_parts(part=1);
// case_top_parts(part=2);
// case_top_parts(part=3);
// case_top_parts(part=4);

// offset to pcb origin
// translate([ 0, 0, 20 ])
// translate([30.23+19/2,88.72+$case_pcb_off_y,7])
// galaksija_keyboard();

// tzxduino();
// translate([0,0,7])
// pcb();
// keyboard_frame();

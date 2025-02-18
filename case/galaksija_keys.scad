/*
 Decription: Keycaps for galaksija keyboard using cherry switches
 Author: issalig
 Date: 06/02/25

 Keytop is flat (rounded surfaces are not nice for FDM printers)
 Print it without any support.
*/
/*
 Letter options
  - A. Paint the letters with a permanent marker.
  - B. Print them and stick them onto the keys. ($text_enabled = false)
  - C. Change the filament color and add the following to your gcode.

;ADD BEFORE THE LAST AFTER_LAYER_CHANGE

;COLOR_CHANGE BEGIN
;ADD SAFETY HEIGHT
G1 Z17 F9000
;STOP FOR CHANGE
M0
;EXTRUDE MATERIAL
G1 E450 F500
;STOP TO CLEAN OR WHATEVER
M0
;RETURN TO HEIGHT
G1 Z10.8 F9000
;COLOR_CHANGE_END

;AFTER_LAYER_CHANGE

*/

$font_name = "GreenMountain3"; // https://www.whatfontis.com/FF_Green-Mountain-3.font
$font_color = [ 0, 0, 0 ];
$special_key_color = "#deb887";
$normal_key_color = [ 0.95, 0.95, 0.95 ];
$text_enabled = true; // characters on keys
$key_space = 19;      // space between keys in pcb

$fn_keys = 40;
$fn_text = 20;
$fn = $fn_keys;

$key_thickness = 1;

$font_size = 6;
$font_size_medium = 4;
$font_size_small = 3;
$text_height = 0.2 * 2; // 0.4 better for FDM

// supports
$stem_support = false; // in case there are adhesion problems
$grid_support = false; // if you plan to print it all together

// main key function
module key(width = 18, height = 18, deep = 7.2, x_diff = 5.2, y_diff = 4.5, z_diff = 0, slant = 0, y_off = 2,
           rounded_corner = 0.5, rounded_corner2 = 3,  thickness = $key_thickness, upper_bevel_radius = 0, slant = 0, base_height = 0.001)
{
    //rounded_corner is radius on corner at bottom
    //rounded_corner2 is radius on corner at top
    
	deep2 = deep + z_diff;
	w_up = width - x_diff; // upper width

	// compute angle for upper side
	ang = atan2(deep - deep2, w_up) + slant;

	// keycap is the difference of inner and outer shell
	// inner and outher shells are hulls from upper and bottom countours
	{
		difference()
		{
			// outer
			hull()
			{
				// bottom side
				translate([ 0, 0, 0.5 * 0 ]) //????  //remember to lower it later by -0.5
				minkowski()
				{
					cube([ width - 2 * rounded_corner, height - 2 * rounded_corner, base_height ], center = true);
					cylinder(r = rounded_corner, h = 0.001, $fn = $fn_keys);
				}

				// upper side
				translate([ 0, y_off, min(deep, deep2) + abs(deep - deep2) / 2 - upper_bevel_radius ])
				// min(h_front[row], h_back[row]) + abs(h_front[row] - h_back[row]) / 2  - upper_bevel_radius])

				rotate([ -ang, 0, 0 ])
				// fillet
				minkowski()
				{
					// rounded corners
					minkowski()
					{
						cube(
						    [
							    width - x_diff - 2 * rounded_corner2 - 2 * upper_bevel_radius,
							    height - y_diff - 2 * rounded_corner2 - 2 * upper_bevel_radius, 0.001
						    ],
						    center = true);
						cylinder(r = rounded_corner2, h = 0.001, $fn = $fn_keys);
					}
					sphere(r = upper_bevel_radius, $fn = $fn_keys);
				}
			}

			// inner is a hull of bottom and upper
			hull()
			{
				translate([ 0, 0, -0.01 ]) // needed it to make the hole

				// bottom
				minkowski()
				{
					cube([ width - 2 * thickness - rounded_corner, height - 2 * thickness - rounded_corner, 0.001 ],
					     center = true);
					cylinder(r = rounded_corner / 2, h = 0.001, $fn = $fn_keys);
				}

				// upper
				translate([ 0, y_off, min(deep, deep2) - max(1 * thickness, upper_bevel_radius) ])
				// translate([ 0, 2 * thickness, min(h_front[row], h_back[row]) - 1 * thickness ])
				rotate([ -ang, 0, 0 ])

				minkowski()
				{
					// inner rounded corner is halved
					cube(
					    [
						    width - x_diff - 2 * thickness - rounded_corner2 - rounded_corner,
						    height - y_diff - 2 * thickness - rounded_corner2 - rounded_corner, 0.001
					    ],
					    center = true);
					cylinder(r = rounded_corner2 / 2, h = 0.001, $fn = $fn_keys);
				}
			}
		}
	}

	// grid support
	if ($grid_support)
	{
		ls = 6;

		// right
		translate([ width / 2, 0, 1 / 2 ])
#cube([ 2, 1, 1 ], center = true);
		// down
		translate([ -1.5, -height / 2, 1 / 2 ])
		rotate([ 0, 0, 90 ])
#cube([ 2, 1, 1 ], center = true);
	}
}

// normal key, uses key module and adds stem
module key_galaksija()
{
	// key
	width = 18;
	height = 18;
	x_diff = 3;
	y_diff = 3;
	y_off = y_diff / 2 - 1;
	deep = 10.5;
	key(width = width, height = height, x_diff = x_diff, y_diff = y_diff, y_off = y_off, deep = deep,
	    upper_bevel_radius = 1, rounded_corner = 1.5, base_height = 0.001, thickness = $key_thickness);

	// stem
	deep_stem = deep - 0.5;
	off_y_stem = 0;
	translate([ 0, 0, off_y_stem ])
	cherry_stem(deep = deep_stem - off_y_stem, cross_thickness = 1.25);
}

// cherry stem dimensions
// https://telcontar.net/KBK/Cherry/images/MX/Cherry_8_mm_mount.svgz
module cherry_stem(cross_thickness = 1.25, cross_width = 5, cross_deep = 4.1, outer_width = 6.85, outer_height = 4.5,
                   deep = 20)
{
	// for dust switches, non tested!!!
	// outer_width = 5.7;
	// outer_height = 4;

	// trapezoidal upper ending
	hull()
	{
		translate([ 0, 0, deep ])
		cube([ outer_width * 1.5, outer_height * 1.5, 0.1 ], center = true);
		translate([ 0, 0, cross_deep + 1 ])
		cube([ outer_width, outer_height, 0.1 ], center = true);
	}

	// stem body
	difference()
	{
		translate([ 0, 0, (cross_deep + 1.5) / 2 ])
		cube([ outer_width, outer_height, cross_deep + 1.5 ], center = true);

		// cross is made with 2 crossing cubes
		translate([ 0, 0, cross_deep / 2 ])
		cube([ cross_width, cross_thickness, cross_deep ], center = true);
		translate([ 0, 0, cross_deep / 2 ])
		cube([ cross_thickness, cross_width, cross_deep ], center = true);
	}

	// printing support
	if ($stem_support)
	{
		ls = 6;

		// left right
		translate([ ls, 0, 0.4 / 2 ])
		cube([ ls, 0.4, 0.4 ], center = true);
		translate([ -(ls), 0, 0.4 / 2 ])
		cube([ ls, 0.4, 0.4 ], center = true);

		translate([ 1.5, ls - 1, 0.4 / 2 ])
		rotate([ 0, 0, 90 ])
		cube([ ls, 0.4, 0.4 ], center = true);
		translate([ -1.5, ls - 1, 0.4 / 2 ])
		rotate([ 0, 0, 90 ])
		cube([ ls, 0.4, 0.4 ], center = true);

		translate([ 1.5, -ls + 1, 0.4 / 2 ])
		rotate([ 0, 0, 90 ])
		cube([ ls, 0.4, 0.4 ], center = true);
		translate([ -1.5, -ls + 1, 0.4 / 2 ])
		rotate([ 0, 0, 90 ])
		cube([ ls, 0.4, 0.4 ], center = true);
	}
}

// enter key is 2u
module key_enter_galaksija(u = 2)
{
	height = 18;
	width = 19 * u - 1; // 18.5*u-0.2;
	deep = 10.5;
	x_diff = 3;
	y_diff = 3;
	y_off = y_diff / 2 - 1;

	key(width = width, height = height, x_diff = x_diff, y_diff = y_diff, y_off = y_off, deep = deep,
	    upper_bevel_radius = 1, rounded_corner = 1.5, base_height = 0.001, thickness = $key_thickness);

	deep_stem = deep - 0.5;
	off_y_stem = 0;

	// central stem is a little bit displaced to the right. measured in pcb
	translate([ 0.24, 0, off_y_stem ])
	cherry_stem(deep = deep_stem - off_y_stem, cross_thickness = 1.25);
}

// space is 8u
module key_space_galaksija(u = 8)
{
	height = 19 - 1;
	width = 19 * u - 1; // 18.5*u-0.2;
	deep = 10.5 + 0.5;  // space is slightly higher than normal key
	x_diff = 3;
	y_diff = 3;
	y_off = y_diff / 2 - 1;

	hole_dist = 77.928 + 14;

	echo("Spacebar width:", width * u - 0.2);

	// space is thicker than normal keys
	key(width = width, height = height, x_diff = x_diff, y_diff = y_diff, y_off = y_off, deep = deep,
	    upper_bevel_radius = 1.75, rounded_corner = 1.5, base_height = 0.001, thickness = $key_thickness);

	deep_stem = deep - 0.5;
	off_y_stem = 0;

	// central stem
	translate([ 0, 0, off_y_stem ])
	cherry_stem(deep = deep_stem - off_y_stem, cross_thickness = 1.25);
	// side stems for retainers
	translate([ hole_dist / 2, 0, off_y_stem ])
	cherry_stem(deep = deep_stem - off_y_stem, cross_thickness = 1.25);
	translate([ -hole_dist / 2, 0, off_y_stem ])
	cherry_stem(deep = deep_stem - off_y_stem, cross_thickness = 1.25);

	// centering tubes
	translate([ hole_dist / 2 + 1 + 10, 0, off_y_stem ])
	difference()
	{
		cylinder(h = deep, d = 6.4);
		cylinder(h = deep - 4, d1 = 4.9, d2 = 4);
	}
	translate([ -(hole_dist / 2 + 1 + 10), 0, off_y_stem ])
	difference()
	{
		cylinder(h = deep, d = 6.4);
		cylinder(h = deep - 4, d1 = 4.9, d2 = 4);
	}

	translate([ 25, 0, off_y_stem ])
	difference()
	{
		cylinder(h = deep, d = 6.4);
		cylinder(h = deep - 4, d1 = 4.9, d2 = 4);
	}
	translate([ -25, 0, off_y_stem ])
	difference()
	{
		cylinder(h = deep, d = 6.4);
		cylinder(h = deep - 4, d1 = 4.9, d2 = 4);
	}
}

// text on keys
module text_galaksija(text = "A", deep = 10.5, font_size = $font_size, font_name = "GreenMountain3",
                      font_height = $text_height)
{
  
	if (($text_enabled))
	{

		y_offset = 0.5;

		translate([ 0, y_offset, deep ])
		color($font_color) linear_extrude(height = font_height)
		{
			text(text, size = font_size, font = font_name, halign = "center", valign = "center", $fn = $fn_text);
		}
	}
}

// double text on keys
module double_text_galaksija(text = "1", text2 = "!", deep = 10.5, font_size = $font_size_medium,
                             font_name = $font_name, font_height = $text_height)
{
	if ($text_enabled)
	{
		y_offset = 0.5 + 3.5;
		y_offset2 = -3;

		translate([ 0, y_offset, deep ])
		color($font_color) linear_extrude(height = font_height)
		{
			// offset(0.1)
			text(text, size = font_size, font = font_name, halign = "center", valign = "center", $fn = $fn_text);
		}

		translate([ 0, y_offset2, deep ])
		color($font_color) linear_extrude(height = font_height)
		{
			text(text2, size = font_size, font = font_name, halign = "center", valign = "center", $fn = $fn_text);
		}
	}
}

module ntilde_text_galaksija(text = "\u007e", text2 = "N", deep = 10.5, font_size = $font_size, font_name = $font_name,
                             font_height = $text_height)
{
	if ($text_enabled)
	{
		y_offset = 4;
		y_offset2 = 0.5;

		translate([ 0, y_offset, deep ])
		color($font_color) linear_extrude(height = font_height)
		{
			text(text, size = font_size, font = "", halign = "center", valign = "center", $fn = $fn_text);
		}

		translate([ 0, y_offset2, deep ])
		color($font_color) linear_extrude(height = font_height)
		{
			text(text2, size = font_size, font = font_name, halign = "center", valign = "center", $fn = $fn_text);
		}
	}
}

module stoplist_text_galaksija(text = "STOP", text2 = "LIST", deep = 10.5, font_size = $font_size_small,
                               font_name = $font_name, font_height = $text_height)
{
	if ($text_enabled)
	{
		y_offset = 2.5;
		y_offset2 = -1.5;

		translate([ 0, y_offset, deep ])
		color($font_color) linear_extrude(height = font_height)
		{
			text(text, size = font_size, font = $font_name, halign = "center", valign = "center", $fn = $fn_text);
		}

		translate([ 0, y_offset2, deep ])
		color($font_color) linear_extrude(height = font_height)
		{
			text(text2, size = font_size, font = $font_name, halign = "center", valign = "center", $fn = $fn_text);
		}
	}
}

module galaksija_row1()
{
	double_letters = "!1\"2#3$4%5&6'7(8)9 0*:-=";
	echo(len(double_letters));
	for (i = [0:len(double_letters) / 2 - 1])
	{
		translate([ 0 + 19 * i, 0, 0 ])
		{
			// text_galaksija(text=letters[i]);
			double_text_galaksija(text = double_letters[2 * i], text2 = double_letters[2 * i + 1]);
			color($normal_key_color) key_galaksija();
			// echo("letter",i, double_letters[i*2], double_letters[i*2+1]);
		}
	}

	translate([ 0 + 19 * len(double_letters) / 2, 0, 0 ])
	{
		text_galaksija(text = "BRK", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
}

module galaksija_row2()
{
	text_galaksija(text = "↑", font_name = "", font_size = 10);
	color($special_key_color) key_galaksija();

	letters_2r = "QWERTYUIOP";
	for (i = [0:len(letters_2r) - 1])
	{
		translate([ 0 + 19 * (i + 1), 0, 0 ])
		{
			text_galaksija(text = letters_2r[i]);
			color($normal_key_color) key_galaksija();
		}
	}

	arrows = "←→";
	for (i = [0:len(arrows) - 1])
	{
		translate([ 19 * (i + len(letters_2r) + 1), 0, 0 ])
		{
			text_galaksija(text = arrows[i], font_name = "", font_size = 10);
			color($special_key_color) key_galaksija();
		}
	}

	translate([ 0 + 19 * (len(letters_2r) + 3), 0, 0 ])
	{
		text_galaksija(text = "DEL", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
}

module galaksija_row3()
{
	text_galaksija(text = "↓", font_name = "", font_size = 10);
	color($special_key_color) key_galaksija();

	letters_3r = "ASDFGHJKL";
	for (i = [0:len(letters_3r) - 1])
	{
		translate([ 0 + 19 * (i + 1), 0, 0 ])
		{
			text_galaksija(text = letters_3r[i]);
			color($normal_key_color) key_galaksija();
			// echo("letter",i, letters_3r[i]);
		}
	}

	double_letters2 = "+;";
	for (i = [0:len(double_letters2) / 2 - 1])
	{
		translate([ 0 + 19 * (i + len(letters_3r) + 1), 0, 0 ])
		{
			double_text_galaksija(text = double_letters2[2 * i], text2 = double_letters2[2 * i + 1]);
			color($normal_key_color) key_galaksija();
		}
	}

	translate([ 0 + 19 * (len(letters_3r) + 2.5), 0, 0 ])
	{
		text_galaksija(text = "ENTER", font_size = $font_size_medium);
		color($special_key_color) key_enter_galaksija();
	}

	translate([ 0 + 19 * (len(letters_3r) + 4), 0, 0 ])
	{
		stoplist_text_galaksija();
		color($special_key_color) key_galaksija();
	}
}

module galaksija_row4()
{
	letters_4r = " ZXCVBNM";
	for (i = [0:len(letters_4r) - 1])
	{
		translate([ 0 + 19 * i, 0, 0 ])
		{
			text_galaksija(text = letters_4r[i]);
			color($normal_key_color) key_galaksija();
			// echo("letter",i, letters_4r[i]);
		}
	}

	double_letters2 = "<,>.?/";
	for (i = [0:len(double_letters2) / 2 - 1])
	{
		translate([ 0 + 19 * (i + len(letters_4r)), 0, 0 ])
		{
			double_text_galaksija(text = double_letters2[2 * i], text2 = double_letters2[2 * i + 1]);
			color($normal_key_color) key_galaksija();
		}
	}

	translate([ 0 + 19 * (len(letters_4r) + 3), 0, 0 ])
	{
		text_galaksija(text = "REPT", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}

	translate([ 0 + 19 * (len(letters_4r) + 4), 0, 0 ])
	color($normal_key_color) key_galaksija();
}

module galaksija_extra_chars()
{
	translate([ -20, 0, 0 ])
	{
		ntilde_text_galaksija();
		color($normal_key_color) key_galaksija();
	}

	translate([ -40, 0, 0 ])
	{
		text_galaksija(text = "€", font_name = "");
		color($normal_key_color) key_galaksija();
	}
}

module galaksija_double_letters_numbers()
{
	double_letters = "!1\"2#3$4%5&6'7(8)9 0";
	echo(len(double_letters));
	for (i = [0:len(double_letters) / 2 - 1])
	{
		translate([ 0 + 19 * i, 0, 0 ])
		{
			// text_galaksija(text=letters[i]);
			double_text_galaksija(text = double_letters[2 * i], text2 = double_letters[2 * i + 1]);
			color($normal_key_color) key_galaksija();
			// echo("letter",i, double_letters[i*2], double_letters[i*2+1]);
		}
	}
}

module galaksija_double_letters_symbols()
{
	double_letters2 = "*:-=+;<,>.?/";
	for (i = [0:len(double_letters2) / 2 - 1])
	{
		translate([ 0 + 19 * i, 0, 0 ])
		{
			double_text_galaksija(text = double_letters2[2 * i], text2 = double_letters2[2 * i + 1]);
			color($normal_key_color) key_galaksija();
		}
	}
}

module galaksija_special_keys()
{
	translate([ -30, 0, 0 ])
	{
		stoplist_text_galaksija();
		color($normal_key_color) key_galaksija();
	}
	translate([ 0, 0, 0 ])
	{
		text_galaksija(text = "ENTER", font_size = $font_size_small);
		color($special_key_color) key_enter_galaksija();
	}
	translate([ 30, 0, 0 ])
	{
		text_galaksija(text = "BRK", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
	translate([ 50, 0, 0 ])
	{
		text_galaksija(text = "DEL", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
	translate([ 70, 0, 0 ])
	{
		text_galaksija(text = "REPT", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
	translate([ 90, 0, 0 ])
	{
		text_galaksija(text = "DEL", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}

	arrows = "→←↑↓";
	for (i = [0:len(arrows) - 1])
	{
		translate([ 110 + 19 * i, 0, 0 ])
		{
			text_galaksija(text = arrows[i], font_name = "", font_size = 10);
			color($special_key_color) key_galaksija();
			// echo("letter",i, arrows[i]);
		}
	}
}

module galaksija_sample_keys()
{

	translate([ 0, 0, 0 ])
	{
		text_galaksija(text = "ENTER", font_size = $font_size_small);
		color($special_key_color) key_enter_galaksija();
	}
	translate([ 30, 0, 0 ])
	{
		text_galaksija(text = "BRK", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
	translate([ 50, 0, 0 ])
	{
		text_galaksija(text = "DEL", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
	translate([ 70, 0, 0 ])
	{
		text_galaksija(text = "REPT", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}
	translate([ 90, 0, 0 ])
	{
		text_galaksija(text = "DEL", font_size = $font_size_small);
		color($special_key_color) key_galaksija();
	}

	translate([ 110, 0, 0 ])
	{
		stoplist_text_galaksija();
		color($special_key_color) key_galaksija();
	}
}

module galaksija_keyboard()
{
	// galaksija_special_keys();
	// galaksija_double_letters_numbers();
	galaksija_row1();
	translate([ -19 / 2, -19, 0 ])
	galaksija_row2();
	translate([ -19 / 4, -19 * 2, 0 ])
	galaksija_row3();
	translate([ 19 / 4, -19 * 3, 0 ])
	galaksija_row4();
	// galaksija_double_letters_symbols();
	// galaksija_extra_chars();

	translate([ 19 / 4 + 19 * 6, -19 * 4, 0 ])
	{
		color($normal_key_color) key_space_galaksija(u = 8); // 6.55);
	}
}

module retainer_ring()
{
	// frame
	difference()
	{
		cube([ 3.2, 7, 3.8 ]);
		translate([ 1, 1, 0 ])
		cube([ 1.2, 5, 3.8 ]);
	}
	// leg
	translate([ -3.6, 2.3, 0 ])
	cube([ 3.6, 1.25, 3.8 ]);
}

module stabilizer_hook()
{
	$fn = $fn_keys;
	l = 15.24;

	difference()
	{
		// center of bottom leg is the origin
		linear_extrude(height = 3) polygon(points = [
			[ -2, 2 ], [ -2, l - 8 ], [ -4, l - 8 ], [ -4, l - 12.1 ], [ -7, l - 12.6 ], [ -7, l - 19.75 ],
			[ -3.4, l - 18.75 ], [ -2.6, l - 17.95 ],
			[ -3, l - 17.65 ], // adjust this if hook space is too narrow for the wire to enter
			[ -3.8, l - 17.85 ], [ -5.8, l - 18.25 ], [ -5.8, l - 16.25 ], [ -2, l - 17.25 ] //,
			                                                                                 //[ 0, l - 17.25 ]
		]);

		// list=[for (i=points) [i[0],i[1]]];
		// echo(list);
	}

	// ring for pcb fixation
	translate([ -5, 0, 3 ])
	rotate([ 0, 180, 0 ])
	translate([ -3, -4.4, -6 ])
	rotate([ 0, 90, 0 ])
	difference()
	{
		union()
		{
			hull()
			{
				// bottom part
				translate([ -6 - 7, 4, -0 ])
				cube([ 26.5 + 7, 8, 1 ]); // 9
				// upper part
				translate([ -6, 8, 0 ])
				cube([ 23, 4, 2 ]); // reinforce
			}

			translate([ -3, -0.6, 0 ])
			cube([ 6, 6, 1.6 ]);
			cylinder(h = 1.6, d = 6);
		}
		// screw hole
		cylinder(h = 1.6, d = 3.3);
	}

	// centering tube outer
	translate([ -14.5, 8, 27 ])
	rotate([ 0, 90, 0 ])
	difference()
	{
		cylinder(h = 12.5, d = 9);
		cylinder(h = 12.5, d = 7.5);
	}

	// centering tube inner
	translate([ -14.5, 8, -5 ])
	rotate([ 0, 90, 0 ])
	difference()
	{
		cylinder(h = 12.5, d = 9);
		cylinder(h = 12.5, d = 7.5);
	}
}

module galaksija_space_stabilizer()
{

	// hook part for right and left
	hole_dist = 77.928;
	translate([ hole_dist / 2 - 9, -8, -20 ])
	rotate([ 0, 90, 0 ])
	stabilizer_hook();

	mirror([ 0, 1, 0 ]) translate([ -hole_dist / 2 + 9, 8, -20 ])
	rotate([ 0, 0, 180 ])
	rotate([ 0, 90, 0 ])
	stabilizer_hook();

	// hull()    {
	translate([ -hole_dist / 2 - 2.5, -18, -20 + 2 ])
	cube([ hole_dist + 5, 4, 1.6 ]);

	translate([ -hole_dist / 2 - 2.5, -16, -20 + 2 ])
	cylinder(h = 1.6, r = 2);
	translate([ -(-hole_dist / 2 - 2.5), -16, -20 + 2 ])
	cylinder(h = 1.6, r = 2);
}

module labels_dxf()
{
	// key outline
	projection(cut = true) translate([ 0, 0, -10.49 ])
	// key_enter_galaksija();
	galaksija_keyboard();

	// fonts
	projection(cut = true) translate([ 0, 0, -10.6 ])
	// key_enter_galaksija();
	galaksija_keyboard();
}

module keyboard_all(){
    // full keyboard
    galaksija_keyboard();

    // space stabilizer
    translate([ 118.5, -100, 18 ])
    color($normal_key_color) galaksija_space_stabilizer();

    // retainer rings
    translate([ 118.5, -100, 0 ])
    color($normal_key_color) retainer_ring();
    translate([ 118.5 + 10, -100, 0 ])
    color($normal_key_color) retainer_ring();
}

keyboard_all();

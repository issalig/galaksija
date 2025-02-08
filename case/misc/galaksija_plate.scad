//generate top.dxf
//top
//projection(cut = false)
//rotate([0,0,-90])
//translate([-4-223,43,0])
//import("galaksija_mm.stl");

//generate keyboard_plate.dxf
projection()
//rotate([0,90,0])
translate([0,0,-0.5])
//linear_extrude(height = 5, center = true, $fn = 16)
{
import("galaksija_keyboard_plate.stl");
}

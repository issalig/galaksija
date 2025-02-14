# description: Generate stickers for Galaksija keyboard
# author: issalig
# date: 11/02/2025

from lxml import etree
import base64
import os
import cairosvg
import argparse

# global variables
global_font_size_normal = 6 + 0.5
global_font_size_medium = 4 + 0.5
global_font_size_small = 3
global_start_x = 10
global_start_y = 10
global_width = 12
global_height = 12
global_round_size = 1
global_cols = 16
global_horizontal_space = 3
global_vertical_space = 3
global_font_name = "GreenMountain3"

global_x, global_y = global_start_x, global_start_y
global_row_count = 0
color = "black"


def embed_font(font_path):
    with open(font_path, 'rb') as font_file:
        font_data = base64.b64encode(font_file.read()).decode('utf-8')
    return f"""
        @font-face {{
            font-family: '{os.path.splitext(os.path.basename(font_path))[0]}';
            src: url('data:application/x-font-ttf;charset=utf-8;base64,{font_data}');
        }}
    """


def generate_text_svg(x, y, letter, font_name, font_size, width, height, color):
    
    # Create centered text
    text = etree.Element("text", {
        "x": str(x + width / 2),
        "y": str(y + height / 2),
        "font-family": font_name,
        "font-size": str(font_size),
        "text-anchor": "left",
        "dominant-baseline": "middle",
        "fill": color
    })
    text.text = letter
    
    return text

def generate_letter_svg(x, y, letter, font_name, font_size, width, height, round_size, 
                       fill_rect="none", stroke_rect=color, fill_text=color):
    rect = etree.Element("rect", {
        "x": str(x), "y": str(y),
        "width": str(width), "height": str(height), 
        "rx": str(round_size), "ry": str(round_size),
        "stroke": stroke_rect, "fill": fill_rect, "stroke-width": "0.1"
    })
    
    text = etree.Element("text", {
        "x": str(x + width / 2),
        "y": str(y + height / 2),
        "font-family": font_name,
        "font-size": str(font_size),
        "text-anchor": "middle",
        "dominant-baseline": "middle",
        "fill": fill_text
    })
    text.text = letter
    
    return rect, text

def generate_double_letter_svg(x, y, upper_letter, lower_letter, font_name, font_size, width, height, round_size,
                             fill_rect="none", stroke_rect=color, fill_text=color):
    rect = etree.Element("rect", {
        "x": str(x), "y": str(y),
        "width": str(width), "height": str(height),
        "rx": str(round_size), "ry": str(round_size),
        "stroke": stroke_rect, "fill": fill_rect, "stroke-width": "0.1"
    })
    
    common_text_attrs = {
        "font-family": font_name,
        "font-size": str(font_size),
        "text-anchor": "middle",
        "dominant-baseline": "middle",
        "fill": fill_text
    }
    
    upper_text = etree.Element("text", {
        "x": str(x + width / 2),
        "y": str(y + height / 3),
        **common_text_attrs
    })
    upper_text.text = upper_letter
    
    lower_text = etree.Element("text", {
        "x": str(x + width / 2),
        "y": str(y + 2 * height / 3),
        **common_text_attrs
    })
    lower_text.text = lower_letter
    
    return rect, upper_text, lower_text

def add_svg_image(parent, x, y, width, height, image_path):
    image = etree.SubElement(parent, "image", {
        "x": str(x),
        "y": str(y),
        "width": str(width),
        "height": str(height),
        "href": image_path
    })
    return image

def embed_svg_file(parent, x, y, svg_filepath):
    # Read as bytes instead of string
    with open(svg_filepath, 'rb') as file:
        svg_content = file.read()
    
    # Create a group element for the imported SVG
    group = etree.SubElement(parent, "g", {
        "transform": f"translate({x},{y})"
    })
    
    # Parse the SVG content
    imported_svg = etree.fromstring(svg_content)
    
    viewbox = imported_svg.get('viewBox')
    if viewbox:
        _, _, orig_width, orig_height = map(float, viewbox.split())
        scale_x = 1
        scale_y = 1
        group.set("transform", f"translate({x},{y}) scale({scale_x},{scale_y})")
        
    for child in imported_svg:
        group.append(child)
    
    return group

def generate_all_letters(svg, rect_fill, rect_stroke, text_fill):
    global global_x, global_y, global_row_count, global_start_x, global_start_y
    global global_font_size_normal, global_font_size_medium, global_font_size_small
    global global_vertical_space

    start_x = global_start_x
    start_y = global_start_y
    vertical_space = global_vertical_space
    
    font_size_normal = global_font_size_normal
    font_size_medium = global_font_size_medium
    font_size_small = global_font_size_small
    
    letters="ABCDEFGHIJKLMNOPQRSTUVWXYZ←→↑↓"
    double_letters = "!1\"2#3$4%5&6'7(8)9 0*:-=<,>.?/+;"
    double_words = ["STOP","LIST"]
    words = ["BRK","DEL","REPT"]
    cols = 16
    horizontal_space = 3
    vertical_space = 3
    font_name = global_font_name
    font_size = 6
    width = 12
    height = 12
    round_size = 1
    
    x = global_x  # Use global values
    y = global_y
    row_count = global_row_count

    # normal letters
    for i, letter in enumerate(letters):
        if i % cols == 0 and i != 0:
            y += width + vertical_space
            x = start_x #+ (row_count % 2) * row_offset
            row_count += 1
        
        rect, text = generate_letter_svg(x, y, letter, font_name, font_size_normal, width, height, round_size, rect_fill, rect_stroke, text_fill)
        svg.append(rect)
        svg.append(text)
        
        x += width + horizontal_space
    
    x, y = start_x, y + width + vertical_space
    
    # double letters
    for i in range(0, len(double_letters), 2):
        if i + 1 < len(double_letters):
            upper_letter = double_letters[i]
            lower_letter = double_letters[i + 1]
            rect, upper_text, lower_text = generate_double_letter_svg(x, y, upper_letter, lower_letter, font_name, font_size_medium, width, height, round_size, rect_fill, rect_stroke, text_fill)
            svg.append(rect)
            svg.append(upper_text)
            svg.append(lower_text)
            
            x += width + horizontal_space

    x, y = start_x, y + width + vertical_space
    
    # double words
    for i in range(0, len(double_words), 2):
        if i + 1 < len(double_words):
            upper_letter = double_words[i]
            lower_letter = double_words[i + 1]
            rect, upper_text, lower_text = generate_double_letter_svg(x, y, upper_letter, lower_letter, font_name, font_size_small, width, height, round_size, rect_fill, rect_stroke, text_fill)
            svg.append(rect)
            svg.append(upper_text)
            svg.append(lower_text)

            x += width + horizontal_space

    # single words
    for i, letter in enumerate(words):
        if i % cols == 0 and i != 0:
            y += width + vertical_space
            x = start_x #+ (row_count % 2) * row_offset
            row_count += 1
        
        rect, text = generate_letter_svg(x, y, letter, font_name, font_size_small, width, height, round_size, rect_fill, rect_stroke, text_fill)
        svg.append(rect)
        svg.append(text)
        
        x += width + horizontal_space

    # enter is bigger
    rect, text = generate_letter_svg(x, y, "ENTER", font_name, font_size_medium, 31, height, round_size, rect_fill, rect_stroke, text_fill)
    svg.append(rect)
    svg.append(text)
    x += 31 + horizontal_space

    rect, text = generate_letter_svg(x, y, "GLKSJ", font_name, font_size_medium, 31, height, round_size, rect_fill, rect_stroke, text_fill)
    svg.append(rect)
    svg.append(text)
    x += 31 + horizontal_space        

    global_x = x
    global_y = y
    global_row_count = row_count
    
    return svg, x, y

def generate_files():
    global global_x, global_y, global_row_count, global_font_size_normal, global_start_x, global_start_y
    global global_vertical_space
    global global_font_name
    

    font_name = global_font_name

    start_x = global_start_x
    start_y = global_start_y
    
    vertical_space = global_vertical_space

    # A4 landscape orientation (210 x 297 mm)
    landscape_height_a4 = 210
    landscape_width_a4 = 297
    svg = etree.Element("svg", 
        xmlns="http://www.w3.org/2000/svg",
        width=f"{landscape_width_a4}mm",
        height=f"{landscape_height_a4}mm",
        viewBox=f"0 0 {landscape_width_a4} {landscape_height_a4}"
    )

    # Add style element with embedded font
    font_path = "./greenm03.ttf"  # Update this path
    style = etree.SubElement(svg, "style")
    style.text = embed_font(font_path)

    svg, global_x, global_y = generate_all_letters(svg, rect_fill="none", rect_stroke=color, text_fill=color)
    
    global_x = start_x
    global_y = global_y + width*2 + vertical_space
    svg, global_x, global_y = generate_all_letters(svg, rect_fill=color, rect_stroke=color, text_fill="white")
    
    global_x = start_x
    global_y = global_y + width + vertical_space
    text = generate_text_svg(global_x, global_y, "GALAKSIJA GALAKSIJA GALAKSIJA", font_name, global_font_size_normal+4, width, height, color)
    svg.append(text)

    # Add style element with embedded font
    #font_path = "path/to/your/GreenMountain3.ttf"  # Update this path
    #style = etree.SubElement(svg, "style")
    #style.text = embed_font(font_path)

    # In your generate_svg function, after the text elements:
    global_x, global_y = start_x, global_y + width + vertical_space
    logo_path = "misc/logo.svg"  # Update this path
    logo = embed_svg_file(svg, global_x, global_y, logo_path)
    svg.append(logo)
    logo2 = embed_svg_file(svg, global_x+110, global_y, logo_path)
    svg.append(logo2)


    # Convert to string and write to file
    #output_file = "letters.svg"

    tree = etree.ElementTree(svg)
    with open(output_file, "wb") as f:
        tree.write(f, pretty_print=True, xml_declaration=True, encoding="utf-8")
    
    print(f"SVG file '{output_file}' has been generated.")

    # Convert to PDF
    pdf_output = output_file.replace('.svg', '.pdf')
    cairosvg.svg2pdf(url=output_file, write_to=pdf_output)

    print(f"PDF file '{pdf_output}' has been generated.")


#main function
if __name__ == "__main__":
    # argparse options for help
    parser = argparse.ArgumentParser(
        description='Generate keyboard stickers for Galaksija computer'
    )
    parser.add_argument(
        '--font', 
        default='GreenMountain3',
        help='Font name to use for text (default: GreenMountain3)'
    )
    parser.add_argument(
        '--output', 
        default='galaksija_letters',
        help='Output filename without extension (default: letters)'
    )
    parser.add_argument(
        '--color', 
        default="black",
        help='Text color (default: black)'
    )
    parser.add_argument(
        '--width', 
        type=float,
        default=12,
        help='Width of keys in mm (default: 12)'
    )
    parser.add_argument(
        '--height',
        type=float, 
        default=12,
        help='Height of keys in mm (default: 12)'
    )

    args = parser.parse_args()
    
    # Update globals from args
    global width, height
    global_font_name = args.font
    width = args.width
    height = args.height
    output_file = f"{args.output}.svg"

    color = args.color

    generate_files()


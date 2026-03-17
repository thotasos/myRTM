#!/usr/bin/env python3
"""
Create a high-resolution macOS app icon for myRTM (Remember The Milk style task manager).
Inspired by Apple's News app icon - rounded square with a distinctive gradient and symbol.
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_rounded_rectangle(width, height, corner_radius):
    """Create a rounded rectangle mask."""
    mask = Image.new('L', (width, height), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, width, height), corner_radius, fill=255)
    return mask

def create_app_icon(size, output_path):
    """
    Create a single app icon at the specified size.
    Using a design similar to Apple's News app - gradient blue background with checkmark/task symbol.
    """

    # Create base image with gradient
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Apple News-style gradient: from vibrant blue/teal to deeper blue
    # Gradient colors (top-left to bottom-right)
    gradient_colors = [
        (0, 180, 255),    # Bright cyan-blue (top-left)
        (0, 140, 230),    # Medium blue
        (0, 100, 200),    # Deeper blue (bottom-right)
    ]

    # Draw gradient background using diagonal lines
    for i in range(size):
        # Interpolate between gradient colors
        t = i / size
        if t < 0.5:
            c1 = gradient_colors[0]
            c2 = gradient_colors[1]
            local_t = t * 2
        else:
            c1 = gradient_colors[1]
            c2 = gradient_colors[2]
            local_t = (t - 0.5) * 2

        r = int(c1[0] + (c2[0] - c1[0]) * local_t)
        g = int(c1[1] + (c2[1] - c1[1]) * local_t)
        b = int(c1[2] + (c2[2] - c1[2]) * local_t)

        draw.line([(0, i), (size, i)], fill=(r, g, b, 255))

    # Apply rounded corners mask
    corner_radius = int(size * 0.2237)  # Apple's standard corner radius ratio
    mask = create_rounded_rectangle(size, size, corner_radius)

    # Create final image with rounded corners
    result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    result.paste(img, (0, 0))

    # Create and apply mask
    result = Image.alpha_composite(
        Image.new('RGBA', (size, size), (255, 255, 255, 255)),
        result
    )

    # Apply rounded corner mask using composite
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(result, (0, 0), mask)

    # Draw the icon symbol - a stylized checkmark/task list symbol
    # Similar to News app's folded newspaper, but with a checkmark
    draw = ImageDraw.Draw(output)

    # Symbol area is roughly center 55% of icon
    symbol_size = int(size * 0.55)
    symbol_offset = (size - symbol_size) // 2

    # Draw a rounded rectangle container for the task symbol
    container_padding = int(symbol_size * 0.15)
    container_radius = int(symbol_size * 0.12)

    container_left = symbol_offset + container_padding
    container_top = symbol_offset + container_padding
    container_right = symbol_offset + symbol_size - container_padding
    container_bottom = symbol_offset + symbol_size - container_padding

    # Semi-transparent white container
    container_color = (255, 255, 255, 180)
    draw.rounded_rectangle(
        [container_left, container_top, container_right, container_bottom],
        container_radius,
        fill=container_color
    )

    # Draw a stylized checkmark in the center
    # Checkmark proportions
    check_start_x = int(size * 0.30)
    check_start_y = int(size * 0.50)
    check_mid_x = int(size * 0.45)
    check_mid_y = int(size * 0.65)
    check_end_x = int(size * 0.70)
    check_end_y = int(size * 0.35)

    stroke_width = max(int(size * 0.08), 3)

    # Draw checkmark with rounded caps
    check_color = (255, 255, 255, 255)

    # First segment (short stroke)
    draw.line(
        [(check_start_x, check_start_y), (check_mid_x, check_mid_y)],
        fill=check_color,
        width=stroke_width
    )

    # Second segment (long stroke)
    draw.line(
        [(check_mid_x, check_mid_y), (check_end_x, check_end_y)],
        fill=check_color,
        width=stroke_width
    )

    # Add subtle highlight/shine effect at top
    highlight_y = int(size * 0.08)
    highlight_height = int(size * 0.15)
    highlight_color = (255, 255, 255, 40)
    draw.rectangle(
        [int(size * 0.2), highlight_y, int(size * 0.8), highlight_y + highlight_height],
        fill=highlight_color
    )

    # Save the icon
    output.save(output_path, 'PNG')
    print(f"Created: {output_path} ({size}x{size})")

def create_icon_set():
    """Create all required icon sizes for macOS app."""

    # Icon sizes needed for macOS app icons
    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]

    # Output directory
    output_dir = "/Users/thotas/Development/myRTM/myRTM/Resources/Assets.xcassets/AppIcon.appiconset"

    # Ensure directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Create icons
    for size, filename in sizes:
        output_path = os.path.join(output_dir, filename)
        create_app_icon(size, output_path)

    # Update Contents.json
    contents_json = '''{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}'''

    with open(os.path.join(output_dir, "Contents.json"), 'w') as f:
        f.write(contents_json)

    print(f"\\nUpdated Contents.json in {output_dir}")
    print("App icon set created successfully!")

if __name__ == "__main__":
    create_icon_set()

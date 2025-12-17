#!/usr/bin/env python3
"""
Simple script to create basic app icons for PWA
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size, filename):
    # Create a new image with a gradient background
    img = Image.new('RGB', (size, size), color='#667eea')
    draw = ImageDraw.Draw(img)
    
    # Draw a simple wallet icon representation
    # Background circle
    draw.ellipse([size//8, size//8, size-size//8, size-size//8], fill='#4c63d2', outline='white', width=3)
    
    # Draw a simple "$" symbol
    font_size = size // 3
    try:
        # Try to use a system font
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            font = ImageFont.load_default()
    
    # Draw the $ symbol
    text = "$"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    draw.text((x, y), text, fill='white', font=font)
    
    # Save the image
    img.save(filename, 'PNG')
    print(f"Created {filename} ({size}x{size})")

# Create icons directory
os.makedirs('static/icons', exist_ok=True)

# Create various icon sizes
sizes = [72, 96, 128, 144, 152, 192, 384, 512]

for size in sizes:
    filename = f'static/icons/icon-{size}x{size}.png'
    create_icon(size, filename)

print("All icons created successfully!")
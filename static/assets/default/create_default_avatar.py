from PIL import Image, ImageDraw, ImageFont
import os

# Create a new image with a white background
size = (200, 200)
bg_color = "#667EEA"  # A nice purple color that matches your theme
image = Image.new('RGB', size, bg_color)
draw = ImageDraw.Draw(image)

# Draw a circle for the avatar background
circle_size = (0, 0, 200, 200)
draw.ellipse(circle_size, fill=bg_color)

# Add user icon or initials (you can modify this part)
draw.ellipse((80, 50, 120, 90), fill='white')  # Head
draw.rectangle((60, 100, 140, 150), fill='white')  # Body

# Save the image
image.save('default-avatar.png')

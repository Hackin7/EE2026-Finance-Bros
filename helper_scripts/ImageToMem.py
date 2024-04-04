from PIL import Image
import os

# Load the image
img = Image.open("image.png")

# Resize the image if it's larger than 96x64 pixels
if img.size[0] > 96 or img.size[1] > 64:
    img = img.resize((96, 64), Image.LANCZOS)

# Convert the image to RGB if it's not
if img.mode != 'RGB':
    img = img.convert('RGB')

# Prepare the .mem file content
mem_content = ""
address = 0  # Start address

# Loop over each pixel and generate the corresponding hexadecimal color value
for y in range(img.size[1]):
    mem_content += f"@{address:04x} "
    for x in range(img.size[0]):
        pixel = img.getpixel((x, y))
        # Assuming 5 bits for red, 6 bits for green, and 5 bits for blue
        red = pixel[0] >> 3
        green = pixel[1] >> 2
        blue = pixel[2] >> 3
        # Format as a 16-bit hexadecimal value (RGB565)
        hex_color = f"{(red << 11) | (green << 5) | blue:04x}"
        mem_content += hex_color + " "
        address += 1  # Increment address for each pixel
    mem_content = mem_content.strip() + "\n"  # Remove trailing space and add newline

# Define the output filename
output_filename = "image_data.mem"
output_path = os.path.join(os.path.dirname(__file__), output_filename)

# Save the .mem file
with open(output_path, "w") as file:
    file.write(mem_content.strip())

print(f".mem file saved to: {output_path}")

from PIL import Image
import cv2
import os
import numpy as np

def process_image(image_path):
    img = Image.open(image_path)
    if img.size[0] > 96 or img.size[1] > 64:
        img = img.resize((96, 64), Image.LANCZOS)
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    mem_content, address = "", 0
    for y in range(img.size[1]):
        mem_content += f"@{address:04x} "
        for x in range(img.size[0]):
            pixel = img.getpixel((x, y))
            red, green, blue = pixel[0] >> 3, pixel[1] >> 2, pixel[2] >> 3
            hex_color = f"{(red << 11) | (green << 5) | blue:04x}"
            mem_content += hex_color + " "
            address += 1
        mem_content = mem_content.strip() + "\n"
    
    output_filename = os.path.basename(image_path).split('.')[0] + "_data.mem"
    output_path = os.path.join(os.path.dirname(__file__), output_filename)
    with open(output_path, "w") as file:
        file.write(mem_content.strip())
    print(f".mem file saved to: {output_path}")

def resize_cover(image, size=(96, 64)):
    img_aspect, target_aspect = image.shape[1] / float(image.shape[0]), size[0] / float(size[1])
    if img_aspect > target_aspect:
        scale = size[1] / float(image.shape[0])
        resized = cv2.resize(image, (int(image.shape[1] * scale + 0.5), size[1]), interpolation=cv2.INTER_AREA)
        crop_x = (resized.shape[1] - size[0]) // 2
        image = resized[:, crop_x:crop_x+size[0]]
    else:
        scale = size[0] / float(image.shape[1])
        resized = cv2.resize(image, (size[0], int(image.shape[0] * scale + 0.5)), interpolation=cv2.INTER_AREA)
        crop_y = (resized.shape[0] - size[1]) // 2
        image = resized[crop_y:crop_y+size[1], :]
    return image

def process_video(video_path):
    video, fps, output_folder = cv2.VideoCapture(video_path), 24, "frames_mem"
    if not video.isOpened():
        print("Error: Could not open video.")
        return
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    frame_index = 0
    while True:
        ret, frame = video.read()
        if not ret:
            break
        frame = resize_cover(frame)
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = Image.fromarray(frame)
        
        mem_content, address = "", 0
        for y in range(img.size[1]):
            mem_content += f"@{address:04x} "
            for x in range(img.size[0]):
                pixel = img.getpixel((x, y))
                red, green, blue = pixel[0] >> 3, pixel[1] >> 2, pixel[2] >> 3
                hex_color = f"{(red << 11) | (green << 5) | blue:04x}"
                mem_content += hex_color + " "
                address += 1
            mem_content = mem_content.strip() + "\n"
        
        output_filename = f"frame_{frame_index:04d}.mem"
        output_path = os.path.join(output_folder, output_filename)
        with open(output_path, "w") as file:
            file.write(mem_content.strip())
        print(f"Frame {frame_index} .mem file saved to: {output_path}")
        frame_index += 1
    
    video.release()
    print("Video processing complete.")

input_path = "image.png"  # Replace with the actual input path

if input_path.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp')):
    process_image(input_path)
elif input_path.lower().endswith('.mp4'):
    process_video(input_path)
else:
    print("Unsupported file type. Please provide a video (.mp4) or image file.")

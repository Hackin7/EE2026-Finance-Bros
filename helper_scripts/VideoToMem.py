from PIL import Image
import cv2
import os

def resize_cover(image, size=(96, 64)):
    img_aspect = image.shape[1] / float(image.shape[0])
    target_aspect = size[0] / float(size[1])
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

def process_frame(frame, frame_index, output_folder):
    frame = resize_cover(frame)
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    img = Image.fromarray(frame)
    mem_content = ""
    address = 0
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

# Load the video
video_path = "video.mp4"
video = cv2.VideoCapture(video_path)
if not video.isOpened():
    print("Error: Could not open video.")
    exit()

original_fps = video.get(cv2.CAP_PROP_FPS)
target_fps = 5

# Calculate the frame skip rate
skip_rate = int(round(original_fps / target_fps))

# Create folder for MEM files
output_folder = "frames_mem"
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

frame_index, captured_frame_index = 0, 0
while True:
    ret, frame = video.read()
    if not ret:
        break
    if frame_index % skip_rate == 0:
        process_frame(frame, captured_frame_index, output_folder)
        captured_frame_index += 1
    frame_index += 1

video.release()
print("Video processing complete.")

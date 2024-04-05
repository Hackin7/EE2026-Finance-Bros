def generate_frame_loading_statements(num_frames):
    statements = ""
    for i in range(num_frames):
        statement = f"{i}: $readmemh(\"frame_{i:04d}.mem\", frame_memory);\n"
        statements += statement
    return statements

# Generate frame loading statements
num_frames = 75
frame_loading_statements = generate_frame_loading_statements(num_frames)

# Read the Verilog template file
with open("video_template.v", "r") as file:
    verilog_code = file.read()

# Replace the placeholder with the generated frame loading statements
verilog_code = verilog_code.replace("{{FRAME_LOADING_STATEMENTS}}", frame_loading_statements)

# Write the modified Verilog code to a new file
with open("video.v", "w") as file:
    file.write(verilog_code)
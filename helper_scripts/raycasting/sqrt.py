import math

def to_resp(val):
    output_val = int(val * (2**8))
    #if output_val < 0: # if got negative, something's wrong
    #    output_val = output_val + (2**16)
    byte_rep = output_val.to_bytes(2)
    return byte_rep

def to_hex(bytes):
    return bytes.hex() # https://stackoverflow.com/questions/6624453/whats-the-correct-way-to-convert-bytes-to-a-hex-string-in-python-3

def to_byte(val):
    return int(val * (2**8)).to_bytes(2)


f = open("sqrt.mem", "w")

for i in range(2**16): #12
    value = int(i) / 2 ** 8

    output_val = math.sqrt(value)
    
    output = int(output_val * (2**8))
    #print(i, value, value2, output_val, output)
    #print(i, value, output_val, output, to_resp(output_val), to_hex(to_resp(output_val)))
    f.write(to_hex(to_resp(output_val)) + "\n")
    #f.write(to_hex(i.to_bytes(2)) + "\n")

f.close()

#print(math.sin(math.radians(90)))
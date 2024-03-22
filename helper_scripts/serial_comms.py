import serial
ser = serial.Serial('COM17')  # open serial port
ser.baudrate = 9600
print(ser.name)         # check which port was really used

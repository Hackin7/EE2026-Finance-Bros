import serial
ser = serial.Serial('COM17')  # open serial port
ser.baudrate = 9600
print(ser.name)         # check which port was really used


def read():
	return ser.read(8)

def write(data):
	print(f"send: {str(data.encode())}, len: {len(data)}")
	ser.write(data.encode())

def send_with_response(callback, flush=True):
	if flush == True:
		print("flush")
		ser.flushInput()
	callback()	
	print(packet_read())

### Master Read from slave

type_mapping = {
	1: "BUY", 
	2: "BUY", 
	3: "OK", 
	4: "FAIL", 
	5: "GET_ACCOUNT_BALANCE",
	6: "GET_ACCOUNT_STOCKS",
	7: "RETURN_ACCOUNT_BALANCE",
	8: "RETURN_ACCOUNT_STOCKS",
}
def packet_parse(packet):
	format = f"""Packet Received
    packet = {str(packet)}
    type = {packet[1]} -> {type_mapping.get(packet[1])}
    account_id = {packet[2]}
    stock_id = {packet[3]} 
    qty = {packet[4]} 
    price = {packet[5]}
    extra = {packet[6]}

    account_salary = {str(packet[2:6])} -> {int.from_bytes(packet[2:6], "big")}
"""
	return format
	

def packet_read():
	return (packet_parse(read()))

### Master Send to slave
def buy(account_id, stock_id, qty, price):
	write("["+chr(1)+chr(account_id)+chr(stock_id)+chr(qty)+chr(price)+"A]")
	
def sell(account_id, stock_id, qty, price):
	write("["+chr(2)+chr(account_id)+chr(stock_id)+chr(qty)+chr(price)+"A]")
	
def ok(account_id=0, stock_id=0, qty=0, price=0):
	write("["+chr(3)+chr(account_id)+chr(stock_id)+chr(qty)+chr(price)+"A]")
	
def fail(account_id=0, stock_id=0, qty=0, price=0):
	write("["+chr(4)+chr(account_id)+chr(stock_id)+chr(qty)+chr(price)+"A]")

def get_account_balance(account_id, stock_id=0, qty=0, price=0):
	write("["+chr(5)+chr(account_id)+chr(stock_id)+chr(qty)+chr(price)+"A]")

'''
from serial_comms import *
'''
ser.flushInput()
#get_account_balance(0)
buy(0, 0, 1, 15)
print(packet_read())
#print(packet_read())
#send_with_response(lambda: buy(0, 0, 1, 15))
#send_with_response(lambda: get_account_balance(0))
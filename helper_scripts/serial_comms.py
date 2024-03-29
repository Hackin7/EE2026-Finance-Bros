import serial
#port = "COM17"
port = "COM19"
ser = serial.Serial(port)  # open serial port
ser.baudrate = 9600
print(ser.name)         # check which port was really used


def read():
	ser.flushInput()
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
    stock_id / stock1 = {packet[3]} 
    qty / stock2 = {packet[4]} 
    price / stock3 = {packet[5]}
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

def get_account_stock(account_id, stock_id=0, qty=0, price=0):
	write("["+chr(6)+chr(account_id)+chr(stock_id)+chr(qty)+chr(price)+"A]")

def return_account_balance(balance=0):
	#print(balance.to_bytes(2, 'big'))
	write("["+chr(7)+(balance.to_bytes(4, 'big')).decode()+"A]")
	
def return_account_stock(stock1=0, stock2=0, stock3=0):
	write("["+chr(8)+chr(stock1)+chr(stock2)+chr(stock3)+chr(0)+"A]")

'''
from serial_comms import *
'''
#get_account_balance(0)
#print(packet_read())

def test_master():
    send_with_response(lambda: buy(0, 0, 1, 15))
    send_with_response(lambda: get_account_balance(0))
    send_with_response(lambda: get_account_stock(0))

### Testing Trading System
def approve_buy():
    print(packet_read())
    print(packet_read())
    ok()


### Testing retrieval of balance
def return_account():
    print(packet_read())
    send_with_response(lambda: return_account_balance(99))
    return_account_stock(100, 10, 1)

test_master()
	
#approve_buy()	
#ok()
#return_account()
#print(packet_read())

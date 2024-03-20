'''
Basic Prototype Functionality
Ultimate Goal

1. Buy - Fix the price, see if you can buy
2. Adjust Market Price on Master Board
3. slave board pings until it can sell

Simple - Market Price Adjust from 
'''

from enum import Enum

### Communication ###############################################################
class PacketCode(Enum):
    BUY = 1
    SELL = 2
    RESP_OK = 3
    RESP_FAIL = 4


class Packet:
    def __init__(self, account_id=None, stock_id=None, price=None, qty=None, mode=None):
        self.type = mode
        self.account_id = account_id
        self.stock_id = stock_id
        self.price = price
        self.qty = qty
        pass
    def __str__(self):
        return f"Packet(type={self.type}, account={self.account_id},stock_id={self.stock_id}, price={self.price}, qty={self.qty})"

class Communicator: # Simulate Serial Module
    def __init__(self):
        self.buffer = None

###################################################################

class Account:
    def __init__(self, balance):
        self.balance = balance

class Stock:
    def __init__(self, price, qty):
        self.price = price
        self.qty = qty


### Slave Code #################################################

class Slave:
    def __init__(self, communicator):
        self.communicator = communicator 
        self.account_id = 0
        self.trading_buffer = []

    ### Trading Logic #########################################
    def add_to_buffer(self, data):
        self.trading_buffer.push(data) 

    def trade_buffer(self):
        self.trade_buffer_1(data[0], data[1], data[2], data[3])

    # Send Packet
    def trade_buffer_1(self, stock_id, price, qty, mode):
        packet = Packet(self.account_id, stock_id, price, qty, "BUY") 
        self.communicator.buffer = packet 
    
    def trade_buffer_2(self):
        while self.communicator.buffer == None:
            pass
        packet = self.communicator.buffer
        if packet.type == "RESP_FAIL": #fail: # trade fail - keep trading
            pass # keep trading
            return
        self.communicator.buffer = None

### Master Code #################################################

class Master:
    def __init__(self, communicator):
        self.communicator = communicator 
        self.accounts = [Account(100), Account(100)]
        self.stocks = [Stock(1,1), Stock(1,1), Stock(1,1)] # total threshold

    ### Approval Logic ##########################################
    def trade_approve(self):
        packet = self.communicator.buffer

        curr_account = self.accounts[packet.account_id]
        curr_stock = self.stocks[packet.stock_id]

        can_buy = (curr_account.balance > packet.price * packet.qty)
        price_match = packet.price == curr_stock.price

        if can_buy and price_match:
            # subtract
            curr_stock.qty -= packet.qty


        self.communicator.buffer = Packet(packet.account_id, packet.stock_id, packet.price, packet.qty, PacketCode.RESP_OK) # Stuff


c = Communicator()
s = Slave(c)
m = Master(c)

s.trade_buffer_1(0, 1, 1, "BUY")
print(c.buffer)
m.trade_approve()
print(c.buffer)
s.trade_buffer_2()
print(c.buffer)

'''
always @ (*) begin
    xpos ypos
    oled_pixel_data = image(xpos, ypos) | image2(xpos, ypos) | image3(xpos, ypos)
end
'''
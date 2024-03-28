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
    RESP_OK_BUY = 3
    RESP_OK_SELL = 3
    RESP_FAIL = 4

'''
price: 200 - 300 per share
qty:   5
'''

class Packet:
    def __init__(self, account_id=None, mode=None, stock_id=None, qty=None, price=None):
        self.type = mode
        self.account_id = account_id
        self.stock_id = stock_id
        self.qty = qty
        self.price = price
    def __str__(self):
        return f"Packet(type={self.type}, account={self.account_id},stock_id={self.stock_id}, qty={self.qty}, price={self.price})"

class Communicator: # Simulate Serial Module
    def __init__(self):
        self.buffer = None
    def print_buffer(self):
        print(f"Buffer: {self.buffer}")

###########################################################################################

class Account:
    def __init__(self, balance):
        self.balance = balance
        self.stocks  = [0, 0, 0] # 
    def __str__(self):
        return f"Account({self.balance}, {self.stocks})"

class Stock:
    def __init__(self, price, qty=0):
        self.price = price
        #self.qty = qty # redundant
    def __str__(self):
        return f"Stock({self.price})"

aapl = Stock(178)  # apple
baba = Stock(74)   # alibaba
goog = Stock(149)  # google

### Slave Code ###################################################################

class Slave:
    def __init__(self, communicator):
        self.communicator = communicator 
        self.account_id = 0
        self.trading_buffer = []

    def add_to_buffer(self, data):
        self.trading_buffer.append(data) 

    
    def print(self, data):
        print(f"Slave: {data}")
    ### FSM #############################################################
    # Send Packet
    def trade_1(self): # Start trading Module
        data = self.trading_buffer.pop()
        if data == None:
            return # Restart current state & poll
        self.trade_1_1(*data)

    def trade_1_1(self, mode, stock_id, qty, price):
        packet = Packet(account_id=self.account_id, mode=mode, stock_id=stock_id, qty=qty, price=price) 
        self.communicator.buffer = packet 
    
    def trade_2(self):
        if self.communicator.buffer == None:
            return
        packet = self.communicator.buffer
        if packet.type == PacketCode.RESP_OK: # Pass
            #self.trading_buffer.pop() # Remove that element
            self.print("DONE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        elif packet.type == PacketCode.RESP_FAIL:
            #self.trading_buffer.pop()
            self.print("FAIL !!! --- Need loop & buy again")
        # Loop to trading again
        #self.trading_buffer = []
        self.communicator.buffer = None

### Master Code #################################################

class Master:
    MOVEMENT_THRESHOLD = 1

    def __init__(self, communicator):
        self.communicator = communicator 
        self.accounts = [Account(10000), Account(10000)]
        self.stocks = [aapl, baba, goog]    # total threshold
        self.stocks_threshold = [0, 0, 0]   # 8 bit +- integers (larger means higher price)
        self.admin_fees = 0

    def __str__(self):
        return (f"Master(\n  {[str(i) for i in self.accounts]}, \n  {[ str(i) for i in self.stocks]}), \n  {[ i for i in self.stocks_threshold]}, \n  {self.admin_fees})")
    def print(self, data):
        print(f"Master: {data}")

    ### Market Movement Logic ###################################
    def market_movement(self):
        #self.print("movement")
        for i in range(3):
            #self.print(self.stocks_threshold[i])
            if self.stocks_threshold[i] <= -Master.MOVEMENT_THRESHOLD:
                self.print("Movement -1")
                self.stocks[i].price -= 1
                self.stocks_threshold[i] = 0
            elif self.stocks_threshold[i] >= Master.MOVEMENT_THRESHOLD:
                self.print("Movement +1")
                self.stocks[i].price += 1
                self.stocks_threshold[i] = 0

    ### Approval Logic ##########################################
    def trade_approve_buy(self, packet):
        curr_account = self.accounts[packet.account_id]
        curr_stock = self.stocks[packet.stock_id]

        amount_paid = curr_stock.price * packet.qty
        price_match = curr_stock.price <= packet.price
        can_buy = (curr_account.balance >= amount_paid)


        if can_buy and price_match: # Can buy
            #--- Math ---------------------------------------------------------------------
            curr_account.balance -= packet.price * packet.qty
            curr_account.stocks[packet.stock_id] += packet.qty
            self.admin_fees += (packet.price - curr_stock.price) * packet.qty
            #--- Comms --------------------------------------------------------------------
            self.communicator.buffer = Packet(packet.account_id, PacketCode.RESP_OK, 0, 0) 
            self.print("Bought !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")            
        else: 
            #--- Comms --------------------------------------------------------------------
            self.communicator.buffer = None # clear buffer
            self.print("Bought FAIL")
        
        #--- Movement -----------------------------------------------------------------
        if can_buy and packet.price < curr_stock.price:  # not as willing to buy -> increase demand -> increase price
            self.stocks_threshold[packet.stock_id] -= 1
        if can_buy and packet.price >= curr_stock.price:  # more willing to buy   -> decrease demand -> decrease price
            self.stocks_threshold[packet.stock_id] += 1
        self.market_movement()

    def trade_approve_sell(self, packet):
        curr_account = self.accounts[packet.account_id]
        curr_stock = self.stocks[packet.stock_id]

        can_sell = (curr_account.stocks[packet.stock_id] >= packet.qty)
        price_match = curr_stock.price >= packet.price

        if can_sell and price_match: # Can buy
            #--- Math ---------------------------------------------------------------------
            curr_account.balance += packet.price * packet.qty
            curr_account.stocks[packet.stock_id] -= packet.qty
            self.admin_fees += (curr_stock.price - packet.price) * packet.qty
            #--- Comms --------------------------------------------------------------------
            self.communicator.buffer = Packet(packet.account_id, PacketCode.RESP_OK, 0, 0) # Send information
            self.print("sell !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        else: 
            #--- Comms --------------------------------------------------------------------
            self.communicator.buffer = None # clear buffer
            self.print("Sell FAIL")
        
        #--- Movement -----------------------------------------------------------------
        if can_sell and packet.price > curr_stock.price:  # less willing to sell -> decrease supply -> increase price
            self.stocks_threshold[packet.stock_id] += 1
        if can_sell and packet.price <= curr_stock.price:  # more willing to sell -> increase supply -> decrease price
            #print(packet.price, curr_stock.price)
            self.stocks_threshold[packet.stock_id] -= 1
        self.market_movement()

    def trade_approve(self):
        packet = self.communicator.buffer
        if (packet.type == PacketCode.BUY): # Poll for correct Packet
            self.trade_approve_buy(packet)
        elif (packet.type == PacketCode.SELL): # Poll for correct Packet
            self.trade_approve_sell(packet)
            

        

c = Communicator()
s = Slave(c)
m = Master(c)

'''
# Buy 1
s.add_to_buffer((PacketCode.BUY, 1, 1, 74))
s.trade_1()
c.print_buffer()
m.trade_approve()
c.print_buffer()
s.trade_2()
c.print_buffer()
print(m)

# Sell 2
# trade_1_1(mode, stock_id, qty):
s.add_to_buffer((PacketCode.SELL, 1, 1, 74))
s.trade_1()
c.print_buffer()
m.trade_approve()
c.print_buffer()
s.trade_2()
c.print_buffer()
print(m)
'''

print("#"*160)
#######################################################
# Buy 1
s.add_to_buffer((PacketCode.BUY, 1, 2, 74))
s.trade_1()
c.print_buffer()
m.trade_approve()
c.print_buffer()
s.trade_2()
c.print_buffer()
print(m)

# Buy 1
s.add_to_buffer((PacketCode.BUY, 1, 2, 74)) #74, 76
s.trade_1()
c.print_buffer()
m.trade_approve()
c.print_buffer()
s.trade_2()
c.print_buffer()
print(m)

# Sell 3
# trade_1_1(mode, stock_id, qty):
print("########### SELL ##############")
s.add_to_buffer((PacketCode.SELL, 1, 2, 75))
s.trade_1()
c.print_buffer()
m.trade_approve()
c.print_buffer()
s.trade_2()
c.print_buffer()
print(m)

# Sell 3
# trade_1_1(mode, stock_id, qty):
s.add_to_buffer((PacketCode.SELL, 1, 2, 75))
s.trade_1()
c.print_buffer()
m.trade_approve()
c.print_buffer()
s.trade_2()
c.print_buffer()
print(m)

## Confirmination ###################################


'''
always @ (*) begin
    xpos ypos
    oled_pixel_data = image(xpos, ypos) | image2(xpos, ypos) | image3(xpos, ypos)
end
'''
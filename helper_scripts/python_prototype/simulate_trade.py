'''
Basic Prototype Functionality
Ultimate Goal

1. Buy and Sell



'''

class Packet:
    def __init__(self, account_id, stock_id, price, qty, mode):
        self.account_id = account_id
        self.stock_id = stock_id
        self.price = price
        self.qty = qty
        pass

class Communicator:
    def __init__(self):
        self.buffer = None

### Slave Code #################################################

class Slave:
    def __init__(self, commmunicator):
        self.communicator = communicator 

    ### Trading Logic #########################################
    def trade_buffer_1(self, stock_id, price, qty, mode):
        packet = Packet(account_id, stock_id, price, qty, mode) 
        self.communicator.buffer = packet 
    def trade_buffer_2(self):
        while self.communicator.buffer == None:
            pass
        if fail: # trade fail - keep trading
            pass # keep trading

### Master Code #################################################

class Master:
    def __init__(self, commmunicator):
        self.communicator = communicator 
        self.accounts = []
        self.stocks = []

    ### Approval Logic ##########################################
    def trade_buffer(self):
        packet = self.communicator.buffer

        curr_account = self.accounts[packet.account_id]
        curr_stock = self.stocks[packet.stock_id]

        can_buy = (curr_account.balance > packet.price * packet.qty)
        price_match = packet.price == curr_stock.price

        if can_buy and price_match:
            # subtract
            curr_stock.qty -= packet.qty


        self.communicator.buffer = None # Stuff






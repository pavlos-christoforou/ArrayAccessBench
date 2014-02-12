import time
NUM_RECORDS = 50* 1000 *100

class PyMemTrade():
    def __init__(self, tradeId, clientId, venueId, instrumentCode, price, quantity, side):
        self.tradeId = tradeId
        self.clientId = clientId
        self.venueId = venueId
        self.instrumentCode = instrumentCode
        self.price = price
        self.quantity = quantity
        self.side = side

def initTrades(trades):
	for i in range(0, NUM_RECORDS):
		aside = ''
		if (i % 2 == 0):
			aside = 'B'
		else:
			aside = 'S'
		trades[i] = PyMemTrade(i,1,123,321,i,i,aside)

def perfRun(runNum, trades):
	start = time.time() * 1000
	initTrades(trades)
	buyCost = 0
	sellCost = 0
	for i in range(0, NUM_RECORDS):
		trade = trades[i]
		if (trade.side == 'B'):
                	buyCost += trade.price * trade.quantity
		else:
                	sellCost += trade.price * trade.quantity      
 	
	end = time.time() * 1000
	duration = end - start
	print(runNum, " - duration ", duration, "ms\n")
	print("buyCost = ", buyCost, " sellCost = ", sellCost, "\n")

if __name__ == '__main__':
	trades = [PyMemTrade(0,0,0,0,0,0,'0') for i in range(NUM_RECORDS)]
	for i in range (0, 5):
		perfRun(i, trades)

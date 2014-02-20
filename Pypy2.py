import time
NUM_RECORDS = 50* 1000 * 444

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
	for i in xrange(0, NUM_RECORDS):
		trades[i].tradeId = i
		trades[i].clientId = 1
		trades[i].venueId = 123
		trades[i].instrumentCode = 321
		trades[i].price = i
		trades[i].quantity = i
		if (i % 2 == 0):
			trades[i].side = 'B'
		else:
			trades[i].side = 'S'

def perfRun(runNum, trades):
	start = time.time() * 1000
	initTrades(trades)
	buyCost = 0
	sellCost = 0
	for i in xrange(0, NUM_RECORDS):
		if (trades[i].side == 'B'):
                	buyCost += trades[i].price * trades[i].quantity
		else:
                	sellCost += trades[i].price * trades[i].quantity      
 	
	end = time.time() * 1000
	duration = end - start
	print(str(runNum) + " - duration " + str(int(duration)) + "ms\n")
	#print(runNum, " - duration ", duration, "ms\n") 		This prints weird on Pypy
	print("buyCost = ", buyCost, " sellCost = ", sellCost, "\n")

if __name__ == '__main__':
	trades = [PyMemTrade(0,0,0,0,0,0,'0') for i in range(NUM_RECORDS)]
	for i in range (0, 5):
		perfRun(i, trades)

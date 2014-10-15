import time
NUM_RECORDS = 50 * 1000 * 444

class PyMemTrade(object):
    __slots__ = ('tradeId', 'clientId', 'venueId', 'instrumentCode','price','quantity','side')
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
        t = trades[i]
        t.tradeId = i
        t.clientId = 1
        t.venueId = 123
        t.instrumentCode = 321
        t.price = i
        t.quantity = i

        if (i % 2 == 0):
            t.side = 'B'
        else:
            t.side = 'S'



def perfRun(runNum, trades):
    start = time.time() * 1000
    initTrades(trades)
    buyCost = 0
    sellCost = 0
    for i in xrange(0, NUM_RECORDS):
        t = trades[i]
        
        if (t.side == 'B'):
            buyCost += t.price * t.quantity
        else:
            sellCost += t.price * t.quantity      
            
    end = time.time() * 1000
    duration = end - start
    print(str(runNum) + " - duration " + str(int(duration)) + "ms\n")
    #print(runNum, " - duration ", duration, "ms\n") 		This prints weird on Pypy
    print("buyCost = ", buyCost, " sellCost = ", sellCost, "\n")

if __name__ == '__main__':
	trades = [PyMemTrade(0,0,0,0,0,0,'0') for i in range(NUM_RECORDS)]
	for i in range (0, 5):
		perfRun(i, trades)

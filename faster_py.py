import time

def initTrades(trades):
    for i, trade in enumerate(trades):
        if i % 2:
            aside = 'S'
        else:
            aside = 'B'
        trade["tradeId"] = i
        trade["clientId"] = 1
        trade["venueId"] = 123
        trade["instrumentCode"] = 321
        trade["price"] = i
        trade["quantity"] = i
        trade["side"] = aside

def perfRun(runNum, trades):
    start = time.time() * 1000
    initTrades(trades)
    buyCost, sellCost = 0, 0
    for trade in trades:
        if trade["side"] == 'B':
            buyCost += trade["price"] * trade["quantity"]
        else:
            sellCost += trade["price"] * trade["quantity"]
    print (runNum, "- duration" , ((time.time() * 1000) - start), "ms")
    print ("buyCost = ", buyCost, " sellCost = ", sellCost)

if __name__ == '__main__':
    NUM_RECORDS = 50 * 1000 * 10
    PyMemTrade = {"tradeId": 0, "clientId": 0, "venueId": 0, 
                  "instrumentCode": 0, "price": 0, "quantity": 0, "side": "0"}
    trades = [PyMemTrade.copy() for i in range(NUM_RECORDS)]
    for i in range (0, 5):
        perfRun(i, trades)

NUM_RECORDS = 50 * 1000 * 444

class RubyMemTrade
   attr_reader :tId, :cId, :vCode, :iCode, :price, :quantity, :side

   def initialize(tId, cId, vCode, iCode, price, quantity, side)
      @tradeId=tId
      @clientId=cId
      @venueCode=vCode
      @instrumentCode=iCode
      @price=price
      @quantity=quantity
      @side=side
   end
   def fromI(i)
      @tradeId=i
      @clientId=1
      @venueCode=123
      @instrumentCode=321
      @price=i
      @quantity=i
      @side= if (i % 2 == 0) then 'B' else 'S' end
   end
end

$trades = Array.new(NUM_RECORDS)

def prepareTrades()
	for i in 0..NUM_RECORDS
		$trades[i]=(RubyMemTrade.new(0,0,0,0,0,0,'a'))
	end
end

def initTrades()
	for i in 0..NUM_RECORDS
		$trades[i].fromI(i)
	end
end

def perfRun(runNum)
	startT = Time.now()
	initTrades()
	buyCost = 0
	sellCost = 0
	for i in 0..NUM_RECORDS
		if $trades[i].side == 'B'
			buyCost += $trades[i].price * $trades[i].quantity
		else
			sellCost += $trades[i].price * $trades[i].quantity
		end
	end
	endT = Time.now()
	duration = (endT - startT) * 1000
	printf("%d - duration %d ms\n", runNum, duration)
	printf("buyCost = %d sellCost = %d\n", buyCost, sellCost)
end

if __FILE__ == $0
	prepareTrades()
	for i in 0..5
		perfRun(i)
	end
end


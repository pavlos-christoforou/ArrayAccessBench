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
      @clientId=1
      @venueCode=123
      @instrumentCode=321
      @price = @quantity = @tradeId = i
      @side = i.even? ? :B : :S 
   end
end

def prepareTrades(trades)
  NUM_RECORDS.times { |i| trades << RubyMemTrade.new(0,0,0,0,0,0, :a) }
end

def initTrades(trades)
  NUM_RECORDS.times { |i| trades[i].fromI(i) }
end

def perfRun(trades, runNum)
  GC.disable
  startT = Time.now()
  initTrades(trades)
  buyCost = sellCost = 0
  trades.each do | trade | 
    if trade.side == :B 
      buyCost += trade.price * trade.quantity
    else
      sellCost += trade.price * trade.quantity
    end
  end

  endT = Time.now()
  duration = (endT - startT) * 1000
  printf("%d - duration %d ms\n", runNum, duration)
  printf("buyCost = %d sellCost = %d\n", buyCost, sellCost)
  GC.enable
  GC.start
end

if __FILE__ == $0
  trades = []
  prepareTrades(trades)
for i in 0..5
    perfRun(trades, i)
  end
end


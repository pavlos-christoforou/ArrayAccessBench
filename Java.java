public class Java
{
    private static final int NUM_RECORDS = 50 * 1000 * 444;
 
    private static JavaMemoryTrade[] trades;

 
    public static void main(final String[] args)
    {
	
        for (int i = 0; i < 5; i++)
        {
            System.gc();
            perfRun(i);
        }
    }
 
    private static void perfRun(final int runNum)
    {
        long start = System.currentTimeMillis();
 
        init();
        long buyCost = 0;
        long sellCost = 0;
 
        for (int i = 0; i < NUM_RECORDS; i++)
        {
            final JavaMemoryTrade trade = get(i);
 
            if (trade.getSide() == 'B')
            {
                buyCost += (trade.getPrice() * trade.getQuantity());
            }
            else
            {
                sellCost += (trade.getPrice() * trade.getQuantity());
            }
        }
 
        long duration = System.currentTimeMillis() - start;
        System.out.println(runNum + " - duration " + duration + "ms");
        System.out.println("buyCost = " + buyCost + " sellCost = " + sellCost);
    }
 
    private static JavaMemoryTrade get(final int index)
    {
        return trades[index];
    }
 
    public static void init()
    {
	trades = new JavaMemoryTrade[NUM_RECORDS];
        for (int i = 0; i < NUM_RECORDS; i++)
        {
            JavaMemoryTrade trade = new JavaMemoryTrade();
            trades[i] = trade;
 
            trade.setTradeId(i);
            trade.setClientId(1);
            trade.setVenueCode(123);
            trade.setInstrumentCode(321);
 
            trade.setPrice(i);
            trade.setQuantity(i);
 
            trade.setSide((i & 1) == 0 ? 'B' : 'S');
        }
    }

 
    private static class JavaMemoryTrade
    {
        private long tradeId;
        private long clientId;
        private int venueCode;
        private int instrumentCode;
        private long price;
        private long quantity;
        private char side;
 
        public long getTradeId()
        {
            return tradeId;
        }
 
        public void setTradeId(final long tradeId)
        {
            this.tradeId = tradeId;
        }
 
        public long getClientId()
        {
            return clientId;
        }
 
        public void setClientId(final long clientId)
        {
            this.clientId = clientId;
        }
 
        public int getVenueCode()
        {
            return venueCode;
        }
 
        public void setVenueCode(final int venueCode)
        {
            this.venueCode = venueCode;
        }
 
        public int getInstrumentCode()
        {
            return instrumentCode;
        }
 
        public void setInstrumentCode(final int instrumentCode)
        {
            this.instrumentCode = instrumentCode;
        }
 
        public long getPrice()
        {
            return price;
        }
 
        public void setPrice(final long price)
        {
            this.price = price;
        }
 
        public long getQuantity()
        {
            return quantity;
        }
 
        public void setQuantity(final long quantity)
        {
            this.quantity = quantity;
        }
 
        public char getSide()
        {
            return side;
        }
 
        public void setSide(final char side)
        {
            this.side = side;
        }
    }
}

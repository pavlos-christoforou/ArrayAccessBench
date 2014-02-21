import java.math.BigInteger;

public class Java3
{
    private static final int NUM_RECORDS = 50 * 1000 * 444;
 
    private static JavaMemoryTrade[] trades;

 
    public static void main(final String[] args)
    {
	trades = new JavaMemoryTrade[NUM_RECORDS];
        for (int i = 0; i < NUM_RECORDS; i++)
        {
            trades[i]= new JavaMemoryTrade();
	}

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
        BigInteger buyCost = BigInteger.valueOf(0);
        BigInteger sellCost = BigInteger.valueOf(0);
 
        for (int i = 0; i < NUM_RECORDS; i++)
        {
            if (trades[i].getSide() == 'B')
            {
                buyCost = buyCost.add(BigInteger.valueOf(trades[i].getPrice() * trades[i].getQuantity() ) );
            }
            else
            {
                sellCost = sellCost.add(BigInteger.valueOf(trades[i].getPrice() * trades[i].getQuantity() ) );
            }
        }
 
        long duration = System.currentTimeMillis() - start;
        System.out.println(runNum + " - duration " + duration + "ms");
        System.out.println("buyCost = " + buyCost + " sellCost = " + sellCost);
    }
 
    public static void init()
    {
        for (int i = 0; i < NUM_RECORDS; i++)
        { 
            trades[i].setTradeId(i);
            trades[i].setClientId(1);
            trades[i].setVenueCode(123);
            trades[i].setInstrumentCode(321);
 
            trades[i].setPrice(i);
            trades[i].setQuantity(i);
 
            trades[i].setSide((i & 1) == 0 ? 'B' : 'S');
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

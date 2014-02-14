using System;

public class MemtestS{
    private const int NUM_RECORDS = 50 * 1000 * 444;
 
    private static CSMemoryTrade[] trades;
 
    static void Main(){
        for (int i = 0; i < 5; i++){
            perfRun(i);
        }
    }
 
    private static void perfRun(int runNum){
	long milliseconds = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
        long start = milliseconds;
 
        init();
        long buyCost = 0;
        long sellCost = 0;
 
        for (int i = 0; i < NUM_RECORDS; i++){
 	    CSMemoryTrade trade = getATrade(i);
 
            if (trade.getSide() == 'B'){
                buyCost += (trade.getPrice() * trade.getQuantity());
            }
            else{
                sellCost += (trade.getPrice() * trade.getQuantity());
            }
        }
 	
	milliseconds = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
	long end = milliseconds;
        long duration = end - start;
        System.Console.Write(runNum + " - duration " + duration + "ms\n");
        System.Console.Write("buyCost = " + buyCost + " sellCost = " + sellCost + "\n");
    }
 
    private static CSMemoryTrade getATrade(int index){
        return trades[index];
    }
 
    public static void init()
    {
        trades = new CSMemoryTrade[NUM_RECORDS]; 
        for (int i = 0; i < NUM_RECORDS; i++){
            CSMemoryTrade trade = new CSMemoryTrade();
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
 
 
    private sealed class CSMemoryTrade
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
 
        public void setTradeId(long tradeId)
        {
            this.tradeId = tradeId;
        }
 
        public long getClientId()
        {
            return clientId;
        }
 
        public void setClientId(long clientId)
        {
            this.clientId = clientId;
        }
 
        public int getVenueCode()
        {
            return venueCode;
        }
 
        public void setVenueCode(int venueCode)
        {
            this.venueCode = venueCode;
        }
 
        public int getInstrumentCode()
        {
            return instrumentCode;
        }
 
        public void setInstrumentCode(int instrumentCode)
        {
            this.instrumentCode = instrumentCode;
        }
 
        public long getPrice()
        {
            return price;
        }
 
        public void setPrice(long price)
        {
            this.price = price;
        }
 
        public long getQuantity()
        {
            return quantity;
        }
 
        public void setQuantity(long quantity)
        {
            this.quantity = quantity;
        }
 
        public char getSide()
        {
            return side;
        }
 
        public void setSide(char side)
        {
            this.side = side;
        }
    }
}

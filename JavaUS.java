import sun.misc.Unsafe;
 
import java.lang.reflect.Field;
 
public class JavaUS
{
    private static final Unsafe unsafe;
    static
    {
        try
        {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            unsafe = (Unsafe)field.get(null);
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
    }
 
    private static final int NUM_RECORDS = 50 * 1000 * 100;
 
    private static long address;
    private static final DirectMemoryTrade flyweight = new DirectMemoryTrade();
 
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
            final DirectMemoryTrade trade = get(i);
 
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
 
        destroy();
    }
 
    private static DirectMemoryTrade get(final int index)
    {
        final long offset = address + (index * DirectMemoryTrade.getObjectSize());
        flyweight.setObjectOffset(offset);
        return flyweight;
    }
 
    public static void init()
    {
        final long requiredHeap = NUM_RECORDS * DirectMemoryTrade.getObjectSize();
        address = unsafe.allocateMemory(requiredHeap);
 
        for (int i = 0; i < NUM_RECORDS; i++)
        {
            DirectMemoryTrade trade = get(i);
 
            trade.setTradeId(i);
            trade.setClientId(1);
            trade.setVenueCode(123);
            trade.setInstrumentCode(321);
 
            trade.setPrice(i);
            trade.setQuantity(i);
 
            trade.setSide((i & 1) == 0 ? 'B' : 'S');
        }
    }
 
    private static void destroy()
    {
        unsafe.freeMemory(address);
    }
  
    private static class DirectMemoryTrade
    {
        private static long offset = 0;
 
        private static final long tradeIdOffset = offset += 0;
        private static final long clientIdOffset = offset += 8;
        private static final long venueCodeOffset = offset += 8;
        private static final long instrumentCodeOffset = offset += 4;
        private static final long priceOffset = offset += 4;
        private static final long quantityOffset = offset += 8;
        private static final long sideOffset = offset += 8;
 
        private static final long objectSize = offset += 2;
 
        private long objectOffset;
 
        public static long getObjectSize()
        {
            return objectSize;
        }
 
        void setObjectOffset(final long objectOffset)
        {
            this.objectOffset = objectOffset;
        }
 
        public long getTradeId()
        {
            return unsafe.getLong(objectOffset + tradeIdOffset);
        }
 
        public void setTradeId(final long tradeId)
        {
            unsafe.putLong(objectOffset + tradeIdOffset, tradeId);
        }
 
        public long getClientId()
        {
            return unsafe.getLong(objectOffset + clientIdOffset);
        }
 
        public void setClientId(final long clientId)
        {
            unsafe.putLong(objectOffset + clientIdOffset, clientId);
        }
 
        public int getVenueCode()
        {
            return unsafe.getInt(objectOffset + venueCodeOffset);
        }
 
        public void setVenueCode(final int venueCode)
        {
            unsafe.putInt(objectOffset + venueCodeOffset, venueCode);
        }
 
        public int getInstrumentCode()
        {
            return unsafe.getInt(objectOffset + instrumentCodeOffset);
        }
 
        public void setInstrumentCode(final int instrumentCode)
        {
            unsafe.putInt(objectOffset + instrumentCodeOffset, instrumentCode);
        }
 
        public long getPrice()
        {
            return unsafe.getLong(objectOffset + priceOffset);
        }
 
        public void setPrice(final long price)
        {
            unsafe.putLong(objectOffset + priceOffset, price);
        }
 
        public long getQuantity()
        {
            return unsafe.getLong(objectOffset + quantityOffset);
        }
 
        public void setQuantity(final long quantity)
        {
            unsafe.putLong(objectOffset + quantityOffset, quantity);
        }
 
        public char getSide()
        {
            return unsafe.getChar(objectOffset + sideOffset);
        }
 
        public void setSide(final char side)
        {
            unsafe.putChar(objectOffset + sideOffset, side);
        }
    }
}

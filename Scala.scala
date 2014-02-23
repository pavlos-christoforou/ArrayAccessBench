
/*
Run with -J-Xmx2g option to increase heapsize
*/
class ScalaMemTrade(tId: Int, cId: Int, vCode: Int, iCode: Int, iPrice: Long, iQuantity: Long, sSide: Char) {

      var tradeId: Int =tId
      var clientId: Int =cId
      var venueCode: Int =vCode
      var instrumentCode: Int =iCode
      var price: Long =iPrice
      var quantity: Long =iQuantity
      var side: Char =sSide

   def fromI(i: Int) = {
      tradeId=i
      clientId=1
      venueCode=123
      instrumentCode=321
      price=i
      quantity=i
      side = if (i % 2 == 0) 'B' else 'S';
   }
}

object ScalaTrade {
  val NUM_RECORDS: Int =  50 * 1000 * 444;

  val trades: Array[ScalaMemTrade] = new Array[ScalaMemTrade](NUM_RECORDS);

  def prepareTrades() : Unit = {
    var i = 0
    while (i < NUM_RECORDS) { trades(i) = new ScalaMemTrade(0,0,0,0,0,0,'a'); i+=1 }
  }

  def initTrades() : Unit = {
    var i = 0
    while (i < NUM_RECORDS) { trades(i).fromI(i); i+=1 } 
  }

  def perfRun(runNum: Int): Unit = {
    val startT: Long = System.currentTimeMillis()
    var i = 0
    initTrades()
    var buyCost: BigInt = 0
    var sellCost: BigInt = 0
    while (i < NUM_RECORDS) {
      if (trades(i).side == 'B')
        buyCost += trades(i).price * trades(i).quantity 
      else 
        sellCost += trades(i).price * trades(i).quantity
      i += 1
    }
    val endT: Long = System.currentTimeMillis()
    val duration = (endT - startT) 
    printf("%d - duration %d ms\n", runNum, duration)
    printf("buyCost = %d sellCost = %d\n", buyCost, sellCost)
  }

  def main(args: Array[String]) {
    prepareTrades()
    System.gc()
    (0 to 5).map { i => System.gc(); printf("Run %d\n", i); perfRun(i) }
  }    
}

ScalaTrade.main(args)

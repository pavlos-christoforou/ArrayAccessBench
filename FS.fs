open System.Diagnostics

let NUM_RECORDS = 50L * 1000L * 444L

type FSMemTrade = { 
  TradeId : int64;
  ClientId : int64;
  VenueId : int32;
  InstrumentCode : int32;
  Price : int64;
  Quantity : int64;
  Side : char}

let initTrades (tradesArray : FSMemTrade array) =
    printfn "initiating trades"
    for i in 0 .. tradesArray.Length - 1 do
        let idx = int64 i
        tradesArray.[i] <- {
            TradeId = idx; 
            ClientId = idx; 
            VenueId = 123; 
            InstrumentCode = 321;
            Price = idx; 
            Quantity = idx; 
            Side = if (i % 2 = 0) then 'S' else 'B'
        }

let perfRun n trades =
  let sw = Stopwatch.StartNew()
  let mutable buyCost = 0L
  let mutable sellCost = 0L
  initTrades trades
  for trade in trades do
    if (trade.Side = 'B') then 
        buyCost <- trade.Price * trade.Quantity 
    else 
        sellCost <- trade.Price * trade.Quantity 
  let duration = sw.ElapsedMilliseconds
  sw.Stop()
  printfn "%d - duration %d ms" n duration
  printfn "buyCost = %O sellCost = %O" buyCost sellCost

let main =
  let array = Array.zeroCreate (int32 NUM_RECORDS)
  for i in 0 .. 5 do
    perfRun i array

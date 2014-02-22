let NUM_RECORDS = 50 * 1000 * 444

type FSMemTrade = { 
  mutable TradeId : int64;
  mutable ClientId : int64;
  mutable VenueId : int32;
  mutable InstrumentCode : int32;
  mutable Price : int64;
  mutable Quantity : int64;
  mutable Side : char}

let trades : FSMemTrade array = Array.zeroCreate NUM_RECORDS
let prepareArray = 
    for i in 0 .. (NUM_RECORDS - 1) do
      Array.set trades i {TradeId = (int64 0); ClientId = (int64 0); VenueId = (int32 0); InstrumentCode = (int32 0); Price = (int64 0); Quantity = (int64 0); Side = 'a'}

let initTrades() =
  for i in 0 .. (NUM_RECORDS - 1) do
    trades.[i].TradeId <- (int64 i)
    trades.[i].ClientId <- (int64 1)
    trades.[i].VenueId <- 123
    trades.[i].InstrumentCode <- 321
    trades.[i].Price <- (int64 i)
    trades.[i].Quantity <- (int64 i)
    trades.[i].Side <- if (i%2 = 0) then 'S' else 'B'

let perfRun n =
  let startT = System.DateTime.Now.Ticks / System.TimeSpan.TicksPerMillisecond
  let mutable buyCost = bigint(0)
  let mutable sellCost = bigint(0)
  let mutable toAdd = bigint(0)
  initTrades()
  for i in 0 .. (NUM_RECORDS - 1) do
    toAdd <- bigint(trades.[i].Price * trades.[i].Quantity)
    if (trades.[i].Side = 'B') then buyCost <- (buyCost + toAdd) else sellCost <- (sellCost + toAdd)
  let endT = System.DateTime.Now.Ticks / System.TimeSpan.TicksPerMillisecond
  let duration = endT - startT
  printfn "%d - duration %d ms" n duration
  printfn "buyCost = %A sellCost = %A" buyCost sellCost

let main =
  prepareArray
  for i in 0 .. 4 do
    perfRun i

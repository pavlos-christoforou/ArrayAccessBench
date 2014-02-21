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
  printfn "initiating trades"
  for i in 0 .. (NUM_RECORDS - 1) do
    let trade = {
      TradeId = (int64 i); 
      ClientId = (int64 1); 
      VenueId = (int32 123); 
      InstrumentCode = (int32 321);
      Price = (int64 i); 
      Quantity = (int64 i); 
      Side = if (i%2 = 0) then 'S' else 'B'}
    Array.set trades i trade

let perfRun n =
  let startT = System.DateTime.Now.Ticks / System.TimeSpan.TicksPerMillisecond
  let mutable buyCost = (int64 0)
  let mutable sellCost = (int64 0)
  initTrades()
  for i in 0 .. (NUM_RECORDS - 1) do
    if (trades.[i].Side = 'B') then buyCost <- trades.[i].Price * trades.[i].Quantity else sellCost <- trades.[i].Price * trades.[i].Quantity 
  let endT = System.DateTime.Now.Ticks / System.TimeSpan.TicksPerMillisecond
  let duration = endT - startT
  printfn "%d - duration %d ms" n duration
  printfn "buyCost = %O sellCost = %O" buyCost sellCost

let main =
  prepareArray
  for i in 0 .. 5 do
    perfRun i

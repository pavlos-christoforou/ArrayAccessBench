let NUM_RECORDS = 50 * 1000 * 444

[<Struct>]
type FSMemTrade =
    val mutable TradeId        : int64;
    val mutable ClientId       : int64;
    val mutable VenueId        : int32;
    val mutable InstrumentCode : int32;
    val mutable Price          : int64;
    val mutable Quantity       : int64;
    val mutable Side           : char

let trades =
    let theDefault = FSMemTrade ( Side = 'a' )
    Array.create NUM_RECORDS theDefault
    // In C# and F#, struct fields are initialized by default to the 'default' value for the field type;
    // this means you only need to set fields which need to be set to a non-default value.

let initTrades () =
    printfn "initiating trades"

    for i = 0 to NUM_RECORDS - 1 do
        let long_i = int64 i
        trades.[i].TradeId        <- long_i
        trades.[i].ClientId       <- 1L
        trades.[i].VenueId        <- 123
        trades.[i].InstrumentCode <- 321
        trades.[i].Price          <- long_i
        trades.[i].Quantity       <- long_i
        trades.[i].Side           <- if (i % 2 = 0) then 'S' else 'B'

let perfRun n =

    let watch = System.Diagnostics.Stopwatch.StartNew ()
    
    initTrades ()

    let mutable buyCost = 0L
    let mutable sellCost = 0L
    for i = 0 to NUM_RECORDS - 1 do
        let cost = trades.[i].Price * trades.[i].Quantity
        if trades.[i].Side = 'B'
            then buyCost  <- buyCost  + cost
            else sellCost <- sellCost + cost

    watch.Stop ()

    let duration = int watch.Elapsed.TotalMilliseconds
    printfn "%d - duration %d ms" n duration
    printfn "buyCost = %O sellCost = %O" buyCost sellCost

[<EntryPoint>]
let main args =
    for i = 0 to 4 do
        System.GC.Collect ()
        perfRun i

    0 // Exit code

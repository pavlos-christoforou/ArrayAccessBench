lobby _AddSlots: (| numRecords = 50 * 1000 * 10. n <- 0. r <- 0. buyCost <- 0. sellCost <- 0.|)
lobby _AddSlots: (| preparationList <- (1 & 2) asList removeAll|)
lobby _AddSlots: (| selfMemTrade <- (|parent* = traits clonable|) |).
selfMemTrade _AddSlots: (| tradeId <- 0. clientId <- 0. venueCode <- 0. instrumentCode <- 0. price <- 0. quantity <- 0. side <- 'a'|).
selfMemTrade _AddSlots: (| fromI: i = (tradeId: i. clientId: 1. venueCode: 123. instrumentCode: 321. price: i. quantity: i. side: (i even) ifTrue:  'B' False: 'S'.) |)
lobby _AddSlots: (| prepareTradesArray: num = ( n: num. [n > 0] whileTrue: [ n: n - 1. preparationList add: (selfMemTrade clone)] ) |)
prepareTradesArray: numRecords
lobby _AddSlots: (| trades <- preparationList asVector |)
lobby _AddSlots: (| initTrades: num = ( n: num. [n > 0] whileTrue: [ (trades at: n) fromI: n. n: n - 1]  ) |)
lobby _AddSlots: (| perfRun: i = ( buyCost: 0. sellCost: 0. [| :runNum. | 
	initTrades: (numRecords - 1). trades do: 
		[|:each| ((each side) == 'B') 
			ifTrue: [buyCost: (buyCost + ((each price) * (each quantity)))] 
			False: [sellCost: (sellCost + ((each price) * (each quantity)))]
		].
	] value: i. 'Run: ' print. i printLine. 'buyCost = ' print. buyCost print. ' sellCost = ' print. sellCost printLine. 'duration ' print)
	|)
lobby _AddSlots: (| doRuns: num = ( r: num. [r > 0] whileTrue: [ r: r - 1. perfRun: r] ) |)

[perfRun: 1] realTime. 
'ms' printLine.
[perfRun: 2] realTime. 
'ms' printLine.
[perfRun: 3] realTime. 
'ms' printLine.
[perfRun: 4] realTime. 
'ms' printLine.

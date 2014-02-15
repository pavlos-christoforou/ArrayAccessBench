Object subclass: #MemTester.
MemTester instanceVariableNames: 'numRecords trades'.

MemTester class extend [
	new [
		| n |
		n := super new.
                n init.
                ^n
	]
]

MemTester extend [
	init [
		numRecords := 50 * 1000 * 444.
		trades := (Array new: numRecords).
		1 to: numRecords do: [ :i | trades at: i put: (STMemoryTrade new). ].	
	]
	initTrades [
		1 to: numRecords do: [ :i | (trades at: i) fromI: i. ].
	]
	perfRun: i [
		|start buyCost sellCost |
		Transcript show: i asString; cr.
		start := Time primMillisecondClock.
		self initTrades.
		buyCost := 0.
		sellCost := 0.
	
		trades do: [:each | ((each side) == $B) 
			ifTrue: [buyCost := (buyCost + ((each price) * (each quantity)))] 
			ifFalse: [sellCost := (sellCost + ((each price) * (each quantity)))]
			].
		Transcript show: 'Run ', (i asString), ' had duration ', ((Time primMillisecondClock) - start) asString, 'ms'; cr.
	]
	run [
		0 to: 5 do: [:i | self perfRun: i.].
	]
]

Object subclass: #STMemoryTrade.
STMemoryTrade instanceVariableNames: 'tradeId clientId venueCode instrumentCode price quantity side'.

STMemoryTrade class extend [
	new [
		| n |
		n := super new.
                n init.
                ^n
	]
]

STMemoryTrade extend [
	init [           
		tradeId := 0.
		clientId := 0.
		venueCode := 0.
		instrumentCode := 0.
		price := 0.
		quantity := 0.
		side := $a
	]
	fromI: i [
		tradeId := i.
		clientId := 1.
		venueCode := 123.
		instrumentCode := 321.
		price := i. 
		quantity := i.
		side := (i even) ifTrue:  $B; ifFalse: $S.
	]
	side [
		^side
	]
	quantity [
		^quantity
	]
	price [
		^price
	]
]

MemTester new run. 

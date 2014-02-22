const NUM_RECORDS = 50 * 1000 * 444

type JuliaMemTrade
	tradeId::Int64 
	clientId::Int64 
	venueCode::Int32
	instrumentCode::Int32
	price::Int64
	quantity::Int64
	side::Char
end

function initTrades(trades)           
	@inbounds for i in 1:NUM_RECORDS
		trades[i].tradeId = i
		trades[i].clientId = 1
		trades[i].venueCode = int32(123)
		trades[i].instrumentCode = int32(321)

		trades[i].price = i
		trades[i].quantity = i

		if (i % 2) == 0 
			trades[i].side = 'B'
		else
			trades[i].side = 'S'
		end
	end
end

function perfRun(trades, runNum)
	startT = time()
	initTrades(trades)
    buyCost::BigInt = 0
	sellCost::BigInt = 0
       
	@inbounds for i in 1:NUM_RECORDS
		if trades[i].side == 'B'
			buyCost += trades[i].price * trades[i].quantity
		else
			sellCost += trades[i].price * trades[i].quantity
		end
	end
	endT = time()
	duration = endT - startT
	@printf "%d - duration %d ms\n" runNum (duration * 1000)
	println("buyCost = ", buyCost, " sellCost = ", sellCost)
end

function main()
        trades = Array(JuliaMemTrade,NUM_RECORDS)

        for i in 1:NUM_RECORDS
	        trades[i] = JuliaMemTrade(0,0,0,0,0,0,'a')
        end

        for i in 1:5
       	        perfRun(trades, i)
        end
end

main()

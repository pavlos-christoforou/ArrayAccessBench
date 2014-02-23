local NUM_RECORDS = 50 * 1000 * 444

local setmetatable = setmetatable

local trades = {}

local LuaMemTrade = {}
LuaMemTrade.__index = LuaMemTrade

function LuaMemTrade.create()
	local trade = {}
	setmetatable(trade,LuaMemTrade)
	trade.tradeId = 0
	trade.clientId = 0
	trade.venueCode = 0
	trade.instrumentCode = 0
	trade.price = 0
	trade.quantity = 0
	trade.side = 'a'
	return trade
end

function LuaMemTrade:withI(i)
	self.tradeId = i
	self.clientId = 1
	self.venueCode = 123
	self.instrumentCode = 321
	self.price = i
	self.quantity = i
	if i%2 == 0 then self.side = 'B' else self.side = 'S' end
end

for i = 1, NUM_RECORDS do
	trades[#trades+1] = LuaMemTrade.create()
end

local function initTrades()
	for i = 1, NUM_RECORDS do
		trades[i]:withI(i)
	end
end

local function perfRun(runNum)
	startT = os.clock()
	initTrades()

	local buyCost = 0
	local sellCost = 0

	for i = 1, NUM_RECORDS do
		if trades[i].side == 'B' 
			then buyCost = buyCost + trades[i].price * trades[i].quantity
			else sellCost = sellCost + trades[i].price * trades[i].quantity
		end
	end
	endT = os.clock()
	duration = (endT - startT) * 1000
	io.stdout:write(runNum .. " - duration " .. duration .. "ms\n")
	io.stdout:write("buyCost = " .. buyCost .. " sellCost = " .. sellCost .. "\n")
end

for i = 1, 5 do
	perfRun(i)
end

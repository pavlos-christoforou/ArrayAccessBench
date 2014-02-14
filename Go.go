package main

import (
	"fmt"
	"time"
)

const (
	NUM_RECORDS = 50 * 1000 * 444
)

var (
	trades [NUM_RECORDS]GoMemoryTrade
)

type GoMemoryTrade struct {
	TradeId        int64 
	ClientId       int64 
	VenueCode      int32
	InstrumentCode int32
	Price          int64
	Quantity       int64
	Side           byte
}

func main() {
	for i := 0; i < 5; i++ {
		perfRun(i)
	}
}

func perfRun(runNum int) {
	start := time.Now()
	initTrades()

	var buyCost int64
	var sellCost int64

	var i int64
	for ; i < NUM_RECORDS; i++ {
		trade := &(trades[i])
		if (*trade).Side == 'B' {
			buyCost += (*trade).Price * (*trade).Quantity
		} else {
			sellCost += (*trade).Price * (*trade).Quantity
		}
	}
	endT := time.Now()
	duration := endT.Sub(start).Nanoseconds() / 1000000
	fmt.Printf("%v - duration %v ms\n", runNum, duration)
	fmt.Printf("buyCost = %v sellCost = %v\n", buyCost, sellCost)
}

func initTrades() {
	var i int64
	for ; i < NUM_RECORDS; i++ {
		trade := &(trades[i])

		(*trade).TradeId = i
		(*trade).ClientId = 1
		(*trade).VenueCode = 123
		(*trade).InstrumentCode = 321

		(*trade).Price = i
		(*trade).Quantity = i

		if (i&1) == 0 {
			(*trade).Side = 'B'
		} else {
			(*trade).Side = 'S'
		}
	}
}

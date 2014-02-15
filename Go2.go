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
		if trades[i].Side == 'B' {
			buyCost += trades[i].Price * trades[i].Quantity
		} else {
			sellCost += trades[i].Price * trades[i].Quantity
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
		trades[i].TradeId = i
		trades[i].ClientId = 1
		trades[i].VenueCode = 123
		trades[i].InstrumentCode = 321

		trades[i].Price = i
		trades[i].Quantity = i

		if (i&1) == 0 {
			trades[i].Side = 'B'
		} else {
			trades[i].Side = 'S'
		}
	}
}

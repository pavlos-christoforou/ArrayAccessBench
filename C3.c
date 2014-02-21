#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <gmp.h> 
 
#define NUM_RECORDS (50 * 1000 * 444)
 
struct CMemoryTrade {
	long TradeId; long ClientId; int VenueCode; int InstrumentCode; long Price; long Quantity; char Side;
};
 
struct CMemoryTrade trades[NUM_RECORDS];
 
void initTrades() {
	for (long i = 0; i < NUM_RECORDS; i++) {
 
		trades[i].TradeId = i;
		trades[i].ClientId = 1;
		trades[i].VenueCode = 123;
		trades[i].InstrumentCode = 321;
 
		trades[i].Price = i;
		trades[i].Quantity = i;
 
		if ((i&1) == 0) {
			trades[i].Side = 'B';
		} else {
			trades[i].Side = 'S';
		}
	}
}
 
double getTime(){
	struct timespec spec;
	clock_gettime(CLOCK_REALTIME, &spec);	
	double s  = spec.tv_sec;
	double ms = spec.tv_nsec;
	return (s*1000 + ms / 1000000);
}
 
void perfRun(int runNum) {	
	double startT = getTime();
	initTrades();

	mpz_t buyCost;
	mpz_init(buyCost);
	mpz_t sellCost;
	mpz_init(sellCost);

	mpz_t toAdd;
	mpz_init(toAdd);

	for (long i = 0; i < NUM_RECORDS; i++) {
		mpz_set_si(toAdd, trades[i].Price * trades[i].Quantity);
		if (trades[i].Side == 'B') {
			mpz_add(buyCost, buyCost, toAdd);
		} else {
			mpz_add(sellCost, sellCost, toAdd);
		}
	}
	double endT = getTime();
	double duration =  endT - startT;
	printf("%d - duration %d ms\n", runNum, (int)duration);
	gmp_printf("buyCost = %Zd sellCost = %Zd\n", buyCost, sellCost);
}
 
int main() {
	for (int i = 0; i < 5; i++) {
		perfRun(i);
	}
}

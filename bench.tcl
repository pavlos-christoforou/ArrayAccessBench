#!/usr/bin/env tclsh8.6
#
#set NUM_RECORDS [expr {50 * 1000 * 444}]
set NUM_RECORDS [expr {50 * 1000 * 50}]

proc initTrades {} {
    set recs $::NUM_RECORDS
    set trades [lrepeat $recs [list 1 2 3 4 5 6 7]] 
    for {set i 0} {$i < $recs} {incr i} {
	if {$i % 2} {
	    set side "B"
	} else {
	    set side "S"
	}
	lset trades $i 0 $i
	lset trades $i 1 1
	lset trades $i 2 123
	lset trades $i 3 321
	lset trades $i 4 $i
	lset trades $i 5 $i
	lset trades $i 6 $side
    }
    return $trades
}

proc perfRun {i} {
    set start [clock clicks -milliseconds]
    set trades [initTrades]
    set buyCost 0
    set sellCost 0

    foreach trade $trades {
	if {[lindex $trade 6] eq "B"} {
	   set buyCost [expr {$buyCost + [lindex $trade 4] * [lindex $trade 5]}]
        } else {
           set sellCost [expr {$sellCost + [lindex $trade 4] * [lindex $trade 5]}]
       }
    }
    set stop [clock clicks -milliseconds]
    set duration [expr {$stop - $start}]
    puts [format "%s - duration %d ms" $i $duration]
    puts [format "buyCost = %s sellCost = %s" $buyCost $sellCost]
}

proc main {} {
    for {set i 0} {$i < 5} { incr i} {
        perfRun $i
    }	
}
main ; #

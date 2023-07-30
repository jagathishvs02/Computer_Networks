
set val(chan)            Channel/WirelessChannel 
set val(prop)           Propagation/TwoRayGround 
set val(netif)          Phy/WirelessPhy
set val(mac)            Mac/802_11
set val(ifq)            Queue/DropTail/PriQueue
set val(ll)             LL
set val(ant)            Antenna/OmniAntenna
set val(ifqlen)         50
set val(nn)             10
set val(rp)             AODV
set val(x)  500
set val(y)  500


set ns [new Simulator]
set tracefile [open Tahoe_wireless.tr w]

$ns trace-all $tracefile
set namfile [open Tahoe_wireless.nam w]

$ns namtrace-all-wireless $namfile $val(x) $val(y)

set fa [open "tt_Tahoe_wireless.xg" "w"]

set f1 [open "tb_Tahoe_wireless.xg" "w"]

proc finish {} {

        global ns tracefile namfile fa f1
        $ns flush-trace
        close $tracefile
 	close $namfile

	close $fa 
	close $f1 


	exec xgraph tt_Tahoe_wireless.xg tb_Tahoe_wireless.xg Tahoe_wireless1.xg Tahoe_wireless2.xg -geometry 300x300 &
        exec nam Tahoe_wireless.nam &
        exit 0
}

proc record {} {
 global ftp1 ftp2 fa f1
 global sink1 sink2

 set ns [Simulator instance]
 set time 0.1
 set now [$ns now]
 
 set bw0 [$sink1 set bytes_]
 set bw1 [$sink2 set bytes_]

 set totbw [expr $bw0 + $bw1]
 puts $fa "$now [expr $totbw/$time*8/1000000]"

 puts $f1 "$now [expr $totbw]"

 $sink1 set bytes_ 0
 $sink2 set bytes_ 0

 $ns at [expr $now+$time] "record"
 
}

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
  -llType $val(ll) \
  -macType $val(mac) \
  -ifqType $val(ifq) \
  -ifqLen $val(ifqlen) \
  -antType $val(ant) \
  -propType $val(prop) \
  -phyType $val(netif) \
  -topoInstance $topo \
  -agentTrace ON \
  -macTrace ON \
  -routerTrace ON \
  -movementTrace ON \
  -channel [new $val(chan)] 
  
for {set i 0} {$i < $val(nn) } { incr i } {
   set n($i) [$ns node]
   $n($i) random-motion 0
   $ns initial_node_pos $n($i) 50
}

$n(0) set X_ -110.0
$n(0) set Y_ 350.0
$n(0) set Z_ 0.0

$n(1) set X_ -10.0
$n(1) set Y_ 350.0
$n(1) set Z_ 0.0

$n(2) set X_ 50.0
$n(2) set Y_ 450.0
$n(2) set Z_ 0.0

$n(3) set X_ -120.0
$n(3) set Y_ 100.0
$n(3) set Z_ 0.0

$n(4) set X_ 90.0
$n(4) set Y_ 100.0
$n(4) set Z_ 0.0

$n(5) set X_ -200.0
$n(5) set Y_ 200.0
$n(5) set Z_ 0.0

$n(6) set X_ 90.0
$n(6) set Y_ 200.0
$n(6) set Z_ 0.0

$n(7) set X_ 400.0
$n(7) set Y_ 100.0
$n(7) set Z_ 0.0

$n(8) set X_ -410.0
$n(8) set Y_ 320.0
$n(8) set Z_ 0.0

$n(9) set X_ 280.0
$n(9) set Y_ -140.0
$n(9) set Z_ 0.0


$ns at 1.0 "$n(0) setdest 70.0 50.0 0.0"
$ns at 1.0 "$n(1) setdest 20.0 30.0 0.0"
$ns at 1.0 "$n(2) setdest 200.0 450.0 85.0"
$ns at 1.0 "$n(3) setdest 40.0 100.0 0.0"
$ns at 1.0 "$n(4) setdest 30.0 45.0 0.0"
$ns at 1.0 "$n(5) setdest 80.0 200.0 0.0"
$ns at 1.0 "$n(6) setdest 50.0 350.0 0.0"
$ns at 1.0 "$n(7) setdest 300.0 145.0 0.0"
$ns at 1.0 "$n(8) setdest 110.0 230.0 0.0"
$ns at 1.0 "$n(9) setdest 250.0 50.0 0.0"

$n(0) color "red"
$ns at 1.0 "$n(0) color red"

$n(5) color "red"
$ns at 1.0 "$n(5) color red"

$n(2) color "darkgreen"
$ns at 1.0 "$n(2) color darkgreen"



set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp1
$ns attach-agent $n(5) $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1


set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
$ns attach-agent $n(2) $tcp2
$ns attach-agent $n(6) $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns at 0.55 "record"
$ns at 1.0 "$ftp1 start"
$ns at 1.0 "$ftp2 start"

$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2

$ns at 14.0 "$ftp1 stop"
$ns at 10.0 "$ftp2 stop"
$ns at 15.0 "finish"


proc plotWindow {tcpSource outfile} {
   global ns
   set now [$ns now]
   set cwnd [$tcpSource set cwnd_]

# the data is recorded in a file called congestion.xg (this can be plotted # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
   puts  $outfile  "$now $cwnd"
   $ns at [expr $now+0.1] "plotWindow $tcpSource  $outfile"
}

set outfile1 [open Tahoe_wireless1.xg w]
set outfile2 [open Tahoe_wireless2.xg w]

$ns  at  0.0  "plotWindow $tcp1  $outfile1"
$ns  at  0.0  "plotWindow $tcp2  $outfile2"



$ns run





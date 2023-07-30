

set ns [new Simulator]

set nf [open Tahoe_grid.nam w]
$ns namtrace-all $nf

set nftr [open Tahoe_grid.tr w]
$ns trace-all $nftr

set fa [open "tt_Tahoe_grid.xg" "w"]

set f1 [open "tb_Tahoe_grid.xg" "w"]

proc finish {} {

        global ns nf nftr fa f1
        $ns flush-trace
        close $nf

	close $fa 
	close $f1 


	exec xgraph tt_Tahoe_grid.xg tb_Tahoe_grid.xg Tahoe_grid1.xg Tahoe_grid2.xg Tahoe_grid3.xg -geometry 300x300 &
        exec nam Tahoe_grid.nam &
        exit 0
}

proc record {} {
 global ftp1 ftp2 ftp3 fa f1
 global sink1 sink2 sink3

 set ns [Simulator instance]
 set time 0.1
 set now [$ns now]
 
 set bw0 [$sink1 set bytes_]
 set bw1 [$sink2 set bytes_]
 set bw2 [$sink3 set bytes_]

 set totbw [expr $bw0 + $bw1 + $bw2]
 puts $fa "$now [expr $totbw/$time*8/1000000]"

 puts $f1 "$now [expr $totbw]"

 $sink1 set bytes_ 0
 $sink2 set bytes_ 0
 $sink3 set bytes_ 0

 $ns at [expr $now+$time] "record"
 
}

set rows 3
set cols 3
set start [lindex $argv 2]
set stop [lindex $argv 3]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

$ns duplex-link $n0 $n1   2Mb  10ms DropTail
$ns duplex-link $n0 $n3   1Mb  50ms DropTail
$ns duplex-link $n1 $n4   2Mb  10ms DropTail
$ns duplex-link $n1 $n2   1Mb  50ms DropTail
$ns duplex-link $n2 $n5   5Mb  10ms DropTail
$ns duplex-link $n3 $n4   2Mb  10ms DropTail
$ns duplex-link $n4 $n5   5Mb  40ms DropTail
$ns duplex-link $n3 $n6   2Mb  10ms DropTail
$ns duplex-link $n4 $n7   3Mb 100ms DropTail
$ns duplex-link $n5 $n8 0.3Mb 200ms DropTail
$ns duplex-link $n6 $n7 0.3Mb 200ms DropTail
$ns duplex-link $n7 $n8   3Mb 200ms DropTail

# Sending node is 0 with agent as Tahoe Agent


set tcp1 [new Agent/TCP]
#$tcp1 set windowOption_ 25
set tcp2 [new Agent/TCP]
#$tcp2 set windowOption_ 25
set tcp3 [new Agent/TCP]
#$tcp3 set windowOption_ 25

$ns attach-agent $n0 $tcp1
$ns attach-agent $n1 $tcp2
$ns attach-agent $n1 $tcp3

# receiving (sink) node is n4

set sink1 [new Agent/TCPSink]
set sink2 [new Agent/TCPSink]
set sink3 [new Agent/TCPSink]
$ns attach-agent $n6 $sink1
$ns attach-agent $n2 $sink2
$ns attach-agent $n7 $sink3

# establish the traffic between the source and sink

$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2
$ns connect $tcp3 $sink3

# Setup a FTP traffic generator on "tcp1"

set ftp1 [new Application/FTP]
set ftp2 [new Application/FTP]
set ftp3 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp2 attach-agent $tcp2
$ftp3 attach-agent $tcp3

$ftp1 set type_ FTP   
$ftp2 set type_ FTP  
$ftp3 set type_ FTP           

# start/stop the traffic

$ns at 0.1  "$ftp1 start"
$ns at 0.55 "record"
$ns at 5    "$ftp2 start"
$ns at 5    "$ftp3 start"
$ns at 40.0 "$ftp1 finish"

proc plotWindow {tcpSource outfile} {
   global ns
   set now [$ns now]
   set cwnd [$tcpSource set cwnd_]

# the data is recorded in a file called congestion.xg (this can be plotted # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
   puts  $outfile  "$now $cwnd"
   $ns at [expr $now+0.1] "plotWindow $tcpSource  $outfile"
}

set outfile1 [open Tahoe_grid1.xg w]
set outfile2 [open Tahoe_grid2.xg w]
set outfile3 [open Tahoe_grid3.xg w]

$ns  at  0.0  "plotWindow $tcp1  $outfile1"
$ns  at  0.0  "plotWindow $tcp2  $outfile2"
$ns  at  0.0  "plotWindow $tcp3  $outfile3"


$ns run

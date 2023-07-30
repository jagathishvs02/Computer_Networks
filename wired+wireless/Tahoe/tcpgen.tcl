set tcp_(0) [$ns_ create-connection  TCP $BS(1) TCPSink $node_(4) 0]
$tcp_(0) set window_ 32
$tcp_(0) set packetSize_ 512
set ftp_(0) [$tcp_(0) attach-source FTP]
$ns_ at 135.62648219784091 "$ftp_(0) start"
#
# 3 connecting to 5 at time 99.562858808582121
#
set tcp_(1) [$ns_ create-connection  TCP $node_(3) TCPSink $BS(1) 0]
$tcp_(1) set window_ 32
$tcp_(1) set packetSize_ 512
set ftp_(1) [$tcp_(1) attach-source FTP]
$ns_ at 99.562858808582121 "$ftp_(1) start"
#
# 4 connecting to 5 at time 22.118449910599018
#
set tcp_(2) [$ns_ create-connection  TCP $node_(4) TCPSink $BS(0) 0]
$tcp_(2) set window_ 32
$tcp_(2) set packetSize_ 512
set ftp_(2) [$tcp_(2) attach-source FTP]
$ns_ at 22.118449910599018 "$ftp_(2) start"
#
# 6 connecting to 7 at time 101.78236045026331
#
set tcp_(3) [$ns_ create-connection  TCP $BS(0) TCPSink $node_(3) 0]
$tcp_(3) set window_ 32
$tcp_(3) set packetSize_ 512
set ftp_(3) [$tcp_(3) attach-source FTP]
$ns_ at 101.78236045026331 "$ftp_(3) start"


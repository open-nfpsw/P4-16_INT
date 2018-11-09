export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/_perf/daq_snort/build/lib
export SNORT_ROOT=~/_perf/ROOT
export RTE_SDK="$SNORT_ROOT/share/dpdk"
export RTE_TARGET="$(uname -m)"-native-linuxapp-gcc

echo 10000 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

cd /root/_perf/daq_snort

#1 From Endpoint
LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:08.0:0000:02:08.0 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x2 --daq-var master-lcore=1 --daq-var socket-mem=256,256  --daq-var file-prefix=snort1 -c ~/snort-2.9.9.0/etc/snort.conf & 

#2
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:08.1:0000:02:08.2 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x4 --daq-var master-lcore=2 --daq-var socket-mem=256,256  --daq-var file-prefix=snort2 -c ~/snort-2.9.9.0/etc/snort.conf &
#
#3
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:08.3:0000:02:08.4 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x8 --daq-var master-lcore=3 --daq-var socket-mem=256,256  --daq-var file-prefix=snort3 -c ~/snort-2.9.9.0/etc/snort.conf &

#4
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:08.5:0000:02:08.6 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x10 --daq-var master-lcore=4 --daq-var socket-mem=256,256  --daq-var file-prefix=snort4 -c ~/snort-2.9.9.0/etc/snort.conf & 

#5
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:08.7:0000:02:09.0 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x20 --daq-var master-lcore=5 --daq-var socket-mem=256,256  --daq-var file-prefix=snort5 -c ~/snort-2.9.9.0/etc/snort.conf &

#6
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:09.1:0000:02:09.2 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x40 --daq-var master-lcore=6 --daq-var socket-mem=256,256  --daq-var file-prefix=snort6 -c ~/snort-2.9.9.0/etc/snort.conf &

#7
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:09.3:0000:02:09.4 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x80 --daq-var master-lcore=7 --daq-var socket-mem=256,256  --daq-var file-prefix=snort7 -c ~/snort-2.9.9.0/etc/snort.conf &

#8
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:09.5:0000:02:09.6 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x100 --daq-var master-lcore=8 --daq-var socket-mem=256,256  --daq-var file-prefix=snort8 -c ~/snort-2.9.9.0/etc/snort.conf &

#9
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:09.7:0000:02:0a.0 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x200 --daq-var master-lcore=9 --daq-var socket-mem=256,256  --daq-var file-prefix=snort9 -c ~/snort-2.9.9.0/etc/snort.conf &

#10
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0a.1:0000:02:0a.2 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x400 --daq-var master-lcore=10 --daq-var socket-mem=256,256  --daq-var file-prefix=snort10 -c ~/snort-2.9.9.0/etc/snort.conf &

#11
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0a.3:0000:02:0a.4 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x800 --daq-var master-lcore=11 --daq-var socket-mem=256,256  --daq-var file-prefix=snort11 -c ~/snort-2.9.9.0/etc/snort.conf &

#12
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0a.5:0000:02:0a.6 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x1000 --daq-var master-lcore=12 --daq-var socket-mem=256,256  --daq-var file-prefix=snort12 -c ~/snort-2.9.9.0/etc/snort.conf &

#13
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0a.7:0000:02:0b.0 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x2000 --daq-var master-lcore=13 --daq-var socket-mem=256,256  --daq-var file-prefix=snort13 -c ~/snort-2.9.9.0/etc/snort.conf &

#14
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0b.1:0000:02:0b.2 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x4000 --daq-var master-lcore=14 --daq-var socket-mem=256,256  --daq-var file-prefix=snort14 -c ~/snort-2.9.9.0/etc/snort.conf &

##15
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0b.3:0000:02:0b.4 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x4000 --daq-var master-lcore=14 --daq-var socket-mem=256,256  --daq-var file-prefix=snort14 -c ~/snort-2.9.9.0/etc/snort.conf &

##16
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0b.5:0000:02:0b.6 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x4000 --daq-var master-lcore=14 --daq-var socket-mem=256,256  --daq-var file-prefix=snort14 -c ~/snort-2.9.9.0/etc/snort.conf &

#17
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0b.7:0000:02:0c.0 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x4000 --daq-var master-lcore=14 --daq-var socket-mem=256,256  --daq-var file-prefix=snort14 -c ~/snort-2.9.9.0/etc/snort.conf &



#Back to Endpoint
LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:0b.3:0000:01:08.3 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x8000 --daq-var master-lcore=15 --daq-var socket-mem=256,256  --daq-var file-prefix=snort15 -c ~/snort-2.9.9.0/etc/snort.conf 

###################################################################################################################





##15
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0b.3:0000:02:0b.4 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x8000 --daq-var master-lcore=15 --daq-var socket-mem=256,256  --daq-var file-prefix=snort15 -c ~/snort-2.9.9.0/etc/snort.conf &
##

#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0b.5:0000:02:0b.6 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x10000 --daq-var master-lcore=16 --daq-var socket-mem=256,256  --daq-var file-prefix=snort16 -c ~/snort-2.9.9.0/etc/snort.conf &
##
##17
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0b.7:0000:02:0c.0 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x20000 --daq-var master-lcore=17 --daq-var socket-mem=256,256  --daq-var file-prefix=snort17 -c ~/snort-2.9.9.0/etc/snort.conf &
##
##18
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.1:0000:02:0c.2 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x40000 --daq-var master-lcore=18 --daq-var socket-mem=256,256  --daq-var file-prefix=snort18 -c ~/snort-2.9.9.0/etc/snort.conf &
##
##19
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.3:0000:02:0c.4 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x80000 --daq-var master-lcore=19 --daq-var socket-mem=256,256  --daq-var file-prefix=snort19 -c ~/snort-2.9.9.0/etc/snort.conf &
#
##18
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.5:0000:02:0c.6 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x40000 --daq-var master-lcore=18 --daq-var socket-mem=256,256  --daq-var file-prefix=snort18 -c ~/snort-2.9.9.0/etc/snort.conf &
##
##19
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.7:0000:03:08.3 --daq-dir  "$(pwd)/build"  --daq  --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x80000 --daq-var master-lcore=19 --daq-var socket-mem=256,256  --daq-var file-prefix=snort19 -c ~/snort-2.9.9.0/etc/snort.conf &
#
#
#

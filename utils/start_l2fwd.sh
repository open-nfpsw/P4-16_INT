export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/snort_perf/daq_snort/build/lib
export SNORT_ROOT=~/snort_perf/ROOT
#export RTE_SDK="$SNORT_ROOT/share/dpdk"
#export RTE_SDK="/root/dpdk-ns/"
#export RTE_TARGET="$(uname -m)"-native-linuxapp-gcc

echo 1000 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

cd ~/dpdk-ns

export RTE_SDK=~/dpdk-ns
export RTE_TARGET=x86_64-native-linuxapp-gcc

cd ~/dpdk-ns/examples/l2fwd
./build/l2fwd -c 0xc -n 4 --proc-type auto --pci-whitelist 0000:02:08.0 --pci-whitelist 0000:01:08.0 --socket-mem 256,256 --file-prefix=nfp0 -- -p 0x3 -T 1

##1 From Endpoint
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:02:08.0:0000:01:08.0 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x2 --daq-var master-lcore=1 --daq-var socket-mem=256,256  --daq-var file-prefix=snort1 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf & 
#
##Back to Endpoint
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" snort -Q -i 0000:01:0b.3:0000:03:08.3 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x8000 --daq-var master-lcore=15 --daq-var socket-mem=256,256  --daq-var file-prefix=snort15 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf 
#
###################################################################################################################





##15
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0b.3:0000:02:0b.4 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x8000 --daq-var master-lcore=15 --daq-var socket-mem=256,256  --daq-var file-prefix=snort15 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf &
##

#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0b.5:0000:02:0b.6 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x10000 --daq-var master-lcore=16 --daq-var socket-mem=256,256  --daq-var file-prefix=snort16 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf &
##
##17
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0b.7:0000:02:0c.0 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x20000 --daq-var master-lcore=17 --daq-var socket-mem=256,256  --daq-var file-prefix=snort17 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf &
##
##18
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.1:0000:02:0c.2 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x40000 --daq-var master-lcore=18 --daq-var socket-mem=256,256  --daq-var file-prefix=snort18 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf &
##
##19
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.3:0000:02:0c.4 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x80000 --daq-var master-lcore=19 --daq-var socket-mem=256,256  --daq-var file-prefix=snort19 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf &
#
##18
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.5:0000:02:0c.6 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x40000 --daq-var master-lcore=18 --daq-var socket-mem=256,256  --daq-var file-prefix=snort18 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf &
##
##19
#LD_LIBRARY_PATH="$SNORT_ROOT/lib" "$SNORT_ROOT/bin/snort" -Q -i 0000:01:0c.7:0000:03:08.3 --daq-dir  "$(pwd)/build"  --daq snort --daq-var pmd-dir="$SNORT_ROOT/lib" --daq-var coremask=0x80000 --daq-var master-lcore=19 --daq-var socket-mem=256,256  --daq-var file-prefix=snort19 -c ~/snort_perf/snort-2.9.9.0/etc/snort.conf &
#
#
#

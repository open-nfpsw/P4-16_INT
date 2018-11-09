#!/bin/bash

systemctl start nfp-sdk6-rte
systemctl start nfp-sdk6-rte1

ifconfig ens1f0 up
ifconfig ens1f1 up

killall snort
killall l2fwd

echo "==================================="
echo "    Loading Nic 0"
echo "==================================="
~/nfp-sdk-6.1-preview/p4/bin/rtecli -p 20206 design-load -p out/pif_design.json -c ./p4cfg/endpoint.p4cfg -f ./out/app.nffw

echo "==================================="
echo "    Loading Nic 1"
echo "==================================="
~/nfp-sdk-6.1-preview/p4/bin/rtecli -p 20207 design-load -p out/pif_design.json -c ./p4cfg/transit.p4cfg -f ./out/app.nffw


echo "==================================="
echo "    DONE"
echo "==================================="


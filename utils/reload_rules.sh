#!/bin/bash

echo "==================================="
echo "    Loading Endpoint Rules Nic 0"
echo "==================================="

~/nfp-sdk-6.x-devel/p4/bin/rtecli -p 20206 config-reload -c ./p4cfg/endpoint.p4cfg

echo "==================================="
echo "    Loading Transit Rules Nic 1"
echo "==================================="

~/nfp-sdk-6.x-devel/p4/bin/rtecli -p 20207 config-reload -c ./p4cfg/transit.p4cfg

echo "==================================="
echo "    DONE"
echo "==================================="


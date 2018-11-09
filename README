# P4-16 INT

This repository contains the P4 source code and configuration files to
demonstrate the use of P4 Inband Network Telemetry on Netronome SmartNICs.

![demo_setup](https://github.com/open-nfpsw/P4-16_INT/blob/master/demo_setup.png)

###Endpoint -> Transition -> Endpoint

The same P4 code is loaded onto all SmartNICs. The 'endpoint' P4 configuration
file is used to encaptulate the packets with headers to be processed as INT
packets throughout the rest of the system. The rest of the system is 
configured with the 'transit' configuration file. 

Each time the packet goes through a transition device a timestamp is added 
together with a device ID.

When the packet returns to the endpoint SmartNIC it can be cloned. The cloned 
packet can be sent to a controller to be parsed and analyzed. The added INT 
headers can also be decapsulated to restore the packet to its original state 
to be sent out a different port unchanged.


from scapy.all import *
import argparse
import time
import threading
from threading import Event
import collections
import Queue
from SimpleXMLRPCServer import SimpleXMLRPCServer
from SimpleXMLRPCServer import SimpleXMLRPCRequestHandler
#import numpy as np

hops = {"1-2":collections.deque(maxlen=10),\
	"2-3":collections.deque(maxlen=10),\
	"3-4":collections.deque(maxlen=10),\
	"4-5":collections.deque(maxlen=10),\
	"5-6":collections.deque(maxlen=10),\
	"6-7":collections.deque(maxlen=10),\
	"7-8":collections.deque(maxlen=10),\
	"8-9":collections.deque(maxlen=10),\
	"9-10":collections.deque(maxlen=10),\
	"10-11":collections.deque(maxlen=10),\
	"11-12":collections.deque(maxlen=10),\
	"12-13":collections.deque(maxlen=10),\
	"13-14":collections.deque(maxlen=10)}

latencyAvgs = {}

# Restrict to a particular path.
class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)

class MyServer(SimpleXMLRPCServer):
    def __init__(self, queue, *args, **kwargs):
        self.queue = queue
        SimpleXMLRPCServer.__init__(self, *args, **kwargs)
        self.register_function(self.getFlows)

    def getFlows(self):
        return self.queue.get(False)

class FuncThread(threading.Thread):
    def __init__(self, target, *args):
        self._target = target
        self._args = args
        threading.Thread.__init__(self)

    def run(self):
        self._target(*self._args)

class PacketProcessor(object):
    def __init__(self, queue):
	self.tstamps = {}

	self.queue = queue

    def __call__(self, x):
        t1 = FuncThread(self.processPacket, x)
        t1.daemon = True
        t1.start()

    def byteToHexToInt(self,byteStr):
        return int((''.join( [ "%02X " % ord( x ) for x in byteStr ] ).strip()).replace(" ",""),16)

    def populateTstampDict(self,i,p_str,tstampId,devId):
	if (p_str[i:i+self.step] == '\x00' * 6 + devId*2):
	    rxTstampId = 'tstamp_rx_nsec_' + tstampId
	    txTstampId = 'tstamp_tx_nsec_' + tstampId
	    self.tstamps[rxTstampId] = p_str[i+self.step+6:i+self.step+10]
            self.tstamps[txTstampId] = p_str[i+self.step+10:i+self.step+14]
            #hexdump(p_str[i:i+self.step])
            #hexdump(self.tstamps[rxTstampId])
	    #hexdump(self.tstamps[txTstampId])
	    return True
        return False


    def processPacket(self, p):
        #hexdump(p)
        p_str = str(p)

	# Search for device IDs and extract RX and TX Timestamps
	self.step = 8
        for i in range(0,len(p_str)-self.step,self.step):
	    self.populateTstampDict(i,p_str,'14','\xFF')
	    self.populateTstampDict(i,p_str,'13','\xEE')
	    self.populateTstampDict(i,p_str,'12','\xDD')
            self.populateTstampDict(i,p_str,'11','\xCC')
            self.populateTstampDict(i,p_str,'10','\xBB')
            self.populateTstampDict(i,p_str,'9','\xAA')
            self.populateTstampDict(i,p_str,'8','\x99')
            self.populateTstampDict(i,p_str,'7','\x88')
            self.populateTstampDict(i,p_str,'6','\x77')
            self.populateTstampDict(i,p_str,'5','\x66')
            self.populateTstampDict(i,p_str,'4','\x55')
            self.populateTstampDict(i,p_str,'3','\x44')
            self.populateTstampDict(i,p_str,'2','\x33')
            self.populateTstampDict(i,p_str,'1','\x22')
	
	if len(self.tstamps) == 28:
	    hops["1-2"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_2"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_1"]))	   
            hops["2-3"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_3"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_2"]))
            hops["3-4"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_4"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_3"]))
            hops["4-5"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_5"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_4"]))
            hops["5-6"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_6"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_5"]))
            hops["6-7"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_7"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_6"]))
            hops["7-8"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_8"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_7"]))
            hops["8-9"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_9"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_8"]))
            hops["9-10"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_10"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_9"]))
            hops["10-11"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_11"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_10"]))
            hops["11-12"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_12"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_11"]))
            hops["12-13"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_13"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_12"]))
            hops["13-14"].append(self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_14"]) - self.byteToHexToInt(self.tstamps["tstamp_rx_nsec_13"]))

	    latencyAvgs["1-2"] = sum(hops["1-2"])/len(hops["1-2"]) #np.mean(hops["1-2"])
            latencyAvgs["2-3"] = sum(hops["2-3"])/len(hops["2-3"]) #np.mean(hops["1-2"])
            latencyAvgs["3-4"] = sum(hops["3-4"])/len(hops["3-4"]) #np.mean(hops["1-2"])
            latencyAvgs["4-5"] = sum(hops["4-5"])/len(hops["4-5"]) #np.mean(hops["1-2"])
            latencyAvgs["5-6"] = sum(hops["5-6"])/len(hops["5-6"]) #np.mean(hops["1-2"])
            latencyAvgs["6-7"] = sum(hops["6-7"])/len(hops["6-7"]) #np.mean(hops["1-2"])
            latencyAvgs["7-8"] = sum(hops["7-8"])/len(hops["7-8"]) #np.mean(hops["1-2"])
            latencyAvgs["8-9"] = sum(hops["8-9"])/len(hops["8-9"]) #np.mean(hops["1-2"])
            latencyAvgs["9-10"] = sum(hops["9-10"])/len(hops["9-10"]) #np.mean(hops["1-2"])
            latencyAvgs["10-11"] = sum(hops["10-11"])/len(hops["10-11"]) #np.mean(hops["1-2"])
            latencyAvgs["11-12"] = sum(hops["11-12"])/len(hops["11-12"]) #np.mean(hops["1-2"])
            latencyAvgs["12-13"] = sum(hops["12-13"])/len(hops["12-13"]) #np.mean(hops["1-2"])
            latencyAvgs["13-14"] = sum(hops["13-14"])/len(hops["13-14"]) #np.mean(hops["1-2"])
            
	    self.queue.put(latencyAvgs)

	    print(latencyAvgs["1-2"])

def main():

    parser = argparse.ArgumentParser(description='IOAM timestam collector config')
    parser.add_argument('-i','--interface', help='Interface to sniff', required=False,default="ens1f1")
    parser.add_argument('-a', '--ip-address', dest='ip_address', default='172.16.0.92', type=str,help="IP Address of server (DEFAULT: 172.16.0.92)")
    args = parser.parse_args()

    q = Queue.Queue(maxsize=0)

    # Create server
    server = MyServer(q, (args.ip_address, 8000),requestHandler=RequestHandler)
    thread.start_new_thread(server.serve_forever, ())

    pp = PacketProcessor(q)

    while(1):
        s = conf.L2socket(iface=args.interface)
        s.sniff(prn=pp)

if __name__ == '__main__':
    main()

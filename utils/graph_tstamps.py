import Queue
import threading
from threading import Event
import collections
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import style
import xmlrpclib
import argparse
import time

class MyAnimate(object):
    def __init__(self, i, ax1,hopName):
        self.i = i
        self.ax1 = ax1
        self.x = []
        self.y = []
        self.binName = []
        self.hopName = hopName
        self.i = i

    def setXY(self,xy):
        self.x = []
        self.y = []
        self.binName = []
        i=0
        for binName, latency in sorted(xy.iteritems()):
            self.x.append(binName) #(i)
            self.y.append(latency)
            self.binName.append(binName)
            i+=1

    def animate(self, i):
        xs = self.x
        ys = self.y

        self.ax1.clear()
        self.ax1.bar(xs, ys)
        self.ax1.set_title(self.hopName)
	self.ax1.plot(xs,ys)

        print "Graph " + str(self.i)
        print self.hopName
        print xs
        print ys
        print '' \
              ''
        #for h in xs:
            #self.ax1.text(h, ys[h]+1, self.binName[h], color='black', fontsize=16)
            #self.ax1.text(h, ys[h]/2, ys[h],color='green', fontsize=10)


class TimerThread(threading.Thread):
    def __init__(self, event, pollingTime, rpcServer, queue,hopGraph):
        threading.Thread.__init__(self)
        self.stopped = event
        self.pollingTime = pollingTime
        self.rpcServer = rpcServer
        self.queue = queue
	self.hopGraph = hopGraph

    def run(self):
        while not self.stopped.wait(self.pollingTime):
            print("Timestamp Graph Poll")

            try:
                latencies = self.rpcServer.getFlows()
            except:
                latencies = None

            if latencies:
                print(latencies)
	        self.queue.put(latencies, True) #Still needed?
		self.hopGraph[1].setXY(latencies)
            else:
                print("No new Latency Figures")


def main():
    parser = argparse.ArgumentParser(description='P4 Performance Test - Client Config')
    parser.add_argument('-t', '--graph-refresh-time', dest='refresh_time', default=1, type=float,
                        help="Interval for refreshing the graph (DEFAULT: 1000 ms)")
    parser.add_argument('-i', '--ip-address', dest='ip_address', default='172.16.0.92', type=str,
                        help="IP Address of server (DEFAULT: 172.16.0.92)")

    args = parser.parse_args()

    hopGraphs = {}
#    shown = False
    i = 0

    style.use('fivethirtyeight')
    fig = plt.figure(i)
    ax1 = fig.add_subplot(1, 1, 1)
    myAnimate = MyAnimate(1, ax1,"Snort Latency Figures")
    ani = animation.FuncAnimation(fig, myAnimate.animate,interval=args.refresh_time * 1000)  # polling time is in secondes, interval is in ms
    hopGraph = ((ani,myAnimate))

    rpcServer = xmlrpclib.ServerProxy('http://root:netronome@%s:8000' % (args.ip_address))

    stopFlag = Event()
    queue = Queue.Queue()
    tThread = TimerThread(stopFlag, args.refresh_time, rpcServer, queue,hopGraph)
    tThread.daemon = True
    tThread.start()

    plt.show()
#    hopGraphs = {}
#    shown = False
#    i = 0
#
#    style.use('fivethirtyeight')
#    fig = plt.figure(i)
#    ax1 = fig.add_subplot(1, 1, 1)
#    myAnimate = MyAnimate(1, ax1,"Snort Latency Figures")
#    ani = animation.FuncAnimation(fig, myAnimate.animate,interval=args.refresh_time * 1000)  # polling time is in secondes, interval is in ms
#    hopGraph = ((ani,myAnimate))
#    plt.show()
    while True:
	time.sleep(10)
#        try:
#            latencies = queue.get()
#        except Queue.Empty, err:
#            latencies = None

#        if latencies:
#            print(latencies)
#	    hopGraph = ((ani,myAnimate))
            #shown = False
#	    print("happening 1?")

#	    hopGraph[1].setXY(latencies)

#           plt.pause(0.1)
#           if not shown:
#		print("happening 2 ?")
#                plt.ion()
                # plt.draw()
#                plt.show()
#                plt.pause(0.5)
#                shown = True


if __name__ == '__main__':
    main()

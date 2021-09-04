#!/usr/bin/env python3
import sys
import statistics
file=open(sys.argv[1],"r")
contents=file.readlines()
data=([],[])
def str_avg(li):
    return sum([float(x) for x in li]) * .001 / len(li)
def str_stdev(li):
    return statistics.stdev([float(x) for x in li]) * .001
for i in range(24):
    data[0].append([])
    data[1].append([])
for i in range(len(contents)):
    data[0][i % 24].append(contents[i].split(" ")[0])
    data[1][i % 24].append(contents[i].split(" ")[1][:-1])
for i in range(24):
    print("%.2f %.2f %.2f %.2f" % (str_avg(data[1][i]), str_avg(data[0][i]), str_stdev(data[1][i]), str_stdev(data[0][i])))
file.close()

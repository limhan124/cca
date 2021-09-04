#!/usr/bin/env python3
import statistics
# workloads = ["splash2x-fft", "dedup", "ferret", "canneal", "blackscholes", "freqmine"]
# workloads = ["splash2x-fft", "dedup"]
f1 = open("4_1_log.txt", "r")
w1 = f1.readlines()
f2 = open("4_2_log.txt", "r")
w2 = f2.readlines()
f3 = open("4_3_log.txt", "r")
w3 = f3.readlines()
# w = [w1, w2, w3]
# for workload in workloads:
    # times = [0, 0, 0]
    # for i in [0, 1, 2]:
    #     for word in w[i]:
    #         status = "dead"
    #         if (word.startswith("submit {workload}".format(workload=workload)) or word.startswith("unpause {workload}".format(workload=workload))) and status == "dead":
    #             status = "running"
    #             times[i] = times[i] - float(word.split(" ")[2])
    #         elif (word.startswith("finish {workload}".format(workload=workload)) or word.startswith("pause {workload}".format(workload=workload))) and status =="running":
    #             status = "dead"
    #             times[i] = times[i] + float(word.split(" ")[2])

a1 = [x.split(" ")[2] for x in w1 if x.startswith("start")]
a2 = [x.split(" ")[2] for x in w1 if x.startswith("end")]
a = float(a2[0]) - float(a1[0])
b1 = [x.split(" ")[2] for x in w2 if x.startswith("start")]
b2 = [x.split(" ")[2] for x in w2 if x.startswith("end")]
b = float(b2[0]) - float(b1[0])
c1 = [x.split(" ")[2] for x in w3 if x.startswith("start")]
c2 = [x.split(" ")[2] for x in w3 if x.startswith("end")]
c = float(c2[0]) - float(c1[0])
# print(workload)
# if workload == "splash2x-fft":
#     print([a, b, c])
print(statistics.mean([a, b, c]))
print(statistics.stdev([a, b, c]))

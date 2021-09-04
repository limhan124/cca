#!/usr/bin/env python3

import subprocess
import sys
import docker
import time
import psutil
import pgrep


def init():
    global memcached_pid
    global memcached_core
    global memcached_cpu
    global memcached_process
    global memcached_threshold
    global client
    global workloads_status
    global log_file
    global single_thread_workloads
    memcached_core = 1
    memcached_pid = pgrep.pgrep("memcache")[0]
    memcached_threshold = 60.0
    memcached_process = psutil.Process(memcached_pid)
    memcached_cpu = memcached_process.cpu_percent(interval=None)
    exec_cmd("sudo taskset -a -cp 0 {pid}".format(pid=memcached_pid))
    client = docker.from_env()

    workloads_status = {
        "splash2x-fft": 0,
        "freqmine": 0,
        "blackscholes": 0,
        "dedup": 0,
        "canneal": 0,
        "ferret": 0
    }
    single_thread_workloads = ["dedup", "splash2x-fft"]
    log_file = "log.txt"
    if len(sys.argv) == 2:
        log_file = sys.argv[1]


def exec_cmd(cmd):
    p = subprocess.Popen(cmd, shell=True, stdout=None, stderr=None)
    p.wait()


def pre_work():
    global log_file
    exec_cmd("[ -e {log_file} ] && rm {log_file}".format(log_file=log_file))
    exec_cmd("touch {log_file}".format(log_file=log_file))
    exec_cmd("chmod 777 {log_file}".format(log_file=log_file))


def log(ev_type, ev_arg, timestamp, msg=""):
    global log_file
    f = open("{log_file}".format(log_file=log_file), "a+")
    f.write("{ev_type} {ev_arg} {timestamp} {msg}\n".format(
        ev_type=ev_type, ev_arg=ev_arg, timestamp=timestamp, msg=msg))


def submit_workload(workload_name, thread=1):
    global workloads_status
    cpuset = "2-3" if thread == 2 else "1"
    cmd = '''docker run --cpuset-cpus="{cpuset}" -d --rm --name {workload_name} \
anakli/parsec:{workload_name}-native-reduced \
./bin/parsecmgmt -a run -p {workload_name} -i native -n {thread}'''.format(cpuset=cpuset, workload_name=workload_name, thread=thread)
    if workload_name == "splash2x-fft":
        cmd = '''docker run --cpuset-cpus="{cpuset}" -d --rm --name {workload_name} \
anakli/parsec:{workload_name}-native-reduced \
./bin/parsecmgmt -a run -p splash2x.fft -i native -n {thread}'''.format(cpuset=cpuset, workload_name=workload_name, thread=thread)

    exec_cmd(cmd)
    log("submit", workload_name, int(time.time()))
    workloads_status[workload_name] = 1


def monitor_memcached():
    global memcached_cpu
    global memcached_core
    global memcached_process
    global memcached_threshold
    global memcached_pid
    global single_thread_workloads
    global workloads_status
    memcached_cpu = memcached_process.cpu_percent(interval=None)
    single_thread_finished = True
    for workload in single_thread_workloads:
        single_thread_finished = single_thread_finished and (
            workloads_status[workload] == 2)
    if single_thread_finished:
        if memcached_core == 1:
            exec_cmd("sudo taskset -a -cp 0-1 {pid}".format(pid=memcached_pid))
            memcached_core = memcached_core + 1
            log("change_core", memcached_core, int(time.time()))
    else:
        if (memcached_core == 1) and (memcached_cpu > memcached_threshold):
            exec_cmd("sudo taskset -a -cp 0-1 {pid}".format(pid=memcached_pid))
            memcached_core = memcached_core + 1
            for workload in single_thread_workloads:
                if workloads_status[workload] == 1:
                    exec_cmd("docker pause {workload}".format(
                        workload=workload))
                    log("pause", workload, int(time.time()))
            log("change_core", memcached_core, int(time.time()))
        elif (memcached_core == 2) and (memcached_cpu <= memcached_threshold):
            exec_cmd("sudo taskset -a -cp 0  {pid}".format(pid=memcached_pid))
            memcached_core = memcached_core - 1
            for workload in single_thread_workloads:
                if workloads_status[workload] == 1:
                    exec_cmd("docker unpause {workload}".format(
                        workload=workload))
                    log("unpause", workload, int(time.time()))
            log("change_core", memcached_core, int(time.time()))


def main_work():
    global client
    global workloads_status

    while True:
        monitor_memcached()
        running_workloads = [
            container.name for container in client.containers.list()]
        for workload in workloads_status:
            if workloads_status[workload] == 1 and (not (workload in running_workloads)):
                workloads_status[workload] = 2
                log("finish", str(workload), int(time.time()))
        completed = False
        for workload in workloads_status:
            if workloads_status[workload] != 2:
                completed = False
                time.sleep(1)
                break
            completed = True
        if completed:
            break


def submit_workloads():
    submit_workload("splash2x-fft", 1)
    submit_workload("freqmine", 2)
    submit_workload("blackscholes", 2)
    submit_workload("dedup", 1)
    submit_workload("canneal", 2)
    submit_workload("ferret", 2)


init()
pre_work()
log("start", "", int(time.time()))
submit_workloads()
main_work()
log("end", "", int(time.time()))

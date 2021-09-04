#!/usr/bin/env python3
import time
import subprocess
import re


def create():
    delete_jobs = subprocess.Popen("kubectl delete jobs --all", shell=True,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
    delete_jobs.wait()
    create_jobs = subprocess.Popen('''kubectl create -f part3/parsec-blackscholes.yaml\n
    kubectl create -f part3/parsec-ferret.yaml\n
    kubectl create -f part3/parsec-canneal.yaml''', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
    create_jobs.wait()
    completed = 0
    status = {'parsec-blackscholes': 0,  'parsec-canneal': 0, 'parsec-dedup': 0,
              'parsec-ferret': 0, 'parsec-splash2x-fft': 0, 'parsec-freqmine': 0}
    while True:
        get_jobs = subprocess.Popen("kubectl get jobs", shell=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
        res = get_jobs.communicate()[0]

        if res.find("1/1") != -1:
            for job in res.splitlines()[1:]:
                cur = re.split(r"[ ]+", job)
                if cur[0] == 'parsec-ferret' and cur[1] == '1/1' and status[cur[0]] == 0:
                    print(res)
                    print(cur[0])
                    status[cur[0]] = 1
                    completed += 1
                    subprocess.Popen("kubectl create -f part3/parsec-freqmine.yaml",
                                     shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
                if cur[0] == 'parsec-freqmine' and cur[1] == '1/1' and status[cur[0]] == 0:
                    print(res)
                    print(cur[0])
                    completed += 1
                    status[cur[0]] = 1
                if cur[0] == 'parsec-canneal' and cur[1] == '1/1' and status[cur[0]] == 0:
                    print(res)
                    print(cur[0])
                    completed += 1
                    status[cur[0]] = 1
                    subprocess.Popen("kubectl create -f part3/parsec-fft.yaml",
                                     shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
                if cur[0] == 'parsec-blackscholes' and cur[1] == '1/1' and status[cur[0]] == 0:
                    print(res)
                    print(cur[0])
                    status[cur[0]] = 1
                    completed += 1
                if cur[0] == 'parsec-splash2x-fft' and cur[1] == '1/1' and status[cur[0]] == 0:
                    print(res)
                    print(cur[0])
                    status[cur[0]] = 1
                    completed += 1
                    subprocess.Popen("kubectl create -f part3/parsec-dedup.yaml",
                                     shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
                if cur[0] == 'parsec-dedup' and cur[1] == '1/1' and status[cur[0]] == 0:
                    print(res)
                    print(cur[0])
                    status[cur[0]] = 1
                    completed += 1

            if completed == 6:
                break
            else:
                time.sleep(1)

    get_jobs = subprocess.Popen("kubectl get jobs -o json > results.json", shell=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
    get_jobs.wait()
    total_time = subprocess.Popen("python3 get_time.py results.json",
                                  shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
    print(total_time.communicate()[0])


create()

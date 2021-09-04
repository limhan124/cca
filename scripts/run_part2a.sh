#!/usr/bin/env bash
times=$1
if [ -z $times ]; then
    times=5
fi
benchmark_dir="parsec-benchmarks/part2a/parsec-"
inteference_dir="interference/ibench-"
log_dir="report/part2a"
log () {
    mkdir -p $log_dir"/"$1"/" && touch $log_dir"/"$1"/"$2".txt"
    echo -e "\n" >> $log_dir"/"$1"/"$2".txt"
    kubectl logs $3 >> $log_dir"/"$1"/"$2".txt"
    echo $1" with inteference "$2" is DONE and recorded in the log!"
}
create () {
    kubectl create -f $1
}

delete () {
    kubectl delete $1 $2
}

validate () {
    if [ "$1" = "completion" ]; then
        timeslice=10
        validate_cmd="kubectl get jobs.batch"
        feature_string="1/1"
        echo "===============wait for the benchmark to be completed=================="
    else
        timeslice=1
        validate_cmd="kubectl get pods"
        feature_string="Running"
        echo "===============wait for the inteference to be starting================="
    fi
    satisfied="false"
    while [ "$satisfied" = "false" ]; do
        sleep $timeslice
        if [[ "$($validate_cmd)" == *"$feature_string"* ]]; then
            satisfied="true"
            echo "validation is successful!"
        fi
    done
}

inteferences=("cpu" "l1d" "l1i" "l2" "llc" "membw")
benchmarks=("blackscholes" "dedup" "fft" "canneal" "ferret" "freqmine")
for inteference in ${inteferences[@]}; do
    create $inteference_dir$inteference".yaml"
    validate "running"
    for benchmark in ${benchmarks[@]}; do
        for i in $(seq 1 1 $times); do
            create $benchmark_dir$benchmark".yaml"
            validate "completion"
            if [ "$benchmark" = "fft" ]; then 
                job_id=$(kubectl get pods --selector=job-name="parsec-splash2x-"$benchmark --output=jsonpath='{.items[*].metadata.name}')
            else
                job_id=$(kubectl get pods --selector=job-name="parsec-"$benchmark --output=jsonpath='{.items[*].metadata.name}')
            fi
            log $benchmark $inteference $job_id
            if [ "$benchmark" = "fft" ]; then 
                delete "jobs.batch" "parsec-splash2x-"$benchmark
            else
                delete "jobs.batch" "parsec-"$benchmark
            fi
        done
    done
    delete "pods" "ibench-"$inteference
done
# no inteference
for benchmark in ${benchmarks[@]}; do
    for i in $(seq 1 1 $times); do
        create $benchmark_dir$benchmark".yaml"
        validate "completion"
        if [ "$benchmark" = "fft" ]; then 
            job_id=$(kubectl get pods --selector=job-name="parsec-splash2x-"$benchmark --output=jsonpath='{.items[*].metadata.name}')
        else
            job_id=$(kubectl get pods --selector=job-name="parsec-"$benchmark --output=jsonpath='{.items[*].metadata.name}')
        fi
        log $benchmark "none" $job_id
        if [ "$benchmark" = "fft" ]; then 
            delete "jobs.batch" "parsec-splash2x-"$benchmark
        else
            delete "jobs.batch" "parsec-"$benchmark
        fi
    done
done

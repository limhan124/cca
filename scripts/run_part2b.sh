#!/usr/bin/env bash
times=$1
if [ -z $times ]; then
    times=5
fi
benchmark_dir="parsec-benchmarks/part2b/parsec-"
log_dir="report/part2b"
log () {
    mkdir -p $log_dir"/"$1"/" && touch $log_dir"/"$1"/t"$2".txt"
    echo -e "\n" >> $log_dir"/"$1"/t"$2".txt"
    kubectl logs $3 >> $log_dir"/"$1"/t"$2".txt"
    echo "==========="$1" running with "$2" thread(s) is DONE and recorded in the log==========="
}
create () {
    kubectl create -f $1
}

delete () {
    kubectl delete $1 $2
}

validate () {
    timeslice=10
    validate_cmd="kubectl get jobs.batch"
    feature_string="1/1"
    echo "===============wait for the benchmark to be completed=================="
    satisfied="false"
    while [ "$satisfied" = "false" ]; do
        sleep $timeslice
        if [[ "$($validate_cmd)" == *"$feature_string"* ]]; then
            satisfied="true"
            echo "validation is successful!"
        fi
    done
}

threads=("8" "4" "2" "1")
benchmarks=("blackscholes" "dedup" "fft" "canneal" "ferret" "freqmine")
for benchmark in ${benchmarks[@]}; do
    for thread in ${threads[@]}; do
        sed -i "s/n\ [0-9]/n\ $thread/" $benchmark_dir$benchmark".yaml"
        for i in $(seq 1 1 $times); do
            create $benchmark_dir$benchmark".yaml"
            validate
            if [ "$benchmark" = "fft" ]; then 
                job_id=$(kubectl get pods --selector=job-name="parsec-splash2x-"$benchmark --output=jsonpath='{.items[*].metadata.name}')
            else
                job_id=$(kubectl get pods --selector=job-name="parsec-"$benchmark --output=jsonpath='{.items[*].metadata.name}')
            fi
            log $benchmark $thread $job_id
            if [ "$benchmark" = "fft" ]; then 
                delete "jobs.batch" "parsec-splash2x-"$benchmark
            else
                delete "jobs.batch" "parsec-"$benchmark
            fi
        done
    done
done

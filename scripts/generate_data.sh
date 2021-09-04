#!/usr/bin/env bash

# ==========================Preparation========================
inteferences=( "none" "cpu" "l1d" "l1i" "l2" "llc" "membw")
benchmarks=("dedup" "blackscholes"  "ferret" "freqmine" "canneal" "fft")
rm -rf result/data/part1 result/data/part2b result/data/part2a
mkdir -p result/data/part1 result/data/part2b result/data/part2a result/data/part4
chmod +x scripts/*
rm -f tmp
# ==========================Part1==============================
for inteference in ${inteferences[@]}; do
    cat "result/logs/part1/$inteference.txt" | grep -E "read" | awk '{print $13,$17;}'  > "result/data/part1/$inteference.txt"
    ./scripts/clean_part1.py "result/data/part1/$inteference.txt" > "result/data/part1/$inteference.dat"
done

# ==========================Part2a==============================
for benchmark in ${benchmarks[@]}; do
    for inteference in ${inteferences[@]}; do
        if [ "fft" = $benchmark ]
        then
            feature_string="Total time without initialization"
        else
            feature_string="real"
        fi
        cat "result/logs/part2a/$benchmark/$inteference.txt" | grep "$feature_string"  \
        | awk '{print $NF;}' \
        | sed 's/\(.*\)m\(.*\)s.*/60 \* \1 \+ \2 /'\
        | tr -d $'\r' \
        | bc -l \
        | awk '{ total += $1; count++ } END { print total/count }' \
        >> "result/data/part2a/$benchmark.txt" 
    done
    no_inteference_performance=$(head -n 1 "result/data/part2a/$benchmark.txt")
    cat "result/data/part2a/$benchmark.txt" \
    | \
    while read line; do
        echo "$no_inteference_performance $line" | awk '{ printf "%.2f\n", $2 / $1}' >> "result/data/part2a/$benchmark.dat"
    done
    rm -f tmp
    touch tmp
    index=0
    cat "result/data/part2a/$benchmark.dat" \
    | \
    while read line; do
        echo "${inteferences[$index]} $line" >> tmp
        index=$(echo "$index + 1" | bc)        
    done
    cp tmp "result/data/part2a/$benchmark.dat"
done
./scripts/generate_table.py > result/report/table.tex

rm -f tmp
# ==========================Part2b==============================
for benchmark in ${benchmarks[@]}; do
    for (( thread=1;thread<=8; thread *=2 )); do
        if [ "fft" = $benchmark ]
        then
            # feature_string="Total time without initialization"
            feature_string="real"
        else
            feature_string="real"
        fi
        cat "result/logs/part2b/$benchmark/t$thread.txt" | grep "$feature_string"  \
        | awk '{print $NF;}' \
        | sed 's/\(.*\)m\(.*\)s.*/60 \* \1 \+ \2 /'\
        | tr -d $'\r' \
        | bc -l \
        | awk '{ total += $1; count++ } END { print total/count }' \
        >> "result/data/part2b/$benchmark.txt" 
    done
    single_thread_performance=$(head -n 1 "result/data/part2b/$benchmark.txt")
    cat "result/data/part2b/$benchmark.txt" \
    | \
    while read line; do
        echo "$single_thread_performance $line" | awk '{ printf "%.2f\n", $1 / $2}' >> "result/data/part2b/$benchmark.dat"
    done
    rm -f tmp
    touch tmp
    index=1
    cat "result/data/part2b/$benchmark.dat" \
    | \
    while read line; do
        echo "$index $line" >> tmp
        index=$(echo "$index * 2" | bc)        
    done
    cp tmp "result/data/part2b/$benchmark.dat"
done
rm -f tmp

# ==========================Part4==============================
for t in $(seq 1 2); do
    for c in $(seq 1 2); do
        cat "result/logs/part4/t$t""c$c.txt" | grep -E "read" | awk '{print $13,$17;}'  > "result/data/part4/t$t""c$c.txt"
    done
done
for t in $(seq 1 2); do
    for c in $(seq 1 2); do
        ./scripts/clean_part4.py "result/data/part4/t$t""c$c.txt" > "result/data/part4/t$t""c$c.dat"
    done
done

gnuplot ./scripts/part1.plt >  "result/report/part1.svg"
gnuplot ./scripts/part2b.plt > "result/report/part2b.svg"
gnuplot ./scripts/part4.plt > "result/report/part4.svg"

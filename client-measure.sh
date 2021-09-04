#!/usr/bin/env sh
INTERNAL_AGENT_IP=10.156.0.35
INTERNAL_MEMCACHED_IP=10.156.0.34
 ./mcperf -s $INTERNAL_MEMCACHED_IP --loadonly
./mcperf -s $INTERNAL_MEMCACHED_IP -a $INTERNAL_AGENT_IP \
--noload -T 16 -C 4 -D 4 -Q 1000 -c 4 -t 1800 \
--qps_interval $1 --qps_min 5000 --qps_max 100000 \
--qps_seed 42

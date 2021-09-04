#!/usr/bin/gnuplot
set terminal svg
set yrange [0:10]
set xrange [0:55]
set xlabel "{/Times:Bold Achieved p95 QPS(query/s)}"
set ylabel "{/Times:Bold Memcached Latency(ms)}"
set format x "%g K"
set format y "%g ms"
# set title "Memcached Latency Distribution with Different Interferences under (Achieved) p95 QPS" \
# font "Helvetica,9"
set style line 1  lc rgb '#00ad88' lt 1 lw 1.5
set style line 2  lc rgb '#fc7303' lt 1 lw 1.5 
set style line 3  lc rgb '#035afc' lt 1 lw 1.5 
set style line 4  lc rgb '#0ffc03' lt 1 lw 1.5 
set style line 5  lc rgb '#fc032d' lt 1 lw 1.5 
set style line 6  lc rgb '#454545' lt 1 lw 1.5
set style line 7  lc rgb '#a81da4' lt 1 lw 1.5
plot "result/data/part1/cpu.dat"  title "CPU" w xyerrorlines ls 1, \
"result/data/part1/l1i.dat" title "l1i"  w xyerrorlines  ls 2 , \
"result/data/part1/l1d.dat" title "l1d" w xyerrorlines ls 3 , \
"result/data/part1/l2.dat"  title "l2" w xyerrorlines ls 4 , \
"result/data/part1/llc.dat"   title "llc" w xyerrorlines ls 5,\
"result/data/part1/membw.dat"   title "membw" w xyerrorlines ls 6,\
"result/data/part1/none.dat" title "no interference" w xyerrorlines ls 7 

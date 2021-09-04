#!/usr/bin/gnuplot
set terminal svg
set xrange [0:8]
set yrange [0:8]
set xlabel "{/Times:Bold Number of  Threads}"
set ylabel "{/Times:Bold Speedup}"
set format y "%g x"
# set title "PARSEC Benchmarks Scalability Performance"
set style line 1  lc rgb '#00ad88' lt 2 lw 1.5 ps 0.8
set style line 2  lc rgb '#fc7303' lt 2 lw 1.5 ps 0.8
set style line 3  lc rgb '#035afc' lt 2 lw 1.5 ps 0.8
set style line 4  lc rgb '#0ffc03' lt 2 lw 1.5 ps 0.8
set style line 5  lc rgb '#fc032d' lt 2 lw 1.5 ps 0.8
set style line 6  lc rgb '#454545' lt 2 lw 1.5 ps 0.8
set grid

plot "result/data/part2b/blackscholes.dat" title "blackscholes" w linespoints ls 1, \
     "result/data/part2b/dedup.dat" title "dedup"  w linespoints  ls 2 , \
     "result/data/part2b/fft.dat" title "fft" w linespoints  ls 3 , \
     "result/data/part2b/canneal.dat"  title "canneal" w linespoints ls 4 , \
     "result/data/part2b/ferret.dat"  title "ferret" w linespoints ls 5,\
     "result/data/part2b/freqmine.dat"  title "freqmine" w linespoints ls 6

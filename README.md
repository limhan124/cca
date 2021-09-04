# Cloud Computing Architecture Project

This repository contains starter code for the Cloud Computing Architecture course project at ETH Zurich. Students will explore how to schedule latency-sensitive and batch applications in a cloud cluster. Please follow the instructions in the project handout. 

## This is the repo for group 026
- always use script under the project root directory
- how to run the experiment(take ``part2a`` as an example):``./scripts/part2a.h {n}``, where ``n`` is the number of test you want to run
- result/ contains the raw result, gnuplot script, and latex report; you can use ``make`` to build the pdf, use ``make clean`` to clean.
- all things are automated; workflow: run experiment->**automatically** log the data->**automatically** clean the data->**automatically** generate plots and tables->**automatically** generate pdf
- currently only support ``Linux``; there's error about path resolution on ``Windows``

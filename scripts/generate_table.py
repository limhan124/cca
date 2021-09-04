#!/usr/bin/python3
benchmarks=["dedup", "blackscholes", "ferret", "freqmine", "canneal", "fft"]
path=r"result/data/part2a/"
for benchmark in benchmarks:
    print(benchmark + r" & ", end="")
    with open(path+benchmark+".dat", "r") as data:
        contents = [x.split(" ")[1][:-1] for x in data.readlines()]
        for x in contents:
            endchar=r"&"
            if x == contents[len(contents) - 1]:
                endchar=""
            if float(x) <= 1.3:
                print(r"{\color{Green}"+x+r"} "+endchar+" ", end="")
            elif float(x) <= 2:
                print(r"{\color{YellowOrange}"+x+r"} "+endchar+" ", end="")
            else:
                print(r"{\color{Red}"+x+r"} " + endchar+" ", end="")
    print(r" \\ \hline ")

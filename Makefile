all: plot
	pdflatex --shell-escape result/report/main.tex
	pdflatex --shell-escape result/report/main.tex
clean:
	rm -rf *.log *.aux result/data/
	mkdir -p result/data/
	rm -f main.pdf
	rm -f result/report/table.tex
	rm -f result/report/*.svg
	rm -f scripts/*.bak
plot: data
	@echo plot
data:
	./scripts/generate_data.sh
.PHONY: all clean plot table data

TARGET ?= main
OUTPUT ?= slide.pdf

build: $(TARGET).tex
	xelatex -shell-escape -output-driver="xdvipdfmx -z 0" $(TARGET).tex
	mv $(TARGET).pdf $(OUTPUT)

clean:
	rm *.log *.aux *.fdb_latexmk *.fls

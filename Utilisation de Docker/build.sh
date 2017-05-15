#!/bin/bash

mkdir -p build_tmp

for f in *.\ *.md; do cp "$f" "build_tmp/${f// /_}"; done

MD_FILES=$(ls build_tmp/*.md | sort -n -t/ -k2 | tr '\n' ' ')

docker run -ti --rm -v "$(pwd)":"$(pwd)" -w "$(pwd)" jagregory/pandoc \
    -s -f markdown_github \
    --epub-cover-image generate.png \
    --latex-engine=xelatex --toc -V geometry:margin=0.5in --variable fontsize=10pt \
    --variable fontfamily=utopia --variable linkcolor=blue \
    -o test.md $MD_FILES

docker run -ti --rm -v "$(pwd)":"$(pwd)" -w "$(pwd)" jagregory/pandoc \
    -s --top-level-division=chapter --highlight-style kate\
    --latex-engine=xelatex -V geometry:margin=0.5in --variable fontsize=10pt \
    --variable fontfamily=utopia --variable linkcolor=blue -o test.pdf test.md

rm -rf build_tmp
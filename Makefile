SHELL = /bin/bash

# Setting GOBIN makes 'go install' put the binary in the bin/ directory.
export GOBIN ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/bin

STITCHMD = $(GOBIN)/stitchmd

# Keep these options in-sync with .github/workflows/ci.yml.
STITCHMD_ARGS = -o style.md -preface src/preface.txt src/SUMMARY.md

.PHONY: all
all: style.md

.PHONY: lint
lint: $(STITCHMD)
	@DIFF=$$($(STITCHMD) -d $(STITCHMD_ARGS)); \
	if [[ -n "$$DIFF" ]]; then \
		echo "style.md is out of date:"; \
		echo "$$DIFF"; \
		false; \
	fi

style.md: $(STITCHMD) $(wildcard src/*)
	$(STITCHMD) $(STITCHMD_ARGS)

styledoc.md: $(STITCHMD) $(wildcard src/*)
	$(STITCHMD) -no-toc -o styledoc.md -preface src/pandocpreface.txt src/SUMMARY.md

styledoc.pdf: styledoc.md
	pandoc $< --toc -o $@

styledoc.html: styledoc.md
	pandoc $< --toc --standalone --css=https://unpkg.com/mvp.css  -o $@


$(STITCHMD):
	go install go.abhg.dev/stitchmd@latest

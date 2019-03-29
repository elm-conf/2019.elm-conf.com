CONTENT_SRC=$(wildcard content/*.md content/**/*.md)

# dependencies are generated!
public:
	touch -m $@

include Makefile.public

Makefile.public: script/generate-makefile.py $(CONTENT_SRC)
	$< $(CONTENT_SRC) > $@

# package management


clean:
	rm -rf public Makefile.public

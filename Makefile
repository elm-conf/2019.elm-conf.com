CONTENT_SRC=$(wildcard content/*.md content/**/*.md)

# dependencies are generated!
public:
	touch -m $@

include Makefile.public

Makefile.public: script/generate-makefile.py $(CONTENT_SRC)
	$< $(CONTENT_SRC) > $@

# package management

npm/default.nix: npm/package.json
	cd npm; node2nix -i package.json

clean:
	rm -rf public Makefile.public

CONTENT_SRC=$(wildcard content/*.md content/**/*.md)
ELM_SRC=$(wildcard src/*.elm src/**/*.elm)

# content dependencies are generated!
public: public/index.min.js
	touch -m $@

public/index.js: elm.json $(ELM_SRC)
	elm make src/Main.elm --output $@ --optimize

public/index.min.js: public/index.js node_modules
	./node_modules/.bin/uglifyjs $< --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | ./node_modules/.bin/uglifyjs --mangle > $@

include Makefile.public

Makefile.public: script/generate-makefile.py $(CONTENT_SRC)
	$< $(CONTENT_SRC) > $@

# package management

node_modules: package.json package-lock.json
	npm install
	@touch -m $@

clean:
	rm -rf public Makefile.public

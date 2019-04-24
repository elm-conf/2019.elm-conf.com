CONTENT_SRC=$(wildcard content/*.md content/**/*.md)
ELM_SRC=$(shell find src -name '*.elm')

STATIC_SRC=$(shell find static/ -type f)
STATIC=$(STATIC_SRC:static/%=public/%)

# content dependencies are generated!
public: public/index.min.js $(STATIC)
	touch -m $@

public/index.js: elm.json src/Api $(ELM_SRC) src/Routes.elm public/404.html
	npx elm make src/Main.elm --output $@ --optimize

public/index.min.js: public/index.js node_modules
	./node_modules/.bin/uglifyjs $< --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | ./node_modules/.bin/uglifyjs --mangle > $@

public/404.html: public/not-found/index.html
	cp $< $@

public/%: static/%
	@mkdir -p $(@D)
	cp $< $@

src/Api: node_modules
	npx elm-graphql https://cfp.elm-conf.com/graphql --base Api

include Makefile.public

Makefile.public: script/generate-makefile.py $(CONTENT_SRC)
	$< $(CONTENT_SRC) > $@

# package management

node_modules: package.json package-lock.json
	npm install
	@touch -m $@

clean:
	rm -rf public Makefile.public src/Routes.elm

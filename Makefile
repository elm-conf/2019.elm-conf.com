CONTENT_SRC=$(wildcard content/*.md content/**/*.md)
ELM_SRC=$(shell find src -name '*.elm')

STATIC_SRC=$(shell find static/ -type f)
STATIC=$(STATIC_SRC:static/%=public/%)

PHOTOS_SRC=$(shell find speaker-photos/ -type f)
PHOTOS=$(PHOTOS_SRC:speaker-photos/%=public/images/speakers/%)

# content dependencies are generated!
public: public/index.min.js $(STATIC) $(PHOTOS)
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

# photos

public/images/speakers/%: speaker-photos/%
	@mkdir -p $(@D)
	convert $< -resize 200x200^ -gravity center -extent 200x200 $@

# package management

node_modules: package.json package-lock.json
	npm install
	@touch -m $@

clean:
	rm -rf public Makefile.public src/Routes.elm

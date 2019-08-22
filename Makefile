CONTENT_SRC=$(wildcard content/*.md content/**/*.md)
ELM_SRC=$(shell find src -name '*.elm')

STATIC_SRC=$(shell find static/ -type f)
STATIC=$(STATIC_SRC:static/%=public/%)

PHOTOS_SRC=$(shell find speaker-photos/ -type f)
PHOTOS=$(PHOTOS_SRC:speaker-photos/%=images/speakers/%)

SPONSOR_PHOTOS_SRC=$(shell find sponsor-photos/ -type f)
SPONSOR_PHOTOS=$(SPONSOR_PHOTOS_SRC:sponsor-photos/%=images/sponsors/%)

# content dependencies are generated!
static: $(STATIC) $(PHOTOS) $(SPONSOR_PHOTOS)
	touch -m $@

dist: elm.json src/Api $(ELM_SRC) $(STATIC) $(PHOTOS)
	npm run build

public/%: static/%
	@mkdir -p $(@D)
	cp $< $@

src/Api: node_modules
	npx elm-graphql https://cfp.elm-conf.com/graphql --base Api

# photos

images/speakers/%: speaker-photos/%
	@mkdir -p $(@D)
	convert $< -resize 400x484^ -gravity center -extent 400x484 $@

images/sponsors/%: sponsor-photos/%
	@mkdir -p $(@D)
	convert $< -resize 400x $@

# package management

node_modules: package.json package-lock.json
	npm install --verbose
	@touch -m $@

clean:
	rm -rf dist

# testing

test: cypress/integration/a11y_spec.js
	./script/cypress-test.sh

cypress/integration/a11y_spec.js: cypress/a11y_runner.js public
	@mkdir -p $(@D)
	echo 'const URLS = `\\' > $@
	find public -name 'index.html' -type f | sed -E 's/^public//' | xargs dirname >> $@
	echo '`;' >> $@
	cat $< >> $@

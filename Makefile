CONTENT_SRC=$(wildcard content/*.md content/**/*.md)
CONTENT_PUBLIC=$(CONTENT_SRC:content/%=public/%)
CONTENT_HTML=$(CONTENT_SRC:content/%.md=public/%.html)

public: $(CONTENT_PUBLIC) $(CONTENT_HTML)
	touch -m $@

public/%.md: content/%.md
	@mkdir -p $(@D)
	cp $< $@

public/%.html: content/%.md script/make-html-wrapper.sh
	@mkdir -p $(@D)
	script/make-html-wrapper.sh $< > $@

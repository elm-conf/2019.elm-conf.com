#!/usr/bin/env python
from __future__ import print_function
import argparse
import os.path

parser = argparse.ArgumentParser()
parser.add_argument('source', nargs='+')

args = parser.parse_args()

def nice_url(source):
    if 'index.md' in source:
        return source

    return source.replace('.md', '/index.md')

SOURCE_RULE = """\
public: {target}
{target}: {source}
	@mkdir -p $(@D)
	cp $< $@
"""

def copy_source(source):
    return SOURCE_RULE.format(
        source=source,
        target=nice_url(source.replace('content', 'public')),
    )

HTML_RULE = """\
public: {target}
{target}: {source} script/make-html-wrapper.sh
	@mkdir -p $(@D)
	script/make-html-wrapper.sh $< > $@
"""

def generate_html(source):
    return HTML_RULE.format(
        source=source,
        target=nice_url(source).replace('content', 'public').replace('.md', '.html')
    )

# routes is more static than the rest of these, but it lives here so we can keep
# the URL cleaning (`nice_url`) in one place

ROUTES_RULE = """\
src/Routes.elm: script/generate-routes.py {sources}
	$< {source_dests} > $@
	elm-format --yes $@
"""

def routes(sources):
    return ROUTES_RULE.format(
        sources=' '.join(sources),
        source_dests=' '.join(
            '%s=%s' % (source, dest)
            for (source, dest)
            in zip(
                [ nice_url(source.replace('content/', '')) for source in sources ],
                [ '/' + os.path.dirname(nice_url(source.replace('content/', ''))) for source in sources ]
            )
        )
    )

rules = []

for source in args.source:
    rules.append(copy_source(source))
    rules.append(generate_html(source))

rules.append(routes(args.source))

print('\n'.join(rules))

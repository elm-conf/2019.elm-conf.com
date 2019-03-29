#!/usr/bin/env python
from __future__ import print_function
import os
import argparse

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

rules = []

for source in args.source:
    rules.append(copy_source(source))
    rules.append(generate_html(source))

print('\n\n'.join(rules))
